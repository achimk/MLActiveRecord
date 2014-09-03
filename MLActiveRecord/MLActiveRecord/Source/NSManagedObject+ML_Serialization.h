//
//  NSManagedObject+ML_Serialization.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import <CoreData/CoreData.h>

extern NSString * const MLManagedObjectSerializingErrorDomain;

typedef enum {
    MLManagedObjectSerializngErrorNoClassFound = 1,
    MLManagedObjectSerializngErrorInitializationFailed,
    MLManagedObjectSerializngErrorInvalidManagedObjectKey,
    MLManagedObjectSerializngErrorUnsupportedManagedObjectPropertyType,
    MLManagedObjectSerializngErrorUniqueFetchRequestFailed,
    MLManagedObjectSerializngErrorUnsupportedRelationshipClass,
    MLManagedObjectSerializngErrorInvalidManagedObjectMapping
} MLManagedObjectSerializngError;

#pragma mark - MLManagedObjectSerializing

@protocol MLManagedObjectSerializing <NSObject>

@required
+ (NSDictionary *)managedObjectKeysByPropertyKey;
+ (NSDictionary *)relationshipModelClassesByPropertyKey;

@optional
+ (NSSet *)propertyKeysForManagedObjectUniquing;
+ (NSValueTransformer *)entityAttributeTransformerForKey:(NSString *)key;

@end

#pragma mark - NSManagedObject (ML_Serialization)

@interface NSManagedObject (ML_Serialization)

+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;
+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;
+ (instancetype)ml_objectWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context error:(NSError **)error;


@end
