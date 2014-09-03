//
//  MLValueTransformer.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "MLValueTransformer.h"


//
// Any MLValueTransformer supporting reverse transformation. Necessary because
// +allowsReverseTransformation is a class method.
//
@interface MLReversibleValueTransformer : MLValueTransformer
@end

@interface MLValueTransformer ()

@property (nonatomic, copy, readonly) MLValueTransformerBlock forwardBlock;
@property (nonatomic, copy, readonly) MLValueTransformerBlock reverseBlock;

@end

@implementation MLValueTransformer

#pragma mark Lifecycle

+ (instancetype)transformerWithBlock:(MLValueTransformerBlock)transformationBlock {
	return [[self alloc] initWithForwardBlock:transformationBlock reverseBlock:nil];
}

+ (instancetype)reversibleTransformerWithBlock:(MLValueTransformerBlock)transformationBlock {
	return [self reversibleTransformerWithForwardBlock:transformationBlock reverseBlock:transformationBlock];
}

+ (instancetype)reversibleTransformerWithForwardBlock:(MLValueTransformerBlock)forwardBlock reverseBlock:(MLValueTransformerBlock)reverseBlock {
	return [[MLReversibleValueTransformer alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

- (id)initWithForwardBlock:(MLValueTransformerBlock)forwardBlock reverseBlock:(MLValueTransformerBlock)reverseBlock {
	NSParameterAssert(forwardBlock != nil);
    
	self = [super init];
	if (self == nil) return nil;
    
	_forwardBlock = [forwardBlock copy];
	_reverseBlock = [reverseBlock copy];
    
	return self;
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return NO;
}

+ (Class)transformedValueClass {
	return [NSObject class];
}

- (id)transformedValue:(id)value {
	return self.forwardBlock(value);
}

@end

@implementation MLReversibleValueTransformer

#pragma mark Lifecycle

- (id)initWithForwardBlock:(MLValueTransformerBlock)forwardBlock reverseBlock:(MLValueTransformerBlock)reverseBlock {
	NSParameterAssert(reverseBlock != nil);
	return [super initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)reverseTransformedValue:(id)value {
	return self.reverseBlock(value);
}

@end

