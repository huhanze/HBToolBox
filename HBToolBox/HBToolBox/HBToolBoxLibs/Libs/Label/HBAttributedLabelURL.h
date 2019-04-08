//
//  HBAttributedLabelURL.h
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBAttributedLabelDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBAttributedLabelURL : NSObject

/// 链接数据
@property (nonatomic, strong) id linkData;
/// 链接range
@property (nonatomic, assign) NSRange range;
/// 链接颜色
@property (nonatomic, strong, nullable) UIColor *color;

/**
   初始化方法

 @param linkData 链接数据
 @param range 范围
 @param color 颜色
 @return return  descriptionHBAttributedLabelURL对象
 */
+ (HBAttributedLabelURL *)urlWithLinkData:(id)linkData
                                     range:(NSRange)range
                                     color:(nullable UIColor *)color;

/**
   检测文本中的所有链接

 @param plainText 文本
 @return 所有链接的数组
 */
+ (nullable NSArray *)detectLinks:(nullable NSString *)plainText;

/**
  设置自定义链接检测
 
 @param block 自定义链接检测回调
 */
+ (void)setCustomDetectMethod:(nullable HBCustomDetectLinkBlock)block;

@end


NS_ASSUME_NONNULL_END
