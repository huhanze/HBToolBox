//
//  UIScrollView+HBExtension.m
//  HBKit
//
//  Created by DylanHu on 2015/6/20.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "UIScrollView+HBExtension.h"

@implementation UIScrollView (HBExtension)

- (void)hb_scrollToTop {
    [self hb_scrollToTopAnimated:YES];
}

- (void)hb_scrollToBottom {
    [self hb_scrollToBottomAnimated:YES];
}

- (void)hb_scrollToLeft {
    [self hb_scrollToLeftAnimated:YES];
}

- (void)hb_scrollToRight {
    [self hb_scrollToRightAnimated:YES];
}

- (void)hb_scrollToTopAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = -self.contentInset.top;
    [self setContentOffset:offset animated:animated];
}

- (void)hb_scrollToBottomAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.y = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:offset animated:animated];
}

- (void)hb_scrollToLeftAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = -self.contentInset.left;
    [self setContentOffset:offset animated:animated];
}

- (void)hb_scrollToRightAnimated:(BOOL)animated {
    CGPoint offset = self.contentOffset;
    offset.x = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:offset animated:animated];
}

@end
