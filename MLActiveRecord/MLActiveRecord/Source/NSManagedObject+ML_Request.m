//
//  NSManagedObject+ML_Request.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 05.08.2014.
//

#import "NSManagedObject+ML_Request.h"

#import "NSManagedObject+ML.h"
#import "MLCoreDataStack.h"

@implementation NSManagedObject (ML_Request)

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate {
    return [self ml_requestWithPredicate:predicate
                     withSortDescriptors:nil
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context {
    return [self ml_requestWithPredicate:predicate
                     withSortDescriptors:nil
                               inContext:context];
}

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor {
    return [self ml_requestWithPredicate:predicate
                     withSortDescriptors:(descriptor) ? @[descriptor] : nil
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor inContext:(NSManagedObjectContext *)context {
    return [self ml_requestWithPredicate:predicate
                     withSortDescriptors:(descriptor) ? @[descriptor] : nil
                               inContext:context];
}

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors {
    return [self ml_requestWithPredicate:predicate
                     withSortDescriptors:descriptors
                               inContext:[[MLCoreDataStack defaultStack] managedObjectContext]];
}

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors inContext:(NSManagedObjectContext *)context {
    NSParameterAssert(context);
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self ml_entityDescriptionInContext:context];
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = descriptors;
    
    return fetchRequest;
}

@end
