//
//  MLSerializingTestCase.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 16.08.2014.
//

#import "MLSerializingTestCase.h"

@implementation MLSerializingTestCase

#pragma mark Tests

- (void)testSerializingDictionaryIntoManagedObject {
    NSManagedObjectContext * context = self.stack.managedObjectContext;
    [context performBlockAndWait:^{
        id json = [self jsonObjectFromFilename:@"ArtistInfo"];
        NSDictionary * artistDictionary = [json objectForKey:@"artist"];
        
        Artist * artist = [Artist ml_objectWithDictionary:artistDictionary inContext:context];
        XCTAssertNotNil(artist, @"Can't serialize dictionary into Artist managed object");
        XCTAssertEqual(artist.name, artistDictionary[@"name"], @"Artist name is invalid");
        XCTAssertEqual(artist.identifier, artistDictionary[@"mbid"], @"Artist identifier is invalid");
        XCTAssertEqual(artist.playcount.integerValue, [artistDictionary[@"playcount"] integerValue], @"Artist playcount is invalid");
        XCTAssertEqual(artist.rank.integerValue, [artistDictionary[@"@attr"][@"rank"] integerValue], @"Artist rank is invalid");
        XCTAssertTrue(0 < artist.images.count, @"No images for artist: %@", artist.name);
        
        NSError * error = nil;
        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&error];
        NSAssert2(nil == error, @"Error during obtain pernament ID's: %@, %@", error, error.userInfo);
        
        [context save:&error];
        NSAssert2(nil == error, @"Error during save context: %@, %@", error, error.userInfo);
    }];
}

- (void)testSerializingListOfDictionariesIntoManagedObjects {
    id json = [self jsonObjectFromFilename:@"ArtistsList"];
    NSArray * artists = [[json objectForKey:@"weeklyartistchart"] objectForKey:@"artist"];
    
    NSManagedObjectContext * context = self.stack.managedObjectContext;
    [context performBlockAndWait:^{
        for (NSDictionary * artistDictionary in artists) {
            Artist * artist = [Artist ml_objectWithDictionary:artistDictionary inContext:context];
            XCTAssertNotNil(artist, @"Can't serialize dictionary into Artist managed object");
            XCTAssertEqual(artist.name, artistDictionary[@"name"], @"Artist name is invalid");
            XCTAssertEqual(artist.identifier, artistDictionary[@"mbid"], @"Artist identifier is invalid");
            XCTAssertEqual(artist.playcount.integerValue, [artistDictionary[@"playcount"] integerValue], @"Artist playcount is invalid");
            XCTAssertEqual(artist.rank.integerValue, [artistDictionary[@"@attr"][@"rank"] integerValue], @"Artist rank is invalid");
            XCTAssertTrue(0 < artist.images.count, @"No images for artist: %@", artist.name);
        }
        
        NSError * error = nil;
        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&error];
        NSAssert2(nil == error, @"Error during obtain pernament ID's: %@, %@", error, error.userInfo);
        
        [context save:&error];
        NSAssert2(nil == error, @"Error during save context: %@, %@", error, error.userInfo);
    }];
    
    XCTAssertTrue(0 < [Artist ml_countInContext:context], @"Fetched no objects for import Artists");
    XCTAssertEqual([Artist ml_countInContext:context], artists.count, @"Fetched objects count doesn't match with json dictionary count");
}

- (void)testInsertAndUpdateListOfDictionariesIntoManagedObjects {
    id json = [self jsonObjectFromFilename:@"ArtistsList"];
    NSArray * artists = [[json objectForKey:@"weeklyartistchart"] objectForKey:@"artist"];
    
    NSManagedObjectContext * context = self.stack.managedObjectContext;
    [context performBlockAndWait:^{
        for (NSDictionary * artistDictionary in artists) {
            Artist * artist = [Artist ml_objectWithDictionary:artistDictionary inContext:context];
            XCTAssertNotNil(artist, @"Can't serialize dictionary into Artist managed object");
            XCTAssertEqual(artist.name, artistDictionary[@"name"], @"Artist name is invalid");
            XCTAssertEqual(artist.identifier, artistDictionary[@"mbid"], @"Artist identifier is invalid");
            XCTAssertEqual(artist.playcount.integerValue, [artistDictionary[@"playcount"] integerValue], @"Artist playcount is invalid");
            XCTAssertEqual(artist.rank.integerValue, [artistDictionary[@"@attr"][@"rank"] integerValue], @"Artist rank is invalid");
            XCTAssertTrue(0 < artist.images.count, @"No images for artist: %@", artist.name);
            XCTAssertTrue(artist.isInserted, @"Artist must be in inserted state");
        }
        
        NSError * error = nil;
        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&error];
        NSAssert2(nil == error, @"Error during obtain pernament ID's: %@, %@", error, error.userInfo);
        
        [context save:&error];
        NSAssert2(nil == error, @"Error during save context: %@, %@", error, error.userInfo);
    }];
    
    XCTAssertTrue(0 < [Artist ml_countInContext:context], @"Fetched no objects for import Artists");
    XCTAssertEqual([Artist ml_countInContext:context], artists.count, @"Fetched objects count doesn't match with json dictionary count");
    
    [context performBlockAndWait:^{
        for (NSDictionary * artistDictionary in artists) {
            Artist * artist = [Artist ml_objectWithDictionary:artistDictionary inContext:context];
            XCTAssertNotNil(artist, @"Can't serialize dictionary into Artist managed object");
            XCTAssertEqual(artist.name, artistDictionary[@"name"], @"Artist name is invalid");
            XCTAssertEqual(artist.identifier, artistDictionary[@"mbid"], @"Artist identifier is invalid");
            XCTAssertEqual(artist.playcount.integerValue, [artistDictionary[@"playcount"] integerValue], @"Artist playcount is invalid");
            XCTAssertEqual(artist.rank.integerValue, [artistDictionary[@"@attr"][@"rank"] integerValue], @"Artist rank is invalid");
            XCTAssertTrue(0 < artist.images.count, @"No images for artist: %@", artist.name);
            XCTAssertTrue(artist.isUpdated, @"Artist must be in updated state");
        }
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"artist == nil"];
        [Image ml_deleteWithPredicate:predicate inContext:context];
        XCTAssertTrue(0 == [Image ml_countWithPredicate:predicate inContext:context], @"Empty images exists");
        
        NSError * error = nil;
        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&error];
        NSAssert2(nil == error, @"Error during obtain pernament ID's: %@, %@", error, error.userInfo);
        
        [context save:&error];
        NSAssert2(nil == error, @"Error during save context: %@, %@", error, error.userInfo);
    }];
    
    XCTAssertTrue(0 < [Artist ml_countInContext:context], @"Fetched no objects for import Artists");
    XCTAssertEqual([Artist ml_countInContext:context], artists.count, @"Fetched objects count doesn't match with json dictionary count");
}

@end
