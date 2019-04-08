//
//  HBAttributedLabelAttachment.h
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBAttributedLabelDefines.h"

NS_ASSUME_NONNULL_BEGIN

void deallocCallback(void *ref);
CGFloat ascentCallback(void *ref);
CGFloat descentCallback(void *ref);
CGFloat widthCallback(void *ref);

@interface HBAttributedLabelAttachment : NSObject
/// 内容
@property (nonatomic, strong) id content;
/// margin
@property (nonatomic, assign) UIEdgeInsets margin;
/// 对齐方式
@property (nonatomic, assign) HBImageAlignment alignment;
/// 字体上行高度
@property (nonatomic, assign) CGFloat fontAscent;
/// 字体下行高度
@property (nonatomic, assign) CGFloat fontDescent;
/// 字体最大size
@property (nonatomic, assign) CGSize maxSize;

/**
  HBAttributedLabelAttachment初始化方法

 @param content 内容
 @param margin margin
 @param alignment 对齐方式
 @param maxSize 文本最大size
 @return HBAttributedLabelAttachment对象
 */
+ (HBAttributedLabelAttachment *)attachmentWith:(id)content
                                          margin:(UIEdgeInsets)margin
                                       alignment:(HBImageAlignment)alignment
                                         maxSize:(CGSize)maxSize;

/**
   大小
 */
- (CGSize)boxSize;

@end


NS_ASSUME_NONNULL_END
