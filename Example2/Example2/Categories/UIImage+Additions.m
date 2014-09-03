//
//  UIImage+Additions.m
//  Example2
//
//  Created by Joachim Kret on 05.08.2014.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)ml_imageWithColor:(UIColor *)color {
    return [self ml_imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)ml_imageWithColor:(UIColor *)color size:(CGSize)size {
    NSParameterAssert(color);
    NSAssert1(size.width && size.height, @"Invalid image size: %@", NSStringFromCGSize(size));
    
    CGRect rect = CGRectZero;
    rect.size = size;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)ml_imageNamed:(NSString *)name bundleName:(NSString *)bundleName {
    if (!bundleName) {
        return [UIImage imageNamed:name];
    }
    
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * bundlePath = [resourcePath stringByAppendingPathComponent:bundleName];
    NSString * imagePath = [bundlePath stringByAppendingPathComponent:name];
    return [UIImage imageNamed:imagePath];
}

@end
