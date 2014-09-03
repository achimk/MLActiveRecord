//
//  MLManagedObjectContextTestCase.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 16.08.2014.
//

#import "MLManagedObjectContextTestCase.h"

@implementation MLManagedObjectContextTestCase

- (void)testSyncSaveContext {
    NSError * error = nil;
    NSManagedObjectContext * saveContext = self.stack.managedObjectContext;
    
    id json = [self jsonObjectFromFilename:@"ArtistInfo"];
    NSDictionary * artistDictionary = [json objectForKey:@"artist"];
    [Artist ml_objectWithDictionary:artistDictionary inContext:saveContext error:&error];
    XCTAssertNil(error, @"Error during importing data into context");
    XCTAssertTrue([saveContext hasChanges], @"Context doesn't have changes after import");
    
    NSInteger count = [Artist ml_countInContext:saveContext];
    XCTAssertTrue(0 < count, @"Context doesn't contains Artist objects");

    BOOL saved = [saveContext ml_saveAndWait:&error];
    XCTAssertNil(error, @"Error during saving context");
    XCTAssertTrue(saved, @"Data not saved");
    XCTAssertFalse([saveContext hasChanges], @"Context still have changes after save");
}

- (void)testAsyncSaveContext {
    NSError * error = nil;
    NSManagedObjectContext * saveContext = self.stack.managedObjectContext;
    
    id json = [self jsonObjectFromFilename:@"ArtistInfo"];
    NSDictionary * artistDictionary = [json objectForKey:@"artist"];
    [Artist ml_objectWithDictionary:artistDictionary inContext:saveContext error:&error];
    XCTAssertNil(error, @"Error during importing data into context");
    XCTAssertTrue([saveContext hasChanges], @"Context doesn't have changes after import");
    
    NSInteger count = [Artist ml_countInContext:saveContext];
    XCTAssertTrue(0 < count, @"Context doesn't contains Artist objects");

    __block BOOL finished = NO;
    [saveContext ml_saveWithCompletion:^(BOOL isSuccess, NSError *saveError) {
        XCTAssertNil(saveError, @"Error during saving context");
        XCTAssertTrue(isSuccess, @"Data not saved");
        finished = YES;
    }];
    
    while (!finished) {
        NSDate * oneSecond = [NSDate dateWithTimeIntervalSinceNow:1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:oneSecond];
    }
    
    XCTAssertFalse([saveContext hasChanges], @"Context still have changes after save");
}

- (void)testSyncSaveParentContext {
    NSError * error = nil;
    NSManagedObjectContext * saveContext = self.stack.managedObjectContext;
    NSManagedObjectContext * mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    mainContext.parentContext = saveContext;
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = mainContext;
    
    id json = [self jsonObjectFromFilename:@"ArtistInfo"];
    NSDictionary * artistDictionary = [json objectForKey:@"artist"];
    [Artist ml_objectWithDictionary:artistDictionary inContext:backgroundContext error:&error];
    XCTAssertNil(error, @"Error during importing data into context");
    XCTAssertTrue([backgroundContext hasChanges], @"Context doesn't have changes after import");
    
    NSInteger count = [Artist ml_countInContext:backgroundContext];
    XCTAssertTrue(0 < count, @"Context doesn't contains Artist objects");
    
    BOOL saved = [backgroundContext ml_saveStackAndWait:&error];
    XCTAssertNil(error, @"Error during saving context");
    XCTAssertTrue(saved, @"Data not saved");
    XCTAssertFalse([saveContext hasChanges], @"Save context still have changes after save");
    XCTAssertFalse([mainContext hasChanges], @"Main context still have changes after save");
    XCTAssertFalse([backgroundContext hasChanges], @"Background context still have changes after save");
}

- (void)testAsyncSaveParentContext {
    NSError * error = nil;
    NSManagedObjectContext * saveContext = self.stack.managedObjectContext;
    NSManagedObjectContext * mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    mainContext.parentContext = saveContext;
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = mainContext;
    
    id json = [self jsonObjectFromFilename:@"ArtistInfo"];
    NSDictionary * artistDictionary = [json objectForKey:@"artist"];
    [Artist ml_objectWithDictionary:artistDictionary inContext:backgroundContext error:&error];
    XCTAssertNil(error, @"Error during importing data into context");
    XCTAssertTrue([backgroundContext hasChanges], @"Context doesn't have changes after import");
    
    NSInteger count = [Artist ml_countInContext:backgroundContext];
    XCTAssertTrue(0 < count, @"Context doesn't contains Artist objects");
    
    __block BOOL finished = NO;
    [backgroundContext ml_saveStackWithCompletion:^(BOOL isSuccess, NSError *saveError) {
        XCTAssertNil(saveError, @"Error during saving context");
        XCTAssertTrue(isSuccess, @"Data not saved");
        finished = YES;
    }];
    
    while (!finished) {
        NSDate * oneSecond = [NSDate dateWithTimeIntervalSinceNow:1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:oneSecond];
    }
    
    XCTAssertFalse([saveContext hasChanges], @"Save context still have changes after save");
    XCTAssertFalse([mainContext hasChanges], @"Main context still have changes after save");
    XCTAssertFalse([backgroundContext hasChanges], @"Background context still have changes after save");
}

