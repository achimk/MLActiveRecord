//
//  MLCoreDataStack+ML_Saves.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 28/07/14.
//

#import "MLCoreDataStack+ML_Saves.h"

@implementation MLCoreDataStack (ML_Saves)

+ (dispatch_queue_t)saveDispatchQueue {
    static dispatch_queue_t saveDispatchQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveDispatchQueue = dispatch_queue_create(ML_QUEUE_NAME("MlCoreDataStack.saveQueue"), DISPATCH_QUEUE_SERIAL);
    });
    
    return saveDispatchQueue;
}

#pragma mark Save Additions

- (void)saveWithBlock:(void(^)(NSManagedObjectContext * context))block {
    [self saveWithBlock:block completion:nil];
}

- (void)saveWithBlock:(void(^)(NSManagedObjectContext * context))block completion:(MLSaveCompletionHandler)completion {
    NSParameterAssert(block);
    
    dispatch_queue_t saveQueue = [[self class] saveDispatchQueue];
    dispatch_async(saveQueue, ^{
        @autoreleasepool {
            NSManagedObjectContext * localContext = [self newConfinementContext];
            block(localContext);
            [localContext ml_saveWithOptions:MLSaveSynchronously | MLSaveCompleteOnMainDispatchQueue | MLSaveParentContexts completion:completion];
        }
    });
}

- (BOOL)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * context))block {
    return [self saveWithBlockAndWait:block error:nil];
}

- (BOOL)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * context))block error:(NSError **)error {
    NSParameterAssert(block);
    
    NSManagedObjectContext * localContext = [self newConfinementContext];
    block(localContext);
    
    if (!localContext.hasChanges) {
        return NO;
    }
    
    __block BOOL saveSuccess = YES;

    [localContext ml_saveWithOptions:MLSaveSynchronously | MLSaveParentContexts | MLSaveCompleteOnMainDispatchQueue completion:^(BOOL isSuccess, NSError *saveError) {
        saveSuccess = isSuccess;

        if (error) {
            *error = saveError;
        }
    }];
    
    return saveSuccess;
}

@end
