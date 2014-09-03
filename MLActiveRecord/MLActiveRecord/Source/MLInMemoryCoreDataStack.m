//
//  MLInMemoryCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLInMemoryCoreDataStack.h"

#import "MLCoreDataStack+ML_Errors.h"

@implementation MLInMemoryCoreDataStack

+ (instancetype)stackWithModel:(NSManagedObjectModel *)model {
    return [[self alloc] initWithModel:model];
}

#pragma mark Init

- (id)initWithModel:(NSManagedObjectModel *)model {
    if (self = [super init]) {
        _managedObjectModel = model;
    }
    
    return self;
}

#pragma mark Subclass Methods

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator {
    NSManagedObjectModel * model = self.managedObjectModel;
    NSPersistentStoreCoordinator * coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    if (coordinator) {
        NSError * error = nil;
        NSDictionary * options = self.storeOptions;
        [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error];
        
        if (error) {
            [MLCoreDataStack handleErrors:error];
        }
    }
    
    return coordinator;
}

@end
