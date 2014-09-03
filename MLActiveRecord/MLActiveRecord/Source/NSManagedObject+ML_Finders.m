//
//  NSManagedObject+ML_Finders.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import "NSManagedObject+ML_Finders.h"

#import "NSManagedObject+ML.h"
#import "NSPredicate+ML.h"
#import "NSSortDescriptor+ML.h"
#import "MLCoreDataStack.h"
#import "MLCoreDataStack+ML_Errors.h"

@implementation NSManagedObject (ML_Finders)

#pragma mark - Check has object

+ (BOOL)ml_hasObjects {
    return [self ml_hasObjectsWithPredicate:nil inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (BOOL)ml_hasObjectsInContext:(NSManagedObjectContext *)context {
    return [self ml_hasObjectsWithPredicate:nil inContext:context];
}

+ (BOOL)ml_hasObjects:(id)condition {
    return [self ml_hasObjects:[NSPredicate ml_condition:condition] inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (BOOL)ml_hasObjects:(id)condition inContext:(NSManagedObjectContext *)context {
    return [self ml_hasObjects:[NSPredicate ml_condition:condition] inContext:context];
}

+ (BOOL)ml_hasObjectsWithPredicate:(NSPredicate *)predicate {
    return [self ml_hasObjectsWithPredicate:predicate inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (BOOL)ml_hasObjectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    return (0 < [self ml_countWithPredicate:predicate inContext:context]);
}

#pragma mark - Count objects

+ (NSInteger)ml_count {
    return [self ml_countWithPredicate:nil inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSInteger)ml_countInContext:(NSManagedObjectContext *)context {
    return [self ml_countWithPredicate:nil inContext:context];
}

+ (NSInteger)ml_count:(id)condition {
    return [self ml_countWithPredicate:[NSPredicate ml_condition:condition] inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSInteger)ml_count:(id)condition inContext:(NSManagedObjectContext *)context {
    return [self ml_countWithPredicate:[NSPredicate ml_condition:condition] inContext:context];
}

+ (NSInteger)ml_countWithPredicate:(NSPredicate *)predicate {
    return [self ml_countWithPredicate:predicate inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSInteger)ml_countWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self ml_entityDescriptionInContext:context];
    fetchRequest.predicate = predicate;
    
    NSError * error = nil;
    NSInteger count = [context countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [MLCoreDataStack handleErrors:error];
    }
    
    return count;
}

#pragma mark - Return first object

+ (instancetype)ml_object:(NSString *)condition {
    return [self ml_objectWithPredicate:[NSPredicate ml_condition:condition]
                     withSortDescriptor:nil
                              inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (instancetype)ml_object:(NSString *)condition inContext:(NSManagedObjectContext *)context {
    return [self ml_objectWithPredicate:[NSPredicate ml_condition:condition]
                     withSortDescriptor:nil
                              inContext:context];
}

+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate {
    return [self ml_objectWithPredicate:predicate
                     withSortDescriptor:nil
                              inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    return [self ml_objectWithPredicate:predicate
                     withSortDescriptor:nil
                              inContext:context];
}

+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor {
    return [self ml_objectWithPredicate:predicate
                     withSortDescriptor:descriptor
                              inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (instancetype)ml_objectWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self ml_entityDescriptionInContext:context];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = (descriptor) ? @[descriptor] : nil;
    fetchRequest.fetchLimit = 1;
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSError * error = nil;
    NSArray * objects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!objects && error) {
        [MLCoreDataStack handleErrors:error];
    }
    
    return objects.firstObject;
}

+ (instancetype)ml_objectWithMaxValueFor:(NSString *)attribute {
    return [self ml_objectWithMaxValueFor:attribute inConrext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (instancetype)ml_objectWithMaxValueFor:(NSString *)attribute inConrext:(NSManagedObjectContext *)context {
    NSParameterAssert(attribute);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K != nil", attribute];
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:attribute ascending:NO];
    return [self ml_objectWithPredicate:predicate
                     withSortDescriptor:descriptor
                              inContext:context];
}

+ (instancetype)ml_objectWithMinValueFor:(NSString *)attribute {
    return [self ml_objectWithMinValueFor:attribute inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (instancetype)ml_objectWithMinValueFor:(NSString *)attribute inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(attribute);
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"%K != nil", attribute];
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:attribute ascending:YES];
    return [self ml_objectWithPredicate:predicate
                     withSortDescriptor:descriptor
                              inContext:context];
}

#pragma mark - Returns objects

+ (NSArray *)ml_ordered:(id)order {
    return [self ml_objectsWithPredicate:nil
                     withSortDescriptors:[NSSortDescriptor ml_descriptors:order]
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_ordered:(id)order inContext:(NSManagedObjectContext *)context {
    return [self ml_objectsWithPredicate:nil
                     withSortDescriptors:[NSSortDescriptor ml_descriptors:order]
                               inContext:context];
}

+ (NSArray *)ml_orderedAscendingBy:(NSString *)key {
    return [self ml_orderedAscendingBy:key inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_orderedAscendingBy:(NSString *)key inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(key);
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
    return [self ml_objectsWithPredicate:nil
                     withSortDescriptors:@[descriptor]
                               inContext:context];
}

+ (NSArray *)ml_orderedDescendingBy:(NSString *)key {
    return [self ml_orderedAscendingBy:key inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_orderedDescendingBy:(NSString *)key inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(key);
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:NO];
    return [self ml_objectsWithPredicate:nil
                     withSortDescriptors:@[descriptor]
                               inContext:context];
}

#pragma mark -

+ (NSArray *)ml_objects {
    return [self ml_objectsWithPredicate:nil
                     withSortDescriptors:nil
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_objectsInContext:(NSManagedObjectContext *)context {
    return [self ml_objectsWithPredicate:nil
                     withSortDescriptors:nil
                               inContext:context];
}

+ (NSArray *)ml_objects:(id)condition {
    return [self ml_objectsWithPredicate:[NSPredicate ml_condition:condition]
                     withSortDescriptors:nil
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_objects:(id)condition inContext:(NSManagedObjectContext *)context {
    return [self ml_objectsWithPredicate:[NSPredicate ml_condition:condition]
                     withSortDescriptors:nil
                               inContext:context];
}

+ (NSArray *)ml_objects:(id)condition ordered:(id)order {
    return [self ml_objectsWithPredicate:[NSPredicate ml_condition:condition]
                     withSortDescriptors:[NSSortDescriptor ml_descriptors:order]
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_objects:(id)condition ordered:(id)order inContext:(NSManagedObjectContext *)context {
    return [self ml_objectsWithPredicate:[NSPredicate ml_condition:condition]
                     withSortDescriptors:[NSSortDescriptor ml_descriptors:order]
                               inContext:context];
}

#pragma mark -

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate {
    return [self ml_objectsWithPredicate:predicate
                     withSortDescriptors:nil
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    return [self ml_objectsWithPredicate:predicate
                     withSortDescriptors:nil
                               inContext:context];
}

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor {
    NSArray * descriptors = (descriptor) ? @[descriptor] : nil;
    return [self ml_objectsWithPredicate:predicate
                     withSortDescriptors:descriptors
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor inContext:(NSManagedObjectContext *)context {
    NSArray * descriptors = (descriptor) ? @[descriptor] : nil;
    return [self ml_objectsWithPredicate:predicate
                     withSortDescriptors:descriptors
                               inContext:context];
}

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors {
    return [self ml_objectsWithPredicate:predicate
                     withSortDescriptors:descriptors
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSArray *)ml_objectsWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self ml_entityDescriptionInContext:context];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = descriptors;
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSError * error = nil;
    NSArray * objects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!objects && error) {
        [MLCoreDataStack handleErrors:error];
    }
    
    return objects;
}

@end
