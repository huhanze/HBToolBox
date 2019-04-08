//
//  UIAlertController+HBExtension.m
//  HBKit
//
//  Created by DylanHu on 2017/4/8.
//  Copyright © 2017年 DylanHu. All rights reserved.
//

#import "UIAlertController+HBExtension.h"

@implementation UIAlertController (HBExtension)

+ (void)alertWithType:(HBAlertType)type title:(nullable NSString *)title message:(nullable NSString *)message confirmed:(void (^)(void))confirmed presentInVC:(UIViewController *)presentVC {
    switch (type) {
        case HBAlertTypeConfirmAndCancel:
        {
            [self alertWithStyle:UIAlertControllerStyleAlert title:title actionTitles:@[@"取消",@"确定"] message:message handlers:@[^{},^{!confirmed ?: confirmed();}] presentInVC:presentVC];
        }
            break;
            
        default:
        {
            [self alertWithStyle:UIAlertControllerStyleAlert title:title actionTitles:@[@"确定"] message:message handlers:@[^{}] presentInVC:presentVC];
        }
            break;
    }
}

+ (void)alertWithStyle:(UIAlertControllerStyle)style title:(nullable NSString *)title actionTitles:(NSArray <NSString *>*)titles message:(nullable NSString *)message handlers:(NSArray  <AlertActionHandler> *)handlers presentInVC:(UIViewController *)presentVC {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    for (int i = 0; i < titles.count; ++i) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:titles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (handlers.count == titles.count) {
                !handlers[i] ?: handlers[i](action);
            }
        }];
        [alertVC addAction:action];
    }
    [presentVC presentViewController:alertVC animated:YES completion:nil];
}

@end
