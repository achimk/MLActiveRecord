//
//  MLCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 21/07/14.
//

#import "MLCoreDataStack.h"

#import "MLActiveRecordDefines.h"
#import "NSManagedObjectContext+ML.h"
#import "NSManagedObjectContext+ML_Saves.h"
#import "NSManagedObjectModel+ML.h"
#import "MLCoreDataStack+ML_Saves.h"

static MLCoreDataStack * defaultStack = nil;

#pragma mark - MLCoreDataStack

@interface MLCoreDataStack ()

@end

#pragma mark -

@implementation MLCoreDataStack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStore = _persistentStore;
@synthesize storeOptions = _storeOptions;

+ (instancetype)defaultStack {
    return defaultStack;
}

+ (void)setDefaultStack:(MLCoreDataStack *)stack {
    NSAssert([NSThread isMainThread], @"Must be called on main thread");
    defaultStack = stack;
    [stack loadStack];
}

+ (NSDictionary *)defaultStoreOptions {
    return nil;
}

#pragma mark Init / Dealloc

- (id)init {
    if (self = [super init]) {
        _saveOnApplicationWillResignActive = NO;
        _saveOnApplicationWillTerminate = NO;
        self.storeOptions = [[self class] defaultStoreOptions];
    }
    
    return self;
}

- (void)dealloc {
    self.saveOnApplicationWillResignActive = NO;
    self.saveOnApplicationWillTerminate = NO;
}

#pragma mark Load Stack

- (void)loadStack {
    [self managedObjectModel];
    [self persistentStoreCoordinator];
    [self managedObjectContext];
}

#pragma mark Accessors

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectContext *)newConfinementContext {
    NSManagedObjectContext * context = [self createConfinementContext];
    return context;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [self createPersistentStoreCoordinator];
        _persistentStore = [[_persistentStoreCoordinator persistentStores] lastObject];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        // looks up all models in the specified bundles and merges them; if nil is specified as argument, uses the main bundle
        _managedObjectModel = [NSManagedObjectModel ml_managedObjectModelFromMainBundle];
    }
    
    return _managedObjectModel;
}

- (void)setSaveOnApplicationWillResignActive:(BOOL)saveOnApplicationWillResignActive {
    if (saveOnApplicationWillResignActive != _saveOnApplicationWillResignActive) {
        if (_saveOnApplicationWillResignActive) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationWillResignActiveNotification
                                                          object:nil];
        }
        
        _saveOnApplicationWillResignActive = saveOnApplicationWillResignActive;
        
        if (saveOnApplicationWillResignActive) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillResignActiveNotification:)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
        }
    }
}

- (void)setSaveOnApplicationWillTerminate:(BOOL)saveOnApplicationWillTerminate {
    if (saveOnApplicationWillTerminate != _saveOnApplicationWillTerminate) {
        if (_saveOnApplicationWillTerminate) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationWillTerminateNotification
                                                          object:nil];
        }
        
        _saveOnApplicationWillTerminate = saveOnApplicationWillTerminate;
        
        if (saveOnApplicationWillTerminate) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillTerminateNotification:)
                                                         name:UIApplicationWillTerminateNotification
                                                       object:nil];
        }
    }
}

#pragma mark Subclass Methods

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator {
    METHOD_MUST_BE_OVERRIDDEN;
}

- (NSManagedObjectContext *)createConfinementContext {
    NSManagedObjectContext * context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return context;
}

#pragma mark Notifications

- (void)applicationWillTerminateNotification:(NSNotification *)aNotification {
    [self saveWithBlockAndWait:nil];
}

- (void)applicationWillResignActiveNotification:(NSNotification *)aNotification {
    [self saveWithBlockAndWait:nil];
}

@end
