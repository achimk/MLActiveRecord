//
//  MLSavingContextSQLCoreDataStack.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "MLSQLiteCoreDataStack.h"

@interface MLSavingContextSQLCoreDataStack : MLSQLiteCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * persistentContext;
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;

@end
