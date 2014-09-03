//
//  MLTestCase.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import <XCTest/XCTest.h>

@interface MLTestCase : XCTestCase

- (id)jsonObjectFromFilename:(NSString *)filename;

@end
