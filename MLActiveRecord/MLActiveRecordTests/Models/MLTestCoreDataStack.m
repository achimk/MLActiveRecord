//
//  MLTestCoreDataStack.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "MLTestCoreDataStack.h"

@implementation MLTestCoreDataStack

+ (instancetype)stack {
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    NSManagedObjectModel * model = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:bundle]];
    
    MLTestCoreDataStack * stack = [[self alloc] initWithModel:model];
    [stack loadStack];
    
    return stack;
}

@end
