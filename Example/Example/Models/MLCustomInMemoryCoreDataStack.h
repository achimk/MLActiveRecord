//
//  MLCustomInMemoryCoreDataStack.h
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLInMemoryCoreDataStack.h"

@interface MLCustomInMemoryCoreDataStack : MLInMemoryCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * savingContext;     // persistent context
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;       // UI updates
@property (nonatomic, readonly, strong) NSManagedObjectContext * backgroundContext; // create / update / delete

@end
