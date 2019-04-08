//
//  HBButton.h
//  HBKit
//
//  Created by DylanHu on 2018/6/14.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HBButtonImageAlignment) {
    HBButtonImageAlignmentDefault = 0,
    HBButtonImageAlignmentLeft = HBButtonImageAlignmentDefault,
    HBButtonImageAlignmentRight = 1,
    HBButtonImageAlignmentTop = 2,
    HBButtonImageAlignmentBottom = 3
};

@interface HBButton : UIControl

/// 标题Label, 默认字体大小 15.0
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/// title边距, 默认 [2.5, 2.5, 2.5, 2.5]
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;
/// image边距, 默认 [2.5, 2.5, 2.5, 2.5]
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
/// 图片的布局方式
@property (nonatomic, assign) HBButtonImageAlignment imageAlignment;
/// 是否总是根据内容自适应
@property (nonatomic, assign) BOOL alwaysSizeToFit;

@property (nonatomic, assign) BOOL adjustsImageWhenHighlighted;
/// 当前状态下的title
@property (nullable, nonatomic, copy, readonly) NSString *currentTitle;
/// 当前状态下的标题颜色
@property (nullable, nonatomic, strong, readonly) UIColor *currentTitleColor;
/// 当前状态下的image
@property (nullable, nonatomic, strong, readonly) UIImage *currentImage;
/// 当前状态下的背景图片UIImage对象
@property (nullable, nonatomic, strong, readonly) UIImage *currentBackGroundImage;

/**
 设置相关状态下的标题
 
 @param title 标题文本
 @param state 按钮的状态(如normal、selected、disabled、highlighted)
 */
- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state;

/**
 设置相关状态下的标题颜色
 
 @param color 标题颜色
 @param state 按钮的状态(如normal、selected、disabled、highlighted)
 */
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;

/**
 设置相关状态下的图片
 
 @param image 需要显示图片image对象
 @param state 按钮的状态(如normal、selected、disabled、highlighted)
 */
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;

/**
 设置相关状态下的背景图片image
 
 @param image 背景图片UIImage对象
 @param state 按钮的状态(如normal、selected、disabled、highlighted)
 */
- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state;

- (CGRect)imageRectForContenRect:(CGRect)contenRect;
- (CGRect)titleRectForContentRect:(CGRect)contenRect;

/**
 获取指定状态下的标题文本
 
 @param state 按钮状态
 @return 当前状态下的标题文本
 */
- (nullable NSString *)titleForState:(UIControlState)state;

/**
 获取指定状态下的标题文本颜色
 
 @param state 按钮状态
 @return 当前状态下的标题文本UIColor对象
 */
- (nullable UIColor *)titleColorForState:(UIControlState)state;

/**
 获取指定状态下的图片image
 
 @param state 按钮状态
 @return 当前状态下的图片UIImage对象
 */
- (nullable UIImage *)imageForState:(UIControlState)state;

/**
 获取指定状态下的背景图片Image
 
 @param state 按钮状态
 @return 当前状态下的背景图片UIImage对象
 */
- (nullable UIImage *)backgroundImageForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END

