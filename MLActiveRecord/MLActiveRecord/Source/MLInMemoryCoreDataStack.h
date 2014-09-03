//
//  MLInMemoryCoreDataStack.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLCoreDataStack.h"

@interface MLInMemoryCoreDataStack : MLCoreDataStack

+ (instancetype)stackWithModel:(NSManagedObjectModel *)model;

- (id)initWithModel:(NSManagedObjectModel *)model;

@end
