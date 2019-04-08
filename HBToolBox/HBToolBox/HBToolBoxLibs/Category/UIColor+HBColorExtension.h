//
//  UIColor+HBColorExtension.h
//  HBKit
//  UIColor扩展
//  Created by DylanHu on 2015/10/18.
//  Copyright © 2015年 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HBColorExtension)

/**
   根据十六进制色值转换对应的UIColor

 @param colorString 色值
 @return UIColor对象
 */
+ (UIColor *)hb_colorFromHexRGB:(NSString *)colorString;

/**
  获取随机颜色

 @return UIColor对象
 */
+ (UIColor *)hb_randomColor;

/**
  获取rgb状态下的颜色

 @param rgb rgb值
 @return UIColor对象
 */
+ (UIColor *)hb_colorWithRGB:(NSString* )rgb;


/**
  根据十六进制色值转换对应的UIColor

 @param colorString 色值
 @param alpha 透明度
 @return UIColor对象
 */
+ (UIColor *)hb_colorFromHexRGB:(NSString *)colorString andAlpha:(CGFloat)alpha;

@end
