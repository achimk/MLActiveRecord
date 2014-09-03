//
//  NSManagedObject+ML_Serialization.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import "NSManagedObject+ML_Serialization.h"

#import "MLCoreDataStack.h"
#import "NSManagedObject+ML.h"
#import "NSManagedObjectContext+ML.h"
#import "MLActiveRecordUtilities.h"

NSString * const MLManagedObjectSerializingErrorDomain = @"MLManagedObjectSerializingErrorDomain";

#pragma mark - NSManagedObject (ML_Serialization_Private)

@interface NSManagedObject (ML_Serialization_Private)

+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context validateForInsert:(BOOL)shouldValidateInsert error:(NSError *__autoreleasing *)error;
+ (NSString *)ml_managedObjectKeyForPropertyKey:(NSString *)key;
+ (NSString *)ml_propertyKeyForManagedObjectKey:(NSString *)key;
+ (NSPredicate *)ml_uniquingPredicateForDictionary:(NSDictionary *)dictionary;
+ (NSValueTransformer *)ml_entityAttributeTransformerForKey:(NSString *)key;

@end

#pragma mark -

@implementation NSManagedObject (ML_Serialization)


+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary {
    return [self ml_objectWithDictionary:dictionary inContext:[[MLCoreDataStack defaultStack] managedObjectContext] validateForInsert:YES error:nil];
}

+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    return [self ml_objectWithDictionary:dictionary inContext:[[MLCoreDataStack defaultStack] managedObjectContext] validateForInsert:YES error:error];
}

+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    return [self ml_objectWithDictionary:dictionary inContext:context validateForInsert:YES error:nil];
}

+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context error:(NSError **)error {
    return [self ml_objectWithDictionary:dictionary inContext:context validateForInsert:YES error:error];
}