- (void)testPerformBlocks {
    NSManagedObjectContext * saveContext = self.stack.managedObjectContext;
    NSManagedObjectContext * mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    mainContext.parentContext = saveContext;
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = mainContext;

    [saveContext ml_performBlockAndWait:^{
        NSManagedObjectContext *threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
        XCTAssertNotNil(threadContext, @"Thread dictionary doesn't contains current block context");
        XCTAssertTrue(saveContext == threadContext, @"Thread context doesn't match with save context");
    }];

    [mainContext ml_performBlockAndWait:^{
        NSManagedObjectContext *threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
        XCTAssertNotNil(threadContext, @"Thread dictionary doesn't contains current block context");
        XCTAssertTrue(mainContext == threadContext, @"Thread context doesn't match with main context");
    }];

    [backgroundContext ml_performBlockAndWait:^{
        NSManagedObjectContext *threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
        XCTAssertNotNil(threadContext, @"Thread dictionary doesn't contains current block context");
        XCTAssertTrue(backgroundContext == threadContext, @"Thread context doesn't match with background context");
    }];

    [backgroundContext ml_performBlockAndWait:^{
        NSManagedObjectContext *threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
        XCTAssertNotNil(threadContext, @"Thread dictionary doesn't contains current block context");
        XCTAssertTrue(backgroundContext == threadContext, @"Thread context doesn't match with background context");

        NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        localContext.parentContext = threadContext;

        [localContext ml_performBlockAndWait:^{
            NSManagedObjectContext *threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
            XCTAssertNotNil(threadContext, @"Thread dictionary doesn't contains current block context");
            XCTAssertTrue(localContext == threadContext, @"Thread context doesn't match with local context");
        }];

        threadContext = [[[NSThread currentThread] threadDictionary] objectForKey:MLActiveRecordManagedObjectContextKey];
        XCTAssertNotNil(threadContext, @"Thread dictionary doesn't contains current block context");
        XCTAssertTrue(backgroundContext == threadContext, @"Thread context doesn't match with background context");
    }];
}

- (void)testSaveCompletionHandlers {
    __block BOOL finished = NO;
    NSManagedObjectContext * saveContext = self.stack.managedObjectContext;

    [Artist ml_createInContext:saveContext];
    XCTAssertTrue([saveContext hasChanges], @"Save context doesn't have changes about Artist object");

    [saveContext ml_saveWithOptions:MLSaveNoOptions completion:^(BOOL isSuccess, NSError *saveError) {
        XCTAssertNil(saveError, @"Error during saving context");
        XCTAssertTrue(isSuccess, @"Data not saved");
        XCTAssertFalse([NSThread isMainThread], @"Completion called on main thread");
        finished = YES;
    }];
    
    while (!finished) {
        NSDate * oneSecond = [NSDate dateWithTimeIntervalSinceNow:1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:oneSecond];
    }
    
    XCTAssertFalse([saveContext hasChanges], @"Save context still have changes after save");

    [Artist ml_createInContext:saveContext];
    XCTAssertTrue([saveContext hasChanges], @"Save context doesn't have changes about Artist object");
    
    finished = NO;
    [saveContext ml_saveWithOptions:MLSaveCompleteOnMainDispatchQueue completion:^(BOOL isSuccess, NSError *saveError) {
        XCTAssertNil(saveError, @"Error during saving context");
        XCTAssertTrue(isSuccess, @"Data not saved");
        XCTAssertTrue([NSThread isMainThread], @"Completion called on non main thread");
        finished = YES;
    }];
    
    while (!finished) {
        NSDate * oneSecond = [NSDate dateWithTimeIntervalSinceNow:1];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:oneSecond];
    }
    
    XCTAssertFalse([saveContext hasChanges], @"Save context still have changes after save");
}



@end
