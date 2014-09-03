//
//  MLActiveRecordUtilities.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import <Foundation/Foundation.h>

/*
 *  Implementation from Mantle github project:
 *  https://github.com/Mantle/Mantle/blob/master/Mantle/MTLReflection.h
 */

// Creates a selector from a key and a constant string.
//
// key    - The key to insert into the generated selector. This key should be in
//          its natural case.
// suffix - A string to append to the key as part of the selector.
//
// Returns a selector, or NULL if the input strings cannot form a valid
// selector.
SEL MLSelectorWithKeyPattern(NSString *key, const char *suffix) __attribute__((pure, nonnull(1, 2)));

// Creates a selector from a key and a constant prefix and suffix.
//
// prefix - A string to prepend to the key as part of the selector.
// key    - The key to insert into the generated selector. This key should be in
//          its natural case, and will have its first letter capitalized when
//          inserted.
// suffix - A string to append to the key as part of the selector.
//
// Returns a selector, or NULL if the input strings cannot form a valid
// selector.
SEL MLSelectorWithCapitalizedKeyPattern(const char *prefix, NSString *key, const char *suffix) __attribute__((pure, nonnull(1, 2, 3)));

/*
 *  Utility methods from:
 *  https://github.com/michalkonturek/RubySugar/tree/master/Source
 */
NSArray *MLSplitStringWithPattern(NSString *string, NSString *pattern);
