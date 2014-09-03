//
//  MLSQLiteCoreDataStack.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLCoreDataStack.h"

@interface MLSQLiteCoreDataStack : MLCoreDataStack

@property (nonatomic, readwrite, assign) BOOL shouldDeletePersistentStoreOnModelMismatch;
@property (nonatomic, readonly, copy) NSURL * storeURL;

+ (instancetype)stackWithStoreAtPath:(NSString *)path;
+ (instancetype)stackWithStoreNamed:(NSString *)name;
+ (instancetype)stackWithStoreAtURL:(NSURL *)url;

+ (instancetype)stackWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model;
+ (instancetype)stackWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model;
+ (instancetype)stackWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model;

- (id)initWithStoreAtPath:(NSString *)path;
- (id)initWithStoreNamed:(NSString *)name;
- (id)initWithStoreAtURL:(NSURL *)url;

- (id)initWithStoreAtPath:(NSString *)path model:(NSManagedObjectModel *)model;
- (id)initWithStoreNamed:(NSString *)name model:(NSManagedObjectModel *)model;
- (id)initWithStoreAtURL:(NSURL *)url model:(NSManagedObjectModel *)model;

- (NSURL *)urlForStoreNamed:(NSString *)storeName;

@end
