//
//  NSManagedObject+ML.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ML)

+ (instancetype)ml_create;
+ (instancetype)ml_createInContext:(NSManagedObjectContext *)context;

+ (NSString *)ml_entityName;
+ (NSEntityDescription *)ml_entityDescription;
+ (NSEntityDescription *)ml_entityDescriptionInContext:(NSManagedObjectContext *)context;

+ (void)ml_deleteAll;
+ (void)ml_deleteAllInContext:(NSManagedObjectContext *)context;
+ (void)ml_deleteWithPredicate:(NSPredicate *)predicate;
+ (void)ml_deleteWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

- (instancetype)ml_inContext:(NSManagedObjectContext *)context;
- (NSDictionary *)ml_dictionary;

@end
