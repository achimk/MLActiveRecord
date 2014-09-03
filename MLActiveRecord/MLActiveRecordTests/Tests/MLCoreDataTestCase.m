//
//  MLCoreDataTestCase.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "MLCoreDataTestCase.h"

#import "MLTestCoreDataStack.h"

#pragma mark - MLCoreDataTestCase

@interface MLCoreDataTestCase ()

@property (nonatomic, readwrite, strong) MLCoreDataStack * stack;

@end

#pragma mark -

@implementation MLCoreDataTestCase

#pragma mark Set Up

- (void)setUp {
    [super setUp];

    // initialize stack
    self.stack = [MLTestCoreDataStack stack];
}

- (void)tearDown {
    // release stack
    self.stack = nil;
    
    [super tearDown];
}

#pragma mark Public Methds

- (void)importArtist {
    NSParameterAssert(self.stack);
    NSParameterAssert(self.stack.managedObjectContext);

    NSManagedObjectContext * context = self.stack.managedObjectContext;
    [context performBlockAndWait:^{
        id json = [self jsonObjectFromFilename:@"ArtistInfo"];
        NSDictionary * artistDictionary = [json objectForKey:@"artist"];
        
        Artist * artist = (Artist *)[NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
        artist.name         = artistDictionary[@"name"];
        artist.identifier   = artistDictionary[@"mbid"];
        artist.path         = artistDictionary[@"url"];
        artist.playcount    = @([artistDictionary[@"playcount"] integerValue]);
        artist.rank         = @([artistDictionary[@"@attr"][@"rank"] integerValue]);
        
        NSMutableSet * images = [NSMutableSet set];
        
        for (NSDictionary * imageDictionary in artistDictionary[@"image"]) {
            Image * image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
            image.path  = imageDictionary[@"#text"];
            image.size  = imageDictionary[@"size"];
            [images addObject:image];
        }
        
        artist.images = images;
        
        NSError * error = nil;
        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&error];
        NSAssert2(nil == error, @"Error during obtain pernament ID's: %@, %@", error, error.userInfo);
        
        [context save:&error];
        NSAssert2(nil == error, @"Error during save context: %@, %@", error, error.userInfo);
    }];
}

- (void)importArtistsList {
    NSParameterAssert(self.stack);
    NSParameterAssert(self.stack.managedObjectContext);
    
    NSManagedObjectContext * context = self.stack.managedObjectContext;
    [context performBlockAndWait:^{
        id json = [self jsonObjectFromFilename:@"ArtistsList"];
        NSArray * artists = [[json objectForKey:@"weeklyartistchart"] objectForKey:@"artist"];
        
        for (NSDictionary * artistDictionary in artists) {
            Artist * artist = (Artist *)[NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
            artist.name         = artistDictionary[@"name"];
            artist.identifier   = artistDictionary[@"mbid"];
            artist.path         = artistDictionary[@"url"];
            artist.playcount    = @([artistDictionary[@"playcount"] integerValue]);
            artist.rank         = @([artistDictionary[@"@attr"][@"rank"] integerValue]);
            
            NSMutableSet * images = [NSMutableSet set];
            
            for (NSDictionary * imageDictionary in artistDictionary[@"image"]) {
                Image * image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
                image.path  = imageDictionary[@"#text"];
                image.size  = imageDictionary[@"size"];
                [images addObject:image];
            }
            
            artist.images = images;
        }
        
        NSError * error = nil;
        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&error];
        NSAssert2(nil == error, @"Error during obtain pernament ID's: %@, %@", error, error.userInfo);
        
        [context save:&error];
        NSAssert2(nil == error, @"Error during save context: %@, %@", error, error.userInfo);
    }];
}

#pragma mark Tests

- (void)testCoreDataStack {
    XCTAssertNotNil(self.stack, @"Stack is Nil");
    XCTAssertNotNil(self.stack.managedObjectModel, @"Stack model is Nil");
    XCTAssertNotNil(self.stack.persistentStoreCoordinator, @"Coordinator is Nil");
    XCTAssertNotNil(self.stack.persistentStore, @"Persistent store is Nil");
    XCTAssertNotNil(self.stack.managedObjectContext, @"Context is Nil");
}

- (void)testImportArtist {
    [self importArtist];
 
    NSManagedObjectContext * context = self.stack.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        NSAssert2(nil == error, @"Error during fetch objects: %@, %@", error, error.userInfo);
    }
    
    XCTAssertTrue(1 == fetchedObjects.count, @"Fetched objects count must be equal 1");
    
    for (Artist * artist in fetchedObjects) {
        XCTAssertTrue(0 < artist.images.count, @"No images for artist: %@", artist.name);
    }
}

- (void)testImportArtistList {
    [self importArtistsList];
    
    NSManagedObjectContext * context = self.stack.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Artist" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rank"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray * fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        NSAssert2(nil == error, @"Error during fetch objects: %@, %@", error, error.userInfo);
    }
    
    id json = [self jsonObjectFromFilename:@"ArtistsList"];
    NSArray * artists = [[json objectForKey:@"weeklyartistchart"] objectForKey:@"artist"];
    
    XCTAssertTrue(0 < fetchedObjects.count, @"Fetched no objects for import Artists");
    XCTAssertTrue(artists.count == fetchedObjects.count, @"Fetched objects count doesn't match with json dictionary count");
    
    for (Artist * artist in fetchedObjects) {
        XCTAssertTrue(0 < artist.images.count, @"No images for artist: %@", artist.name);
    }
}

@end
