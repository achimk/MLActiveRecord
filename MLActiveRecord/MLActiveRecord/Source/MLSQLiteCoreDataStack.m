//
//  MLSQLiteCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLSQLiteCoreDataStack.h"

#import "MLActiveRecordDefines.h"
#import "MLCoreDataStack+ML_Errors.h"

#pragma mark - MLSQLiteCoreDataStack

@interface MLSQLiteCoreDataStack ()

- (NSString *)directoryWithSearchPathDirectory:(NSSearchPathDirectory)searchPathDirectory;
- (NSString *)applicationDocumentsDirectory;
- (NSString *)applicationStorageDirectory;
- (BOOL)removePersistentStoreFilesAtURL:(NSURL *)anURL error:(NSError **)error;

@end

#pragma mark -

@implementation MLSQLiteCoreDataStack

+ (NSDictionary *)defaultStoreOptions {
    return @{
             NSMigratePersistentStoresAutomaticallyOption     : @(YES),
             NSInferMappingModelAutomaticallyOption           : @(YES),
             NSSQLitePragmasOption                            : @{@"journal_mode"  : @"WAL"}
             };
}

+ (instancetype)stackWithStoreAtPath:(NSString *)path {
    return [self stackWithStoreAtPath:path model:nil];
}

+ (instancetype)stackWithStoreNamed:(NSString *)name {
    return [self stackWithStoreNamed:name model:nil];
}

+ (instancetype)stackWithStoreAtURL:(NSURL *)url {
    return [self stackWithStoreAtURL:url model:nil];
}

+ (instancetype)stackWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model {
    return [[self alloc] initWithStoreAtPath:path model:model];
}

+ (instancetype)stackWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model {
    return [[self alloc] initWithStoreNamed:name model:model];
}

+ (instancetype)stackWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model {
    return [[self alloc] initWithStoreAtURL:url model:model];
}

#pragma mark Init

- (id)init {
    METHOD_USE_DESIGNATED_INIT;
}

- (id)initWithStoreAtPath:(NSString *)path {
    return [self initWithStoreAtPath:path model:nil];
}

- (id)initWithStoreNamed:(NSString *)name {
    return [self initWithStoreNamed:name model:nil];
}

- (id)initWithStoreAtURL:(NSURL *)url {
    return [self initWithStoreAtURL:url model:nil];
}

- (id)initWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model {
    NSParameterAssert(path);
    NSURL * anURL = [NSURL URLWithString:path];
    return [self initWithStoreAtURL:anURL model:model];
}

- (id)initWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model {
    NSParameterAssert(name);
    NSURL * anURL = [self urlForStoreNamed:name];
    return [self initWithStoreAtURL:anURL model:model];
}

- (id)initWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model {
    NSParameterAssert(url);
    
    if (self = [super init]) {
        _shouldDeletePersistentStoreOnModelMismatch = NO;
        _storeURL = [url copy];
        _managedObjectModel = model;
    }
    
    return self;
}

#pragma mark Accessors

- (NSURL *)urlForStoreNamed:(NSString *)storeName {
    NSMutableArray * paths = [NSMutableArray array];
    [paths addObject:(([self applicationDocumentsDirectory]) ?: [NSNull null])];
    [paths addObject:(([self applicationStorageDirectory]) ?: [NSNull null])];
    NSFileManager * fileManager = nil;
    
    for (id path in paths) {
        if ([path isKindOfClass:[NSString class]]) {
            NSString * filePath = [(NSString *)path stringByAppendingPathComponent:storeName];
            
            if ([fileManager fileExistsAtPath:filePath]) {
                return [NSURL URLWithString:filePath];
            }
        }
    }
    
    return [NSURL fileURLWithPath:[[self applicationStorageDirectory] stringByAppendingPathComponent:storeName]];
}

#pragma mark Subclass Methods

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator {
    NSURL * anURL = self.storeURL;
    NSManagedObjectModel * model = self.managedObjectModel;
    NSPersistentStoreCoordinator * coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    if (coordinator) {
        NSError * error = nil;
        BOOL pathExists = YES;
        NSFileManager * fileManager = [NSFileManager new];
        
        if (![fileManager fileExistsAtPath:[[anURL URLByDeletingLastPathComponent] path] isDirectory:nil]) {
            pathExists = [fileManager createDirectoryAtURL:[anURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        if (pathExists) {
            error = nil;
            NSDictionary * options = self.storeOptions;
            NSPersistentStore * store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:anURL options:options error:&error];
            
            if (self.shouldDeletePersistentStoreOnModelMismatch && !store && error) {
                BOOL isMigrationError = ([error code] == NSPersistentStoreIncompatibleVersionHashError) || ([error code] == NSMigrationMissingSourceModelError);
                
                if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError) {
                    if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError) {
                        // Could not open the database, so... kill it! (AND WAL bits)
                        [self removePersistentStoreFilesAtURL:anURL error:nil];
                        MLLog(@"→ Removed incompatible model version: %@", [anURL lastPathComponent]);
                    }
                    
                    // try one more time to create the store
                    store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:anURL options:options error:&error];
                    
                    if (store) {
                        // if we successfully added a store, remove the error that was initially created
                        error = nil;
                    }
                }
            }
        }
        
        if (error) {
            [MLCoreDataStack handleErrors:error];
        }
    }
    
    return coordinator;
}

#pragma mark Private Methods

- (NSString *)directoryWithSearchPathDirectory:(NSSearchPathDirectory)searchPathDirectory {
    NSArray * objects = NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES);
    return (objects && objects.count) ? [objects lastObject] : nil;
}

- (NSString *)applicationDocumentsDirectory {
    return [self directoryWithSearchPathDirectory:NSDocumentDirectory];
}

- (NSString *)applicationStorageDirectory {
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    return [[self directoryWithSearchPathDirectory:NSApplicationSupportDirectory] stringByAppendingPathComponent:appName];
}

- (BOOL)removePersistentStoreFilesAtURL:(NSURL *)anURL error:(NSError **)error {
    NSParameterAssert(anURL);
    NSAssert([anURL isFileURL], @"URL must be a file URL.");
    
    NSString * rawURL = [anURL absoluteString];
    NSURL * shmSidecar = [NSURL URLWithString:[rawURL stringByAppendingString:@"-shm"]];
    NSURL * walSidecar = [NSURL URLWithString:[rawURL stringByAppendingString:@"-wal"]];
    
    BOOL removeItemResult = YES;
    NSError * removeItemError = nil;
    
    for (NSURL * toRemove in @[anURL, shmSidecar, walSidecar]) {
        BOOL itemResult = [[NSFileManager defaultManager] removeItemAtURL:toRemove error:&removeItemError];
        removeItemResult = removeItemResult && (itemResult || [removeItemError code] == NSFileNoSuchFileError);
    }
    
    if (error) {
        *error = removeItemError;
    }
    
    return removeItemResult;
}

@end
