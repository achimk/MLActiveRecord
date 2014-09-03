//
//  Image.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "Image.h"

#import "Artist.h"

@implementation Image

@dynamic path;
@dynamic size;
@dynamic artist;

+ (NSString *)ml_entityName {
    return @"Image";
}

#pragma mark Conforms to MLManagedObjectSerializing protocol

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{
             @"#text"   : @"path",
             @"size"    : @"size"
             };
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey {
    return nil;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return nil;
}


@end
