//
//  HBDateModel.h
//  HHBKit
//
//  Created by DylanHu on 2015/10/18.
//  Copyright © 2015年 DylanHu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBDateModel : NSObject

/// 天数
@property (nonatomic, copy) NSString *day;

/// 小时
@property (nonatomic, copy) NSString *hour;

/// 分钟
@property (nonatomic, copy) NSString *minute;

/// 秒数
@property (nonatomic, copy) NSString *second;

/// 便利构造器
- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)dateModelWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
