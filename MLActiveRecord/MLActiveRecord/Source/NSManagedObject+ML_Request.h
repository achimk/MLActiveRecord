//
//  NSManagedObject+ML_Request.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 05.08.2014.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (ML_Request)

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate;
+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptor:(NSSortDescriptor *)descriptor inContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors;
+ (NSFetchRequest *)ml_requestWithPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)descriptors inContext:(NSManagedObjectContext *)context;

@end
