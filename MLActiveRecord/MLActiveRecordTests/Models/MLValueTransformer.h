//
//  MLValueTransformer.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import <Foundation/Foundation.h>

/*
 *  Implementation from Mantle github project:
 *  https://github.com/Mantle/Mantle/blob/master/Mantle/MTLValueTransformer.h
 */

typedef id (^MLValueTransformerBlock)(id);

//
// A value transformer supporting block-based transformation.
//
@interface MLValueTransformer : NSValueTransformer

// Returns a transformer which transforms values using the given block. Reverse
// transformations will not be allowed.
+ (instancetype)transformerWithBlock:(MLValueTransformerBlock)transformationBlock;

// Returns a transformer which transforms values using the given block, for
// forward or reverse transformations.
+ (instancetype)reversibleTransformerWithBlock:(MLValueTransformerBlock)transformationBlock;

// Returns a transformer which transforms values using the given blocks.
+ (instancetype)reversibleTransformerWithForwardBlock:(MLValueTransformerBlock)forwardBlock reverseBlock:(MLValueTransformerBlock)reverseBlock;

@end
