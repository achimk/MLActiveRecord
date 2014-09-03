//
//  NSPredicate+ML.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 21/07/14.
//

#import "NSPredicate+ML.h"

@implementation NSPredicate (ML)

+ (instancetype)ml_condition:(id)condition {
    if ([condition isKindOfClass:[self class]]) {
        return condition;
    }
    else if ([condition isKindOfClass:[NSString class]]) {
        return [self predicateWithFormat:condition];
    }
    else if ([condition isKindOfClass:[NSDictionary class]]) {
        NSMutableArray * items = [NSMutableArray array];
        [condition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [items addObject:[NSPredicate predicateWithFormat:@"%K == %@", key, obj]];
        }];
        
        return [NSCompoundPredicate andPredicateWithSubpredicates:items];
    }
    else {
        return nil;
    }
}

@end