+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context validateForInsert:(BOOL)shouldValidateInsert error:(NSError *__autoreleasing *)error {
//#warning Checking for cycles when processing relationships is not supported!
    
    NSAssert([self conformsToProtocol:@protocol(MLManagedObjectSerializing)], @"'%@' doesn't conforms to protocol: MLManagedObjectSerializing", self.class);
    NSParameterAssert(dictionary);
    NSParameterAssert(context);
    
    NSString * entityName = [self ml_entityName];
	NSAssert(nil != entityName, @"%@ returned a nil +ml_entityName", self.class);
    
    __block NSManagedObject * managedObject = nil;
    NSPredicate * uniquingPredicate = [self ml_uniquingPredicateForDictionary:dictionary];
    
    //fetch unique managedObject with predicate
    if (uniquingPredicate) {
        __block NSError * fetchRequestError = nil;
        __block BOOL encountedError = NO;

        [context ml_performBlockAndWait:^{
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
            fetchRequest.predicate = uniquingPredicate;
            fetchRequest.returnsObjectsAsFaults = NO;
            fetchRequest.fetchLimit = 1;

            NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchRequestError];

            if (!results) {
                encountedError = YES;

                if (error) {
                    NSString *failureReason = [NSString stringWithFormat:NSLocalizedString(@"Failed to fetch a managed object for uniqing predicate \"%@\".", @""), uniquingPredicate];
                    NSDictionary *userInfo = @{
                            NSLocalizedDescriptionKey : NSLocalizedString(@"Could not serialize managed object", @""),
                            NSLocalizedFailureReasonErrorKey : failureReason,
                    };
                    fetchRequestError = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorUniqueFetchRequestFailed userInfo:userInfo];
                }
            }
            else {
                managedObject = results.firstObject;
            }
        }];
        
        if (encountedError && error) {
            *error = fetchRequestError;
            return nil;
        }
    }
    
    if (!managedObject) {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    
    //managedObject error
    if (!managedObject) {
        if (error) {
            NSString * failureReason = [NSString stringWithFormat:NSLocalizedString(@"Failed to initialize a managed object from entity named \"%@\".", @""), entityName];
			NSDictionary * userInfo = @{
                                        NSLocalizedDescriptionKey: NSLocalizedString(@"Could not serialize managed object", @""),
                                        NSLocalizedFailureReasonErrorKey: failureReason,
                                        };
            
			*error = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorInitializationFailed userInfo:userInfo];
        }
        
        return nil;
    }
    
    __block NSError * tmpError = nil;
    NSDictionary * managedObjectProperties = managedObject.entity.propertiesByName;
    
    //enumerate dictionary
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * propertyKey, id value, BOOL *stop) {
        NSString * managedObjectKey = [self ml_managedObjectKeyForPropertyKey:propertyKey];
        
        if (!managedObjectKey) {
            return;
        }
        
        if ([value isEqual:[NSNull null]]) {
            value = nil;
        }
        
        // serialize attribute block
        BOOL (^serializeAttribute)(NSAttributeDescription *) = ^(NSAttributeDescription *attributeDescription) {
			__autoreleasing id transformedValue = value;
            NSValueTransformer * attributeTransformer = [self ml_entityAttributeTransformerForKey:propertyKey];
            
			if (attributeTransformer) {
                transformedValue = [attributeTransformer transformedValue:transformedValue];
            }
            
			if (![managedObject validateValue:&transformedValue forKey:managedObjectKey error:&tmpError]) {
                return NO;
            }
            
			[managedObject setValue:transformedValue forKey:managedObjectKey];
            
			return YES;
        };
        
        // relationship from model block
        NSManagedObject * (^objectForRelationshipFromObject)(id) = ^ id (id object) {
            if (![object isKindOfClass:[NSDictionary class]]) {
				NSString * failureReason = [NSString stringWithFormat:NSLocalizedString(@"Property of class %@ cannot be encoded into an NSManagedObject.", @""), [object class]];
				NSDictionary * userInfo = @{
                                            NSLocalizedDescriptionKey: NSLocalizedString(@"Could not serialize managed object", @""),
                                            NSLocalizedFailureReasonErrorKey: failureReason
                                            };
                tmpError = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorUnsupportedRelationshipClass userInfo:userInfo];
                return nil;
            }
            
            NSDictionary * relationshipClasses = [self.class relationshipModelClassesByPropertyKey];
            Class nestedClass = relationshipClasses[propertyKey];
            
            if (!nestedClass) {
                NSDictionary * userInfo = @{
                                            NSLocalizedDescriptionKey: NSLocalizedString(@"Could not deserialize managed object", @""),
                                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No model class could be found to deserialize the object.", @"")
                                            };
                
				tmpError = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorNoClassFound userInfo:userInfo];
                return nil;
            }
            
            return [nestedClass ml_objectWithDictionary:(NSDictionary *) object inContext:context validateForInsert:NO error:&tmpError];
        };
        
        // serialize relationship block
        BOOL (^serializeRelationship)(NSRelationshipDescription *) = ^(NSRelationshipDescription *relationshipDescription) {
			if (!value) {
                return YES;
            }
            
			if ([relationshipDescription isToMany]) {
				if (![value conformsToProtocol:@protocol(NSFastEnumeration)]) {
					NSString * failureReason = [NSString stringWithFormat:NSLocalizedString(@"Property of class %@ cannot be encoded into a to-many relationship.", @""), [value class]];
					NSDictionary * userInfo = @{
                                                NSLocalizedDescriptionKey: NSLocalizedString(@"Could not serialize managed object", @""),
                                                NSLocalizedFailureReasonErrorKey: failureReason
                                                };
                    
					tmpError = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorUnsupportedRelationshipClass userInfo:userInfo];
                    
					return NO;
				}
                
				id relationshipCollection;
                
				if ([relationshipDescription isOrdered]) {
					relationshipCollection = [NSMutableOrderedSet orderedSet];
				}
                else {
					relationshipCollection = [NSMutableSet set];
				}
                
				for (id object in value) {
					NSManagedObject * nestedObject = objectForRelationshipFromObject(object);
                    
					if (nestedObject == nil) {
                        return NO;
                    }
                    
					[relationshipCollection addObject:nestedObject];
				}
                
				[managedObject setValue:relationshipCollection forKey:managedObjectKey];
			}
            else {
				NSManagedObject * nestedObject = objectForRelationshipFromObject(value);
                
				if (nestedObject == nil) {
                    return NO;
                }
                
				[managedObject setValue:nestedObject forKey:managedObjectKey];
			}
            
			return YES;
		};
        
        // serialize property block
        BOOL (^serializeProperty)(NSPropertyDescription *) = ^(NSPropertyDescription * propertyDescription) {
			if (!propertyDescription) {
				NSString * failureReason = [NSString stringWithFormat:NSLocalizedString(@"No property by name \"%@\" exists on the entity.", @""), managedObjectKey];
				NSDictionary * userInfo = @{
                                            NSLocalizedDescriptionKey: NSLocalizedString(@"Could not serialize managed object", @""),
                                            NSLocalizedFailureReasonErrorKey: failureReason
                                            };
                
				tmpError = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorInvalidManagedObjectKey userInfo:userInfo];
                
				return NO;
			}
            
			// Jump through some hoops to avoid referencing classes directly.
			NSString * propertyClassName = NSStringFromClass(propertyDescription.class);
            
			if ([propertyClassName isEqual:@"NSAttributeDescription"]) {
				return serializeAttribute((id)propertyDescription);
			}
            else if ([propertyClassName isEqual:@"NSRelationshipDescription"]) {
				return serializeRelationship((id)propertyDescription);
			}
            else {
				NSString * failureReason = [NSString stringWithFormat:NSLocalizedString(@"Property descriptions of class %@ are unsupported.", @""), propertyClassName];
                
				NSDictionary * userInfo = @{
                                            NSLocalizedDescriptionKey: NSLocalizedString(@"Could not serialize managed object", @""),
                                            NSLocalizedFailureReasonErrorKey: failureReason
                                            };
                
				tmpError = [NSError errorWithDomain:MLManagedObjectSerializingErrorDomain code:MLManagedObjectSerializngErrorUnsupportedManagedObjectPropertyType userInfo:userInfo];
                
				return NO;
			}
		};
        
        // perform serialize
        if (!serializeProperty(managedObjectProperties[managedObjectKey])) {
            [context ml_performBlockAndWait:^{
                [context deleteObject:managedObject];
            }];
            
			managedObject = nil;
			*stop = YES;
		}
    }];
    
    if (managedObject && shouldValidateInsert && ![managedObject validateForInsert:&tmpError]) {
        [context ml_performBlockAndWait:^{
            [context deleteObject:managedObject];
        }];
        
        managedObject = nil;
	}
    
    if (error) {
        *error = tmpError;
    }
    
    return managedObject;
}

