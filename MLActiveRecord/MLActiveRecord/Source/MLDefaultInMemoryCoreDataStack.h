//
//  MLDefaultInMemoryCoreDataStack.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 04/09/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLInMemoryCoreDataStack.h"

@interface MLDefaultInMemoryCoreDataStack : MLInMemoryCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * persistentContext; // persistent store
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;       // UI updates
@property (nonatomic, readonly, strong) NSManagedObjectContext * saveContext;       // background create/update/delete

@end
