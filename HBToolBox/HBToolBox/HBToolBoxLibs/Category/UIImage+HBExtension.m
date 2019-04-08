//
//  UIImage+HBExtension.m
//  HBKit
//
//  Created by DylanHu on 2018/6/15.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "UIImage+HBExtension.h"
#import <objc/runtime.h>

@implementation UIImage (HBExtension)
- (NSString *)imageAssetName {
    NSString *assetName = nil;
    unsigned int count = 0;
    Ivar *members = class_copyIvarList([UIImageAsset class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = members[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(var)];
        if ([name isEqualToString:@"_assetName"]) {
            id object = object_getIvar(self.imageAsset, var);
            if ([object isKindOfClass:[NSString class]]) {
                assetName = (NSString *)object;
            }
        }
    }
    return assetName;
}

@end
