//
//  MLSavingContextInMemoryCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLSavingContextInMemoryCoreDataStack.h"

#import "NSManagedObjectContext+ML.h"
#import "NSManagedObjectContext+ML_Observing.h"

@implementation MLSavingContextInMemoryCoreDataStack

@synthesize savingContext = _savingContext;
@synthesize mainContext = _mainContext;

#pragma mark Dealloc

- (void)dealloc {
    [_mainContext ml_stopObservingContextDidSave:_savingContext];
}

#pragma mark Load Stack

- (void)loadStack {
    [super loadStack];
    
    [self savingContext];
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
        return self.savingContext;
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
        _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [_mainContext ml_observeContextDidSave:self.savingContext];
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)newConfinementContext {
    NSManagedObjectContext * context = [self createConfinementContext];
    context.parentContext = self.savingContext;
    return context;
}

@end
