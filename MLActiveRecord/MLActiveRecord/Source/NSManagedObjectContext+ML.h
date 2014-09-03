//
//  NSManagedObjectContext+ML.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 17/07/14.
//

#import <CoreData/CoreData.h>

extern NSString * const MLActiveRecordManagedObjectContextKey;

@interface NSManagedObjectContext (ML)

- (void)ml_performBlock:(void (^)())block;
- (void)ml_performBlockAndWait:(void (^)())block;

@end
