//
//  MLActiveRecord.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import <Foundation/Foundation.h>

// Core Data Stacks
#import "MLCoreDataStack.h"
#import "MLCoreDataStack+ML_Saves.h"
#import "MLCoreDataStack+ML_Errors.h"
#import "MLSQLiteCoreDataStack.h"
#import "MLSavingContextSQLCoreDataStack.h"
#import "MLInMemoryCoreDataStack.h"
#import "MLSavingContextInMemoryCoreDataStack.h"

// ManagedObject Categories
#import "NSManagedObject+ML.h"
#import "NSManagedObject+ML_Finders.h"
#import "NSManagedObject+ML_Request.h"
#import "NSManagedObject+ML_Serialization.h"

// ManagedObjectContext Categories
#import "NSManagedObjectContext+ML.h"
#import "NSManagedObjectContext+ML_Saves.h"
#import "NSManagedObjectContext+ML_Observing.h"

// ManagedObjectModel Categories
#import "NSManagedObjectModel+ML.h"

// Predicate Categories
#import "NSPredicate+ML.h"

// SortDescriptor Categories
#import "NSSortDescriptor+ML.h"
