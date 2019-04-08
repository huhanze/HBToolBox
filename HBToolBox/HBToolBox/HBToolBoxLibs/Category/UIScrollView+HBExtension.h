//
//  UIScrollView+HBExtension.h
//  HBKit
//
//  Created by DylanHu on 2015/6/20.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (HBExtension)

/**
   滚动内容到顶部
 */
- (void)hb_scrollToTop;

/**
 滚动内容到底部
 */
- (void)hb_scrollToBottom;

/**
 滚动内容到最左端
 */
- (void)hb_scrollToLeft;

/**
 滚动内容到最右端
 */
- (void)hb_scrollToRight;

/**
 滚动内容到顶部

 @param animated 是否使用动画
 */
- (void)hb_scrollToTopAnimated:(BOOL)animated;

/**
 滚动内容到底部
 
 @param animated 是否使用动画
 */
- (void)hb_scrollToBottomAnimated:(BOOL)animated;

/**
 滚动内容到最左端
 
 @param animated 是否使用动画
 */
- (void)hb_scrollToLeftAnimated:(BOOL)animated;

/**
 滚动内容到最右端
 
 @param animated 是否使用动画
 */
- (void)hb_scrollToRightAnimated:(BOOL)animated;

@end
