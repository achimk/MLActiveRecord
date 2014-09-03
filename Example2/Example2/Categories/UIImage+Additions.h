//
//  UIImage+Additions.h
//  Example2
//
//  Created by Joachim Kret on 05.08.2014.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (UIImage *)ml_imageWithColor:(UIColor *)color;
+ (UIImage *)ml_imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)ml_imageNamed:(NSString *)name bundleName:(NSString *)bundleName;

@end
