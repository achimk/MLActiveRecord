//
//  NSManagedObjectContext+ML.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import "NSManagedObjectContext+ML.h"

NSString * const MLActiveRecordManagedObjectContextKey = @"MLActiveRecordManagedObjectContextKey";

@implementation NSManagedObjectContext (ML)

#pragma mark Perform Block

- (void)ml_performBlock:(void (^)())block {
    [self ml_performBlock:block synchronously:NO];
}

- (void)ml_performBlockAndWait:(void (^)())block {
    [self ml_performBlock:block synchronously:YES];
}

- (void)ml_performBlock:(void (^)())block synchronously:(BOOL)isSync {
    if (!block) {
        return;
    }
    
    void (^performBlock)(void) = ^{
        NSManagedObjectContext * threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
        [[[NSThread currentThread] threadDictionary] setObject:self forKey:MLActiveRecordManagedObjectContextKey];
        
        block();

        [[[NSThread currentThread] threadDictionary] removeObjectForKey:MLActiveRecordManagedObjectContextKey];
        
        if (threadContext) {
            [[[NSThread currentThread] threadDictionary] setObject:threadContext forKey:MLActiveRecordManagedObjectContextKey];
        }
    };
    
    if (NSConfinementConcurrencyType == self.concurrencyType) {
        performBlock();
    }
    else if (isSync) {
        [self performBlockAndWait:performBlock];
    }
    else {
        [self performBlock:performBlock];
    }
}


@end
