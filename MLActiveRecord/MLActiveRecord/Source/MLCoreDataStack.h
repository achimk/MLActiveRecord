//
//  MLCoreDataStack.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 21/07/14.
//

#import <CoreData/CoreData.h>

#import "MLActiveRecordDefines.h"

@interface MLCoreDataStack : NSObject {
@protected
    NSManagedObjectContext * _managedObjectContext;
    NSPersistentStoreCoordinator * _persistentStoreCoordinator;
    NSManagedObjectModel * _managedObjectModel;
    NSPersistentStore * _persistentStore;
}

@property (nonatomic, readonly, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStore * persistentStore;
@property (nonatomic, readwrite, copy) NSDictionary * storeOptions;
@property (nonatomic, assign) BOOL saveOnApplicationWillTerminate;
@property (nonatomic, assign) BOOL saveOnApplicationWillResignActive;

+ (instancetype)defaultStack;
+ (void)setDefaultStack:(MLCoreDataStack *)stack;
+ (NSDictionary *)defaultStoreOptions;

- (void)loadStack;
- (NSManagedObjectContext *)newConfinementContext;

@end

@interface MLCoreDataStack (MLSubclassOnly)

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator;
- (NSManagedObjectContext *)createConfinementContext;

@end

@interface MLCoreDataStack (MLNotifications)

- (void)applicationWillTerminateNotification:(NSNotification *)aNotification;
- (void)applicationWillResignActiveNotification:(NSNotification *)aNotification;

@end
