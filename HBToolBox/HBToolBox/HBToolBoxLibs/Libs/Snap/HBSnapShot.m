//
//  HBSnapShot.m
//  HBTabView
//
//  Created by DylanHu on 2019/3/14.
//  Copyright © 2019 DylanHu. All rights reserved.
//

#import "HBSnapShot.h"
#import "HBSnapShotView.h"
#import "UIView+HBExtension.h"

@implementation HBSnapShot


/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
+ (NSData *)dataWithSnapShotForPNGFormat {
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

#pragma mark 获取截屏图片
+ (UIImage *)getImageWithSnapShot {
    NSData *imageData = [self dataWithSnapShotForPNGFormat];
    return [UIImage imageWithData:imageData];
}

#pragma mark 将UIView转换成UIImage对象
+ (UIImage *)getImageWithView:(UIView *)view opaque:(BOOL)opaque {
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, opaque,[UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)showSnapShotViewWithDuration:(CGFloat)duration completed:(void (^ __nullable)(UIImage *image))completed {
    [self showSnapShotViewWithImage:[self getImageWithSnapShot] duration:duration completed:completed];
}

+ (void)showSnapShotViewWithImage:(UIImage *)image duration:(CGFloat)duration completed:(void (^ __nullable)(UIImage *image))completed {
    HBSnapShotView *snapShotView = [HBSnapShotView snapShotViewWithImage:image];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow.subviews.lastObject addSubview:snapShotView];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imageShowSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.8, [UIScreen mainScreen].bounds.size.height * 0.8);
    snapShotView.frame = CGRectMake((screenSize.width - imageShowSize.width) * 0.5,(screenSize.height - imageShowSize.height) * 0.5 , imageShowSize.width, imageShowSize.height);
    snapShotView.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        snapShotView.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                snapShotView.frame = CGRectMake(snapShotView.frame.origin.x, screenSize.height - snapShotView.frame.origin.x - imageShowSize.height * 0.3, imageShowSize.width * 0.3, imageShowSize.height * 0.3);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration animations:^{
                    snapShotView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [snapShotView removeFromSuperview];
                    !completed ?: completed(image);
                }];
            }];
        });
    }];
}

@end
