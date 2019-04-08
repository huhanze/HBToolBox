//
//  HBAttributedLabel.h
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBAttributedLabelDefines.h"
#import "NSMutableAttributedString+HBExtention.h"

NS_ASSUME_NONNULL_BEGIN

@class HBAttributedLabelURL,HBAttributedLabel;

@protocol HBAttributedLabelDelegate <NSObject>

- (void)attributedLabel:(HBAttributedLabel *)label
          clickedOnLink:(id)linkData;

@end

@interface HBAttributedLabel : UIView

@property (nonatomic, weak, nullable) id <HBAttributedLabelDelegate> delegate;
/// 文本中的链接点击回调
@property (nonatomic, copy) HBCustomLinkDidClickedBlock linkDidClickedBlock;

/// 字体
@property (nonatomic, strong, nullable) UIFont *font;
/// 文本颜色
@property (nonatomic, strong, nullable) UIColor *textColor;
/// 链接点击时背景高亮色
@property (nonatomic, strong, nullable) UIColor *highlightColor;
/// 链接颜色
@property (nonatomic, strong, nullable) UIColor *linkColor;
/// 阴影颜色
@property (nonatomic, strong, nullable) UIColor *shadowColor;
/// 阴影偏移量
@property (nonatomic, assign) CGSize shadowOffset;
/// 阴影半径
@property (nonatomic, assign) CGFloat shadowBlur;
/// 链接是否有下划线
@property (nonatomic, assign) BOOL underLineForLink;
/// 自动检测链接
@property (nonatomic, assign) BOOL autoDetectLinks;
/// 标签文本行数
@property (nonatomic, assign) NSInteger numberOfLines;
/// 文本排版样式
@property (nonatomic, assign) CTTextAlignment textAlignment;
/// LineBreakMode样式
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;
/// 文本行间距
@property (nonatomic, assign) CGFloat lineSpacing;
/// 文本段落间距
@property (nonatomic, assign) CGFloat paragraphSpacing;
/// 文本内容
@property (nonatomic, copy, nullable) NSString *text;
/// 属性文本
@property (nonatomic, copy, nullable) NSAttributedString *attributedText;

/**
  添加普通文本

 @param text 所添加的文本字符串
 */
- (void)appendText:(NSString *)text;

/**
   添加属性文本

 @param attributedText 属性文本内容
 */
- (void)appendAttributedText:(NSAttributedString *)attributedText;

/**
  添加图片

 @param image UIImage对象
 */
- (void)appendImage:(UIImage *)image;

/**
   添加图片并指定图片的大小

 @param image UIImage对象
 @param maxSize UIImage大小
 */
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize;

/**
 添加图片并指定图片的大小、间距
 
 @param image UIImage对象
 @param maxSize UIImage大小
 @param margin 间距
 */
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin;

/**
  添加图片并指定图片的大小、间距、以及对齐方式

 @param image UIImage对象
 @param maxSize UIImage大小
 @param margin 间距
 @param alignment 对齐方式
 */
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin
          alignment:(HBImageAlignment)alignment;


/**
   添加UI控件

 @param view UI控件
 */
- (void)appendView:(UIView *)view;

/**
   添加UI控件并指定间距
 
 @param view UI控件
 @param margin 间距
 */
- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin;

/**
   添加UI控件并指定间距、对齐方式
 
 @param view UI控件
 @param margin 间距
 @param alignment 对齐方式
 */
- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin
         alignment:(HBImageAlignment)alignment;

/**
   添加自定义链接

 @param linkData 链接数据
 @param range 被添加的范围
 */
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range;

/**
   添加自定义链接
 
 @param linkData 链接数据
 @param range 被添加的范围
 @param color 颜色
 */
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range
            linkColor:(UIColor *)color;

- (CGSize)sizeThatFits:(CGSize)size;

/**
  设置全局的自定义Link检测Block
 */
+ (void)setCustomDetectMethod:(nullable HBCustomDetectLinkBlock)block;

@end

NS_ASSUME_NONNULL_END
