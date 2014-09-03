//
//  MLCustomInMemoryCoreDataStack.h
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLInMemoryCoreDataStack.h"

@interface MLCustomInMemoryCoreDataStack : MLInMemoryCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * savingContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * backgroundContext;

@end
