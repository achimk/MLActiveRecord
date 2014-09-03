//
//  MLCustomInMemoryCoreDataStack.m
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLCustomInMemoryCoreDataStack.h"

@implementation MLCustomInMemoryCoreDataStack

@synthesize savingContext = _savingContext;
@synthesize mainContext = _mainContext;
@synthesize backgroundContext = _backgroundContext;

#pragma mark Load Stack

- (void)loadStack {
    [super loadStack];
    
    [self savingContext];
    [self mainContext];
    [self backgroundContext];
}

#pragma mark Accessors

- (NSManagedObjectContext *)managedObjectContext {
    NSDictionary * threadDictionary = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext * threadContext = threadDictionary[MLActiveRecordManagedObjectContextKey];
    
    if (threadContext) {
        return threadContext;
    }
    else if ([NSThread isMainThread]) {
        return self.mainContext;
    }
    else {
        return self.backgroundContext;
    }
}

- (NSManagedObjectContext *)savingContext {
    if (!_savingContext) {
        _savingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _savingContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _savingContext;
}

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.parentContext = self.savingContext;
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _backgroundContext.parentContext = self.mainContext;
    }
    
    return _backgroundContext;
}

- (NSManagedObjectContext *)newConfinementContext {
    NSManagedObjectContext * context = [self createConfinementContext];
    context.parentContext = self.backgroundContext;
    return context;
}

@end
