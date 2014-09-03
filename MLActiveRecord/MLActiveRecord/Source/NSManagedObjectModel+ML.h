//
//  NSManagedObjectModel+ML.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (ML)

+ (instancetype)ml_managedObjectModelAtURL:(NSURL *)anURL;
+ (instancetype)ml_managedObjectModelFromMainBundle;
+ (instancetype)ml_managedObjectModelNamed:(NSString *)modelFileName;
+ (instancetype)ml_newModelNamed:(NSString *)modelName inBundleNamed:(NSString *)bundleName NS_RETURNS_RETAINED; //todo why annotation?

@end
