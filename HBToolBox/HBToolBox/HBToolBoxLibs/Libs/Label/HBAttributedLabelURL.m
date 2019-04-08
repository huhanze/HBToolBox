//
//  HBAttributedLabelURL.m
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBAttributedLabelURL.h"

/// 正则表达式串
static NSString *HBURLExpression = @"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";

/// 自定义检测回调
static HBCustomDetectLinkBlock customDetectBlock = nil;

static NSString *HBURLExpressionKey = @"HBURLExpressionKey";

@implementation HBAttributedLabelURL

#pragma mark - 初始化方法
+ (HBAttributedLabelURL *)urlWithLinkData:(id)linkData
                                     range:(NSRange)range
                                     color:(UIColor *)color {
    HBAttributedLabelURL *url = [[HBAttributedLabelURL alloc] init];
    url.linkData = linkData;
    url.range = range;
    url.color = color;
    return url;
}

#pragma mark - 检测文本中的所有链接
+ (NSArray *)detectLinks:(NSString *)plainText {
    if (customDetectBlock) {
        return customDetectBlock(plainText);
    } else {
        NSMutableArray *links = nil;
        if ([plainText length]) {
            links = [NSMutableArray array];
            NSRegularExpression *urlRegex = [HBAttributedLabelURL urlExpression];
            [urlRegex enumerateMatchesInString:plainText
                                       options:0
                                         range:NSMakeRange(0, [plainText length])
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                        NSRange range = result.range;
                                        NSString *text = [plainText substringWithRange:range];
                                        HBAttributedLabelURL *link = [HBAttributedLabelURL urlWithLinkData:text
                                                                                                       range:range
                                                                                                       color:nil];
                                        [links addObject:link];
                                    }];
        }
        return links;
    }
}

+ (NSRegularExpression *)urlExpression {
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSRegularExpression *exp = dict[HBURLExpressionKey];
    if (exp == nil) {
        exp = [NSRegularExpression regularExpressionWithPattern:HBURLExpression
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
        dict[HBURLExpressionKey] = exp;
    }
    return exp;
}

+ (void)setCustomDetectMethod:(HBCustomDetectLinkBlock)block {
    customDetectBlock = [block copy];
}

@end
