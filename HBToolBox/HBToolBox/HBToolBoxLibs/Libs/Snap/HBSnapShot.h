//
//  HBSnapShot.h
//  HBTabView
//
//  Created by DylanHu on 2019/3/14.
//  Copyright © 2019 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBSnapShot : NSObject


/**
 获取截屏

 @return 截屏获得的UIImage对象
 */
+ (UIImage *)getImageWithSnapShot;

/**
 获取截屏，并显示在当前屏幕

 @param duration 显示时间
 @param completed 显示完成后的回调
 */
+ (void)showSnapShotViewWithDuration:(CGFloat)duration completed:(void (^ __nullable)(UIImage *image))completed;

@end

NS_ASSUME_NONNULL_END
