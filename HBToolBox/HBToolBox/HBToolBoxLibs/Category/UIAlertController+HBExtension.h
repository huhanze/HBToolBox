//
//  UIAlertController+HBExtension.h
//  HBKit
//
//  Created by DylanHu on 2017/4/8.
//  Copyright © 2017年 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AlertActionHandler)(UIAlertAction * _Nonnull action);

typedef NS_ENUM(NSUInteger, HBAlertType) {
    HBAlertTypeConfirm = 0,
    HBAlertTypeConfirmAndCancel,
};
@interface UIAlertController (HBExtension)

/**
 快速创建 UIAlertController弹窗 alert风格
 
 @param type --- 2种类型 type == HBAlertTypeConfirm 时，只有action为确定的弹窗，type == HBAlertTypeConfirmAndCancel时  action为 确定 - 取消
 @param title 标题
 @param message 消息
 @param confirmed 点击确认后的回调
 @param presentVC 栈顶控制器
 */
+ (void)alertWithType:(HBAlertType)type
                title:(nullable NSString *)title
              message:(nullable NSString *)message
            confirmed:(void (^)(void))confirmed
          presentInVC:(UIViewController *)presentVC;


/**
 快速创建 UIAlertController弹窗
 
 @param style UIAlertControllerStyle 弹窗样式
 @param title 标题
 @param titles action的标题，可以传一组action
 @param message 消息
 @param handlers actions的回调事件，如@[^{},^(UIAlertAction *action){},...]
 @param presentVC 栈顶控制器
 
 @discussion 注意: actionTitle的数量要和actionHandler的数量保持一致,
 如：titles : @[@"取消",@"确定"]，handlers：@[^{},^{}]
 */
+ (void)alertWithStyle:(UIAlertControllerStyle)style
                 title:(nullable NSString *)title
          actionTitles:(NSArray <NSString *>*)titles
               message:(nullable NSString *)message
              handlers:(NSArray <AlertActionHandler> *)handlers
           presentInVC:(UIViewController *)presentVC;

@end

NS_ASSUME_NONNULL_END
