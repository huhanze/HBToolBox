//
//  NSMutableAttributedString+HBExtention.m
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "NSMutableAttributedString+HBExtention.h"

@implementation NSMutableAttributedString (HBExtention)

- (void)hb_setTextColor:(UIColor *)color {
    [self hb_setTextColor:color range:NSMakeRange(0, [self length])];
}

- (void)hb_setTextColor:(UIColor *)color range:(NSRange)range {
    if (color.CGColor) {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
}


- (void)hb_setFont:(UIFont *)font {
    [self hb_setFont:font range:NSMakeRange(0, [self length])];
}

- (void)hb_setFont:(UIFont *)font range:(NSRange)range {
    if (font) {
        [self removeAttribute:(NSString *)kCTFontAttributeName range:range];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (nil != fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

- (void)hb_setUnderlineStyle:(CTUnderlineStyle)style
                     modifier:(CTUnderlineStyleModifiers)modifier {
    [self hb_setUnderlineStyle:style
                       modifier:modifier
                          range:NSMakeRange(0, self.length)];
}

- (void)hb_setUnderlineStyle:(CTUnderlineStyle)style
                     modifier:(CTUnderlineStyleModifiers)modifier
                        range:(NSRange)range {
    [self removeAttribute:(NSString *)kCTUnderlineColorAttributeName range:range];
    [self addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                 value:[NSNumber numberWithInt:(style|modifier)]
                 range:range];
}

@end
