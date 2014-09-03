//
//  MLTestCase.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "MLTestCase.h"

@implementation MLTestCase

#pragma mark Accessors

- (id)jsonObjectFromFilename:(NSString *)filename {
    NSParameterAssert(filename);
    id path = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json"];
    id json = [NSData dataWithContentsOfURL:path];
    return [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
}

@end
