//
//  HBUIButton.h
//  HBKit
//
//  Created by DylanHu on 2018/6/14.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HBUIButtonImageAlignment) {
    HBUIButtonImageAlignmentLeft = 0,
    HBUIButtonImageAlignmentBottom = 1,
    HBUIButtonImageAlignmentRight = 2,
    HBUIButtonImageAlignmentTop = 3,
    HBUIButtonImageAlignmentDefault = HBUIButtonImageAlignmentLeft
};

@interface HBUIButton : UIButton

@property (nonatomic, assign) HBUIButtonImageAlignment imageAlignment;

@property (nonatomic, assign) BOOL alwaysSizeToFit;

@end

NS_ASSUME_NONNULL_END
