//
//  NSManagedObjectContext+ML_Saves.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import "NSManagedObjectContext+ML_Saves.h"

#import "NSManagedObjectContext+ML.h"
#import "MLActiveRecordDefines.h"

#define CALL_COMPLETION_BLOCK(onMainThread, block, isSuccess, error) \
if (!block) { \
return; \
} \
else if (onMainThread) { \
if ([NSThread isMainThread]) { \
block(isSuccess, error); \
} \
else { \
dispatch_async(dispatch_get_main_queue(), ^{ \
block(isSuccess, error); \
}); \
} \
} \
else { \
block(isSuccess, error); \
} \

@implementation NSManagedObjectContext (ML_Saves)

- (BOOL)ml_saveAndWait:(NSError **)error {
    __block BOOL saveSuccess = YES;
    MLSaveCompletionHandler completionHandler = ^(BOOL isSuccess, NSError * saveError) {
        saveSuccess = isSuccess;
        
        if (error) {
            *error = saveError;
        }
    };
    
    [self ml_saveWithOptions:MLSaveSynchronously | MLSaveCompleteOnMainDispatchQueue completion:completionHandler];
    
    return saveSuccess;
}

- (void)ml_saveWithCompletion:(MLSaveCompletionHandler)completion {
    [self ml_saveWithOptions:MLSaveCompleteOnMainDispatchQueue completion:completion];
}

- (BOOL)ml_saveStackAndWait:(NSError **)error {
    __block BOOL saveSuccess = YES;
    MLSaveCompletionHandler completionHandler = ^(BOOL isSuccess, NSError * saveError) {
        saveSuccess = isSuccess;
        
        if (error) {
            *error = saveError;
        }
    };
    
    [self ml_saveWithOptions:MLSaveParentContexts | MLSaveSynchronously | MLSaveCompleteOnMainDispatchQueue completion:completionHandler];
    
    return saveSuccess;
}

- (void)ml_saveStackWithCompletion:(MLSaveCompletionHandler)completion {
    [self ml_saveWithOptions:MLSaveParentContexts | MLSaveCompleteOnMainDispatchQueue completion:completion];
}

- (void)ml_saveStackWithMainCompletion:(MLSaveCompletionHandler)completion {
    [self ml_saveWithOptions:MLSaveParentContexts | MLSaveCompleteOnMainDispatchQueue | MLSaveCompleteOnMainContext completion:completion];
}

- (void)ml_saveWithOptions:(MLSaveOptions)options completion:(MLSaveCompletionHandler)completion {
    BOOL shouldSaveSync                     = ((options & MLSaveSynchronously) == MLSaveSynchronously);
    BOOL shouldSaveSyncExceptRoot           = ((options & MLSaveSynchronouslyExceptRoot) == MLSaveSynchronouslyExceptRoot);
    BOOL syncSave                           = (shouldSaveSync && !shouldSaveSyncExceptRoot) || (shouldSaveSyncExceptRoot && (nil == self.parentContext));
    BOOL saveParentContexts                 = ((options & MLSaveParentContexts) == MLSaveParentContexts);
    BOOL shouldCompleteOnMainDispatchQueue  = ((options & MLSaveCompleteOnMainDispatchQueue) == MLSaveCompleteOnMainDispatchQueue);
    BOOL shouldCompleteOnMainContext        = ((options & MLSaveCompleteOnMainContext) == MLSaveCompleteOnMainContext);
    __block BOOL hasChanges = NO;
    
    if ([self concurrencyType] == NSConfinementConcurrencyType) {
        hasChanges = [self hasChanges];
    }
    else {
        [self performBlockAndWait:^{
            hasChanges = [self hasChanges];
        }];
    }
    
    if (!hasChanges) {
        if (!saveParentContexts || !self.parentContext) {
            CALL_COMPLETION_BLOCK(shouldCompleteOnMainDispatchQueue, completion, YES, nil);
            return;
        }
    }
    
    void (^saveBlock)(void) = ^{
        NSString *optionsSummary = @"";
        optionsSummary = [optionsSummary stringByAppendingString:saveParentContexts ? @"Save Parents,":@""];
        optionsSummary = [optionsSummary stringByAppendingString:syncSave ? @"Sync Save":@""];
        
        MLLog(@"→ Saving %@ [%@]", self, optionsSummary);
        
        NSError * error = nil;
        BOOL saved = NO;
        
        @try {
            saved = [self save:&error];
        }
        @catch(NSException * exception) {
            MLLog(@"Unable to perform save: %@", (id)[exception userInfo] ? : (id)[exception reason]);
        }
        @finally {
            if (!saved) {
                CALL_COMPLETION_BLOCK(shouldCompleteOnMainDispatchQueue, completion, saved, error);
            }
            else {
                // If we should not save the parent context, or there is not a parent context to save (root context), call the completion block
                if ((YES == saveParentContexts) && [self parentContext]) {
                    if (shouldCompleteOnMainContext && NSMainQueueConcurrencyType == self.concurrencyType) {
                        CALL_COMPLETION_BLOCK(shouldCompleteOnMainDispatchQueue, completion, saved, error);
                        
                        [[self parentContext] ml_saveWithOptions:options completion:nil];
                    }
                    else {
                        [[self parentContext] ml_saveWithOptions:options completion:completion];
                    }
                }
                // If we are not the default context (And therefore need to save the root context, do the completion action if one was specified
                else {
                    MLLog(@"→ Finished saving: %@", self);
                    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
                    NSUInteger numberOfInsertedObjects = [[self insertedObjects] count];
                    NSUInteger numberOfUpdatedObjects = [[self updatedObjects] count];
                    NSUInteger numberOfDeletedObjects = [[self deletedObjects] count];
#pragma clang diagnostic pop
                    
                    MLLog(@"Objects - Inserted %tu, Updated %tu, Deleted %tu", numberOfInsertedObjects, numberOfUpdatedObjects, numberOfDeletedObjects);
                    
                    CALL_COMPLETION_BLOCK(shouldCompleteOnMainDispatchQueue, completion, saved, error);
                }
            }
        }
    };
    
    if ([self concurrencyType] == NSConfinementConcurrencyType) {
        saveBlock();
    }
    else if (syncSave) {
        [self performBlockAndWait:saveBlock];
    }
    else {
        [self performBlock:saveBlock];
    }
}

- (void)ml_performBlock:(void(^)())block andSaveWithCompletion:(MLSaveCompletionHandler)completion {
    [self ml_saveWithOptions:MLSaveCompleteOnMainDispatchQueue block:block completion:completion];
}

- (void)ml_performBlock:(void(^)())block andSaveStackWithCompletion:(MLSaveCompletionHandler)completion {
    [self ml_saveWithOptions:MLSaveParentContexts | MLSaveCompleteOnMainDispatchQueue block:block completion:completion];
}

- (void)ml_saveWithOptions:(MLSaveOptions)options block:(void(^)())block completion:(MLSaveCompletionHandler)completion {
    [self ml_performBlock:^{
        if (block) {
            block();
        }
        
        [self ml_saveWithOptions:options completion:completion];
    }];
}

@end
