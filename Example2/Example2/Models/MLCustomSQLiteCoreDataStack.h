//
//  MLCustomSQLiteCoreDataStack.h
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLSQLiteCoreDataStack.h"

@interface MLCustomSQLiteCoreDataStack : MLSQLiteCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * savingContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * backgroundContext;

@end
