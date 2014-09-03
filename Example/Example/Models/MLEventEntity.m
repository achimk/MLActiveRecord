//
//  MLEventEntity.m
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLEventEntity.h"

@implementation MLEventEntity

@dynamic identifier;
@dynamic name;
@dynamic timestamp;

+ (NSString *)ml_entityName {
    return @"EventEntity";
}

@end
