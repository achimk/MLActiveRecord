//
//  Artist.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "Artist.h"

#import "Image.h"
#import "MLValueTransformer.h"

@implementation Artist

@dynamic name;
@dynamic identifier;
@dynamic path;
@dynamic playcount;
@dynamic rank;
@dynamic images;

+ (NSString *)ml_entityName {
    return @"Artist";
}

#pragma mark Conforms to MLManagedObjectSerializing protocol

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{
             @"name"        : @"name",
             @"mbid"        : @"identifier",
             @"url"         : @"path",
             @"playcount"   : @"playcount",
             @"@attr"       : @"rank",
             @"image"       : @"images"
             };
}

+ (NSDictionary *)relationshipModelClassesByPropertyKey {    
    return @{
             @"image"       : [Image class]
             };
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"name"];
}

+ (NSValueTransformer *)entityAttributeTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"playcount"]) {
        return [MLValueTransformer transformerWithBlock:^(id value) {
            NSString *string = (NSString *) value;
            return (string.length) ? @(string.integerValue) : @(0);
        }];
    }
    else if ([key isEqualToString:@"@attr"]) {
        return [MLValueTransformer transformerWithBlock:^(id value) {
            NSDictionary *dictionary = (NSDictionary *) value;
            return (dictionary[@"rank"]) ? @([dictionary[@"rank"] integerValue]) : @(0);
        }];
    }
    
    return nil;
}

@end
