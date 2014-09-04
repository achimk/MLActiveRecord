//
//  MLCustomSQLiteCoreDataStack.h
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLSQLiteCoreDataStack.h"

@interface MLCustomSQLiteCoreDataStack : MLSQLiteCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * savingContext;     // pesistent context
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;       // UI updates
@property (nonatomic, readonly, strong) NSManagedObjectContext * backgroundContext; // create / update / delete

@end
