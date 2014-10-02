//
//  MLSavingContextInMemoryCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLSavingContextInMemoryCoreDataStack.h"

#import "NSManagedObjectContext+ML.h"
#import "NSManagedObjectContext+ML_Observing.h"
#import "MLCoreDataStack+ML_Saves.h"

@implementation MLSavingContextInMemoryCoreDataStack

@synthesize persistentContext = _persistentContext;
@synthesize mainContext = _mainContext;

#pragma mark Dealloc

- (void)dealloc {
    [_mainContext ml_stopObservingContextDidSave:_persistentContext];
}

#pragma mark Load Stack

- (void)loadStack {
    [super loadStack];
    
    [self persistentContext];
    [self mainContext];
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
        return self.persistentContext;
    }
}

- (NSManagedObjectContext *)persistentContext {
    if (!_persistentContext) {
        _persistentContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _persistentContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _persistentContext;
}

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [_mainContext ml_observeContextDidSave:self.persistentContext];
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)stackSavingContext {
    return self.persistentContext;
}

@end
