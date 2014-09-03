//
//  MLActiveRecordUtilities.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "MLActiveRecordUtilities.h"

#import <objc/runtime.h>

SEL MLSelectorWithKeyPattern(NSString *key, const char *suffix) {
	NSUInteger keyLength = [key maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSUInteger suffixLength = strlen(suffix);
    
	char selector[keyLength + suffixLength + 1];
    
	BOOL success = [key getBytes:selector maxLength:keyLength usedLength:&keyLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, key.length) remainingRange:NULL];
	if (!success) return NULL;
    
	memcpy(selector + keyLength, suffix, suffixLength);
	selector[keyLength + suffixLength] = '\0';
    
	return sel_registerName(selector);
}

SEL MLSelectorWithCapitalizedKeyPattern(const char *prefix, NSString *key, const char *suffix) {
	NSUInteger prefixLength = strlen(prefix);
	NSUInteger suffixLength = strlen(suffix);
    
	NSString *initial = [key substringToIndex:1].uppercaseString;
	NSUInteger initialLength = [initial maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
	NSString *rest = [key substringFromIndex:1];
	NSUInteger restLength = [rest maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
	char selector[prefixLength + initialLength + restLength + suffixLength + 1];
	memcpy(selector, prefix, prefixLength);
    
	BOOL success = [initial getBytes:selector + prefixLength maxLength:initialLength usedLength:&initialLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, initial.length) remainingRange:NULL];
	if (!success) return NULL;
    
	success = [rest getBytes:selector + prefixLength + initialLength maxLength:restLength usedLength:&restLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, rest.length) remainingRange:NULL];
	if (!success) return NULL;
    
	memcpy(selector + prefixLength + initialLength + restLength, suffix, suffixLength);
	selector[prefixLength + initialLength + restLength + suffixLength] = '\0';
    
	return sel_registerName(selector);
}

NSArray *MLSplitStringWithPattern(NSString *string, NSString *pattern) {
    if (!pattern) {
        return [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if (![pattern length]) pattern = @"s*";
    
    NSError *error = nil;
    NSRegularExpression *rx = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                        options:0
                                                                          error:&error];
    
    NSInteger location = 0;
    id result = [NSMutableArray array];
    id matches = [rx matchesInString:string options:0 range:[string rangeOfString:string]];
    for (NSTextCheckingResult *match in matches) {
        NSRange range = NSMakeRange(location, (match.range.location - location));
        id token = [string substringWithRange:range];
        if ([token length]) [result addObject:token];
        location = match.range.location + match.range.length;
    }
    
    if (location < [string length]) {
        id token = [[string substringFromIndex:location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [result addObject:token];
    }
    
    if (![result count]) [result addObject:string];
    
    return result;
};




