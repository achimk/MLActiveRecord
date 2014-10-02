//
//  MLCoreDataStack+ML_Saves.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 28/07/14.
//

#import "MLCoreDataStack+ML_Saves.h"

#import "NSManagedObjectContext+ML.h"

@implementation MLCoreDataStack (ML_Saves)

+ (dispatch_queue_t)saveDispatchQueue {
    static dispatch_queue_t saveDispatchQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveDispatchQueue = dispatch_queue_create(ML_QUEUE_NAME("MLCoreDataStack.saveQueue"), DISPATCH_QUEUE_SERIAL);
    });
    
    return saveDispatchQueue;
}

#pragma mark Save Additions

- (NSManagedObjectContext *)stackSavingContext {
    return self.managedObjectContext;
}

- (void)saveWithBlock:(void(^)(NSManagedObjectContext * context))block {
    [self saveWithBlock:block completion:nil];
}

- (void)saveWithBlock:(void(^)(NSManagedObjectContext * context))block completion:(MLSaveCompletionHandler)completion {
    
#warning Should we check for confinamed context and dispatch on saveDispatchQueue?
    
    NSManagedObjectContext * context = self.stackSavingContext;
    NSAssert(context, @"Stack saving context is Nil");
    void (^processBlock)(void) = ^{
        if (block) {
            block(context);
        }
    };
    
    [context ml_saveWithOptions:MLSaveSynchronously | MLSaveCompleteOnMainDispatchQueue | MLSaveParentContexts
                          block:processBlock
                     completion:completion];
}

- (BOOL)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * context))block {
    return [self saveWithBlockAndWait:block error:nil];
}

- (BOOL)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * context))block error:(NSError **)error {
    NSManagedObjectContext * context = self.stackSavingContext;
    NSAssert(context, @"Stack saving context is Nil");

#warning Should we check for confinamed context and dispatch on saveDispatchQueue?
    
    if (block) {
        [context ml_performBlockAndWait:^{
            block(context);
        }];
    }
    
    __block BOOL saveSuccess = YES;
    [context ml_saveWithOptions:MLSaveSynchronously | MLSaveParentContexts | MLSaveCompleteOnMainDispatchQueue completion:^(BOOL isSuccess, NSError * saveError) {
        saveSuccess = isSuccess;
        
        if (error) {
            *error = saveError;
        }
    }];
    
    return saveSuccess;
}

@end
