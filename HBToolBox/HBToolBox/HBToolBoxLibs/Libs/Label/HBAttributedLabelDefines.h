//
//  HBAttributedLabelDefines.h
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#ifndef HBAttributedLabelDefines_h
#define HBAttributedLabelDefines_h

#define HBRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class HBAttributedLabel;

typedef NS_OPTIONS(NSUInteger, HBImageAlignment) {
    HBImageAlignmentTop,
    HBImageAlignmentCenter,
    HBImageAlignmentBottom
};

/// 链接检测回调
typedef NSArray * _Nullable (^HBCustomDetectLinkBlock)(NSString * _Nullable text);

/// 链接点击回调
typedef void (^HBCustomLinkDidClickedBlock)(HBAttributedLabel *label, id linkData);

// 如果文本长度小于这个值,直接在主线程中检测链接，文本过长时放到后台线程检测
#define HBMinAsyncDetectLinkLength 50

NS_ASSUME_NONNULL_END

#endif /* HBttributedLabelDefines_h */
