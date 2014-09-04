//
//  MLDefaultInMemoryCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 04/09/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLDefaultInMemoryCoreDataStack.h"

#import "MLCoreDataStack+ML_Saves.h"
#import "NSManagedObjectContext+ML.h"

@implementation MLDefaultInMemoryCoreDataStack

@synthesize persistentContext = _persistentContext;
@synthesize mainContext = _mainContext;
@synthesize saveContext = _saveContext;

#pragma mark Load Stack

- (void)loadStack {
    [super loadStack];
    
    [self persistentContext];
    [self mainContext];
    [self saveContext];
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
        return self.saveContext;
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
        _mainContext.parentContext = self.persistentContext;
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)saveContext {
    if (!_saveContext) {
        _saveContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _saveContext.parentContext = self.mainContext;
    }
    
    return _saveContext;
}

- (NSManagedObjectContext *)stackSavingContext {
    return self.saveContext;
}

@end
