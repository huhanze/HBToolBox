//
//  NSMutableAttributedString+HBExtention.h
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (HBExtention)

/**
 设置文本字体颜色

 @param color UIColor
 */
- (void)hb_setTextColor:(UIColor *)color;

/**
 设置文本字体颜色并指定文本范围

 @param color UIColor
 @param range 需要设置的范围
 */
- (void)hb_setTextColor:(UIColor *)color range:(NSRange)range;

/**
 设置字体

 @param font 字体
 */
- (void)hb_setFont:(UIFont *)font;

/**
 设置字体

 @param font 字体
 @param range 需要设置字体的范围
 */
- (void)hb_setFont:(UIFont *)font range:(NSRange)range;

/**
 设置下划线
 */
- (void)hb_setUnderlineStyle:(CTUnderlineStyle)style
                     modifier:(CTUnderlineStyleModifiers)modifier;

- (void)hb_setUnderlineStyle:(CTUnderlineStyle)style
                     modifier:(CTUnderlineStyleModifiers)modifier
                        range:(NSRange)range;
@end

NS_ASSUME_NONNULL_END
