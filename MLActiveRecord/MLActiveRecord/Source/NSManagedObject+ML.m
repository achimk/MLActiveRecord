//
//  NSManagedObject+ML.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import "NSManagedObject+ML.h"

#import "NSManagedObject+ML_Finders.h"
#import "MLCoreDataStack.h"
#import "MLCoreDataStack+ML_Errors.h"

@implementation NSManagedObject (ML)

#pragma mark Create

+ (instancetype)ml_create {
    return [self ml_createInContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (instancetype)ml_createInContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    return [NSEntityDescription insertNewObjectForEntityForName:self.ml_entityName inManagedObjectContext:context];
}

#pragma mark Entity

+ (NSString *)ml_entityName {
    return NSStringFromClass([self class]);
}

+ (NSEntityDescription *)ml_entityDescription {
    return [self ml_entityDescriptionInContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSEntityDescription *)ml_entityDescriptionInContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    return [NSEntityDescription entityForName:self.ml_entityName inManagedObjectContext:context];
}

#pragma mark Delete

+ (void)ml_deleteAll {
    [self ml_deleteWithPredicate:nil inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (void)ml_deleteAllInContext:(NSManagedObjectContext *)context {
    [self ml_deleteWithPredicate:nil inContext:context];
}

+ (void)ml_deleteWithPredicate:(NSPredicate *)predicate {
    [self ml_deleteWithPredicate:predicate inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (void)ml_deleteWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    NSArray * objects = [self ml_objectsWithPredicate:predicate inContext:context];
    
    for (NSManagedObject * object in objects) {
        [context deleteObject:object];
    }
}

#pragma mark Public Methods

- (instancetype)ml_inContext:(NSManagedObjectContext *)context {
    NSError * error = nil;
    
    if (self.objectID.isTemporaryID) {
        BOOL isSuccess = [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:&error];
        
        if (!isSuccess) {
            [MLCoreDataStack handleErrors:error];
            return nil;
        }
    }
    
    NSManagedObject * managedObject = [context existingObjectWithID:self.objectID error:&error];
    
    if (error) {
        [MLCoreDataStack handleErrors:error];
    }
    
    return managedObject;
}

- (NSDictionary *)ml_dictionary {
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    NSDictionary * attributes = self.entity.attributesByName;
    
    for (NSString * key in attributes.allKeys) {
        id value = [self valueForKey:key];
        
        if (value) {
            [dictionary setObject:value forKey:key];
        }
    }
    
    return dictionary;
}

@end