#pragma mark Private Methods

+ (NSString *)ml_managedObjectKeyForPropertyKey:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([self conformsToProtocol:@protocol(MLManagedObjectSerializing)], @"'%@' doesn't conforms to protocol: MLManagedObjectSerializing", self.class);

    NSDictionary * propertyKeys = [self.class managedObjectKeysByPropertyKey];
    return (propertyKeys) ? propertyKeys[key] : nil;
}

+ (NSString *)ml_propertyKeyForManagedObjectKey:(NSString *)key {
    NSParameterAssert(key);
    NSAssert([self conformsToProtocol:@protocol(MLManagedObjectSerializing)], @"'%@' doesn't conforms to protocol: MLManagedObjectSerializing", self.class);

    NSDictionary * propertyKeys = [self.class managedObjectKeysByPropertyKey];
    
    __block NSString * propertyKey = nil;
    [propertyKeys enumerateKeysAndObjectsUsingBlock:^(NSString * objKey, NSString * objValue, BOOL * stop) {
        if ([objValue isEqualToString:key]) {
            propertyKey = objKey;
            *stop = YES;
        }
    }];
    
    return propertyKey;
}

+ (NSPredicate *)ml_uniquingPredicateForDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    
    if (![self.class respondsToSelector:@selector(propertyKeysForManagedObjectUniquing)]) {
        return nil;
    }
    
    NSSet * propertyKeys = [self.class propertyKeysForManagedObjectUniquing];
    
    if (!propertyKeys) {
        return nil;
    }
    
    NSAssert(0 < propertyKeys.count, @"+propertyKeysForManagedObjectUniquing must not be empty.");
    NSMutableArray * subpredicates = [NSMutableArray array];
    
	for (NSString * propertyKey in propertyKeys) {
		NSString * managedObjectKey = [self ml_managedObjectKeyForPropertyKey:propertyKey];
		NSAssert(managedObjectKey != nil, @"%@ must map to a managed object key.", propertyKey);
        
		id transformedValue = [dictionary valueForKeyPath:propertyKey];
        
		NSValueTransformer *attributeTransformer = [self ml_entityAttributeTransformerForKey:propertyKey];
		if (attributeTransformer != nil) transformedValue = [attributeTransformer transformedValue:transformedValue];
        
		NSPredicate *subpredicate = [NSPredicate predicateWithFormat:@"%K == %@", managedObjectKey, transformedValue];
		[subpredicates addObject:subpredicate];
	}
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

+ (NSValueTransformer *)ml_entityAttributeTransformerForKey:(NSString *)key {
	NSParameterAssert(key != nil);
    
	SEL selector = MLSelectorWithKeyPattern(key, "EntityAttributeTransformer");
	if ([self.class respondsToSelector:selector]) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self.class methodSignatureForSelector:selector]];
		invocation.target = self.class;
		invocation.selector = selector;
		[invocation invoke];
        
		__unsafe_unretained id result = nil;
		[invocation getReturnValue:&result];
		return result;
	}
    
	if ([self.class respondsToSelector:@selector(entityAttributeTransformerForKey:)]) {
		return [self.class entityAttributeTransformerForKey:key];
	}
    
	return nil;
}

@end
