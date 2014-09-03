//
//  NSManagedObjectContext+ML_Observing.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (ML_Observing)

- (void)ml_observeContextDidSave:(NSManagedObjectContext *)otherContext;
- (void)ml_observeContextDidSaveOnMainThread:(NSManagedObjectContext *)otherContext;
- (void)ml_stopObservingContextDidSave:(NSManagedObjectContext *)otherContext;

@end
