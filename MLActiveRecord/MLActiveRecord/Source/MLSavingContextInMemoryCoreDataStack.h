//
//  MLSavingContextInMemoryCoreDataStack.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLInMemoryCoreDataStack.h"

@interface MLSavingContextInMemoryCoreDataStack : MLInMemoryCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * persistentContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;

@end
