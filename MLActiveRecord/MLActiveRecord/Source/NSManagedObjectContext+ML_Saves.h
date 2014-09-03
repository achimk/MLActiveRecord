//
//  NSManagedObjectContext+ML_Saves.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import <CoreData/CoreData.h>

typedef NS_OPTIONS(NSUInteger, MLSaveOptions) {
    MLSaveNoOptions                     = 0,        // No options — used for cleanliness only.
    MLSaveParentContexts                = 1 << 0,   // When saving, continue saving parent contexts until the changes are present in the persistent store.
    MLSaveSynchronously                 = 1 << 1,   // Perform saves synchronously, blocking execution on the current thread until the save is complete.
    MLSaveSynchronouslyExceptRoot       = 1 << 2,   // Perform saves synchronously, blocking execution on the current thread until the save is complete; however, saves root context asynchronously
    MLSaveCompleteOnMainDispatchQueue   = 1 << 3,   // Call complete block only on main dispatch queue
    MLSaveCompleteOnMainContext         = 1 << 4    // hen saving, check for main context and call complete block. If main context not found then call complete on the end of saves loop.
};

typedef void (^MLSaveCompletionHandler)(BOOL isSuccess, NSError * error);

@interface NSManagedObjectContext (ML_Saves)

/*
 * Synchronously save changes in the current context and it's parent.
 * Executes a save on the current context's dispatch queue. This method only saves the current context, and the parent of the current context
 * if one is set. The method will not return until the save is complete.
 */
- (BOOL)ml_saveAndWait:(NSError **)error;

/*
 * Asynchronously save changes in the current context and it's parent.
 * Executes a save on the current context's dispatch queue asynchronously. This method only saves the current context, and the parent of the
 * current context if one is set. The completion block will always be called on the main queue.
 */
- (void)ml_saveWithCompletion:(MLSaveCompletionHandler)completion;

/*
 * Synchronously save changes in the current context all the way back to the persistent store.
 * Executes saves on the current context, and any ancestors, until the changes have been persisted to the assigned persistent store. The
 * method will not return until the save is complete.
 */
- (BOOL)ml_saveStackAndWait:(NSError **)error;

/*
 * Asynchronously save changes in the current context all the way back to the persistent store.
 * Executes asynchronous saves on the current context, and any ancestors, until the changes have been persisted to the assigned persistent
 * store. The completion block will always be called on the main queue.
 */
- (void)ml_saveStackWithCompletion:(MLSaveCompletionHandler)completion;

/*
 * Save the current context with options.
 * All other save methods are conveniences to this method.
 */
- (void)ml_saveWithOptions:(MLSaveOptions)options completion:(MLSaveCompletionHandler)completion;

/*
 * Perform block for context and asynchronously save changes in the current context and it's parent.
 * Executes a save on the current context's dispatch queue asynchronously. This method only saves the current context, and the parent of the
 * current context if one is set. The completion block will always be called on the main queue.
 */
- (void)ml_performBlock:(void(^)())block andSaveWithCompletion:(MLSaveCompletionHandler)completion;

/*
 * Perform block for context adn asynchronously save changes in the current context all the way back to the persistent store.
 * Executes asynchronous saves on the current context, and any ancestors, until the changes have been persisted to the assigned persistent
 * store. The completion block will always be called on the main queue.
 */
- (void)ml_performBlock:(void(^)())block andSaveStackWithCompletion:(MLSaveCompletionHandler)completion;

/*
 * Perform block for context and save the current context with options.
 */
- (void)ml_saveWithOptions:(MLSaveOptions)options block:(void(^)())block completion:(MLSaveCompletionHandler)completion;

@end
