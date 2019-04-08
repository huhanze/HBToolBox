//
//  HBDateModel.m
//  HBKit
//
//  Created by DylanHu on 2015/10/18.
//  Copyright © 2015年 DylanHu. All rights reserved.
//

#import "HBDateModel.h"

@implementation HBDateModel
#pragma mark - 初始化方法
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)dateModelWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
