//
//  NSManagedObjectModel+ML.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 24/07/14.
//

#import "NSManagedObjectModel+ML.h"

@implementation NSManagedObjectModel (ML)

+ (instancetype)ml_managedObjectModelAtURL:(NSURL *)anURL {
    return [[self alloc] initWithContentsOfURL:anURL];
}

+ (instancetype)ml_managedObjectModelFromMainBundle {
    return [self mergedModelFromBundles:nil];
}

+ (instancetype)ml_managedObjectModelNamed:(NSString *)modelFileName {
	NSString * path = [[NSBundle mainBundle] pathForResource:[modelFileName stringByDeletingPathExtension]
                                                      ofType:[modelFileName pathExtension]];
	NSURL * momURL = [NSURL fileURLWithPath:path];
	
    return [[self alloc] initWithContentsOfURL:momURL];
}

+ (instancetype)ml_newModelNamed:(NSString *)modelName inBundleNamed:(NSString *)bundleName {
    NSString * path = [[NSBundle mainBundle] pathForResource:[modelName stringByDeletingPathExtension]
                                                      ofType:[modelName pathExtension]
                                                 inDirectory:bundleName];
    NSURL * momURL = [NSURL fileURLWithPath:path];
    
    return [[self alloc] initWithContentsOfURL:momURL];
}

@end
