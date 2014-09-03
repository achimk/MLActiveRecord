//
//  NSSortDescriptor+ML.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 21/07/14.
//

#import "NSSortDescriptor+ML.h"

#import "MLActiveRecordUtilities.h"

@implementation NSSortDescriptor (ML)

+ (NSArray *)ml_descriptors:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return @[object];
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        return [self ml_descriptorsFromArray:object];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        return [self ml_descriptorsFromString:object];
    }
    else {
        return nil;
    }
}

+ (NSArray *)ml_descriptorsFromString:(NSString *)object {
    NSParameterAssert(object);
    static NSString * const delimiter = @",";
    id objects = MLSplitStringWithPattern(object, delimiter);
    
    NSMutableArray * result = [NSMutableArray array];
    
    for (NSString * string in objects) {
        NSString * trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        id description = [self ml_createFromString:trimmed];
        
        if (description) {
            [result addObject:description];
        }
    }
    
    return (result.count) ? result : nil;
}

+ (NSArray *)ml_descriptorsFromArray:(NSArray *)object {
    NSParameterAssert(object);
    NSMutableArray * result = [NSMutableArray array];
    
    for (id item in object) {
        if ([item isKindOfClass:[self class]]) {
            [result addObject:item];
        }
        else if ([item isKindOfClass:[NSString class]]) {
            id description = [self ml_createFromString:item];
            
            if (description) {
                [result addObject:description];
            }
        }
    }
    
    return (result.count) ? result : nil;
}

+ (instancetype)ml_createFromString:(NSString *)string {
    NSParameterAssert(string);
    static NSString * const descendingKey = @"!";
    
    if (NSNotFound == [string rangeOfString:descendingKey].location) {
        return [self sortDescriptorWithKey:string ascending:YES];
    }

    string = [string stringByReplacingOccurrencesOfString:descendingKey withString:@""];
    return [self sortDescriptorWithKey:string ascending:NO];
}

@end
