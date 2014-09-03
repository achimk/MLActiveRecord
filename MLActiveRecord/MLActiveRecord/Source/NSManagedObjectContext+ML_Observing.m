//
//  NSManagedObjectContext+ML_Observing.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "NSManagedObjectContext+ML_Observing.h"

#import "NSManagedObjectContext+ML.h"

#pragma mark - NSManagedObjectContext (ML_ObservingPrivate)

@interface NSManagedObjectContext (ML_ObservingPrivate)

- (void)ml_mergeChangesFromNotification:(NSNotification *)aNotification;
- (void)ml_mergeChangesOnMainThreadFromNotification:(NSNotification *)aNotification;

@end

#pragma mark -

@implementation NSManagedObjectContext (ML_Observing)

#pragma mark Observing

- (void)ml_observeContextDidSave:(NSManagedObjectContext *)otherContext {
    NSParameterAssert(otherContext);
    
    if (otherContext) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ml_mergeChangesFromNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:otherContext];
    }
}

- (void)ml_observeContextDidSaveOnMainThread:(NSManagedObjectContext *)otherContext {
    NSParameterAssert(otherContext);
    
    if (otherContext) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ml_mergeChangesOnMainThreadFromNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:otherContext];
    }
}

- (void)ml_stopObservingContextDidSave:(NSManagedObjectContext *)otherContext {
    NSParameterAssert(otherContext);
    
    if (otherContext) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:otherContext];
    }
}

#pragma mark Notifications

- (void)ml_mergeChangesFromNotification:(NSNotification *)aNotification {
    NSManagedObjectContext * fromContext = aNotification.object;
    
    if (fromContext == self) {
        return;
    }

    [self ml_performBlock:^{
        [self mergeChangesFromContextDidSaveNotification:aNotification];
    }];
}

- (void)ml_mergeChangesOnMainThreadFromNotification:(NSNotification *)aNotification {
    if ([NSThread isMainThread]) {
        [self ml_mergeChangesFromNotification:aNotification];
    }
    else {
        [self performSelectorOnMainThread:@selector(ml_mergeChangesFromNotification:) withObject:aNotification waitUntilDone:YES];
    }
}

@end
