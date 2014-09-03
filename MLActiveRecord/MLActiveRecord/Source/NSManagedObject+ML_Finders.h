//
//  NSManagedObject+ML_Finders.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ML_Finders)

/*
 *  Has objects in context
 */
+ (BOOL)ml_hasObjects;
+ (BOOL)ml_hasObjectsInContext:(NSManagedObjectContext *)context;
+ (BOOL)ml_hasObjects:(id)condition;
+ (BOOL)ml_hasObjects:(id)condition inContext:(NSManagedObjectContext *)context;
+ (BOOL)ml_hasObjectsWithPredicate:(NSPredicate *)predicate;
+ (BOOL)ml_hasObjectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

/*
 *  Count objects in context
 */
+ (NSInteger)ml_count;
+ (NSInteger)ml_countInContext:(NSManagedObjectContext *)context;
+ (NSInteger)ml_count:(id)condition;
+ (NSInteger)ml_count:(id)condition inContext:(NSManagedObjectContext *)context;
+ (NSInteger)ml_countWithPredicate:(NSPredicate *)predicate;
+ (NSInteger)ml_countWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

/*
 *  Returns NSManagedObject in context
 */
+ (instancetype)ml_object:(NSString *)condition;
+ (instancetype)ml_object:(NSString *)condition inContext:(NSManagedObjectContext *)context;
+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate;
+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor;
+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor inContext:(NSManagedObjectContext *)context;
+ (instancetype)ml_objectWithMaxValueFor:(NSString *)attribute;
+ (instancetype)ml_objectWithMaxValueFor:(NSString *)attribute inConrext:(NSManagedObjectContext *)context;
+ (instancetype)ml_objectWithMinValueFor:(NSString *)attribute;
+ (instancetype)ml_objectWithMinValueFor:(NSString *)attribute inContext:(NSManagedObjectContext *)context;

/*
 *  Returns objects in context
 */
+ (NSArray *)ml_ordered:(id)order;
+ (NSArray *)ml_ordered:(id)order inContext:(NSManagedObjectContext *)context;
+ (NSArray *)ml_orderedAscendingBy:(NSString *)key;
+ (NSArray *)ml_orderedAscendingBy:(NSString *)key inContext:(NSManagedObjectContext *)context;
+ (NSArray *)ml_orderedDescendingBy:(NSString *)key;
+ (NSArray *)ml_orderedDescendingBy:(NSString *)key inContext:(NSManagedObjectContext *)context;

+ (NSArray *)ml_objects;
+ (NSArray *)ml_objectsInContext:(NSManagedObjectContext *)context;
+ (NSArray *)ml_objects:(id)condition;
+ (NSArray *)ml_objects:(id)condition inContext:(NSManagedObjectContext *)context;
+ (NSArray *)ml_objects:(id)condition ordered:(id)order;
+ (NSArray *)ml_objects:(id)condition ordered:(id)order inContext:(NSManagedObjectContext *)context;

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor inContext:(NSManagedObjectContext *)context;
+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors;
+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors inContext:(NSManagedObjectContext *)context;

@end
