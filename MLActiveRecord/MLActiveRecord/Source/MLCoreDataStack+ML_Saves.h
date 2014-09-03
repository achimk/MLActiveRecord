//
//  MLCoreDataStack+ML_Saves.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 28/07/14.
//

#import "MLCoreDataStack.h"

#import "NSManagedObjectContext+ML_Saves.h"

@interface MLCoreDataStack (ML_Saves)

- (void)saveWithBlock:(void(^)(NSManagedObjectContext * context))block;
- (void)saveWithBlock:(void(^)(NSManagedObjectContext * context))block completion:(MLSaveCompletionHandler)completion;

- (BOOL)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * context))block;
- (BOOL)saveWithBlockAndWait:(void (^)(NSManagedObjectContext * context))block error:(NSError **)error;

@end
