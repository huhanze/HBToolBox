//
//  NSDate+HBDateExtension.m
//  HBKit
//  日期格式化扩展
//  Created by DylanHu on 2015/10/18.
//  Copyright © 2015年 DylanHu. All rights reserved.
//

#import "NSDate+HBDateExtension.h"
#import "HBDateModel.h"

HBCommonDateFormatStr const commonDateFormatStrDefault = @"yyyy-MM-dd HH:mm:ss";
HBCommonDateFormatStr const commonDateFormatStrContainsYearMonthDayOnly = @"yyyy-MM-dd";
HBCommonDateFormatStr const commonDateFormatStrContainsYearMonthOnly = @"yyyy-MM";
HBCommonDateFormatStr const commonDateFormatStrContainsMonthDayOnly = @"MM-dd";
HBCommonDateFormatStr const commonDateFormatStrWithoutSeconds = @"yyyy-MM-dd HH:mm";
HBCommonDateFormatStr const commonDateFormatStrWithoutYearAndSeconds = @"MM-dd HH:mm";

@implementation NSDate (HBDateExtension)

#pragma mark - 精确到秒（xx天xx小时xx分xx秒）
+ (NSString *)hb_timeformatAccurateSecondWithSeconds:(long long)seconds {
    
    // 天
    NSString *strDay = [NSString stringWithFormat:@"%lld",seconds/(86400)];
    
    // 小时
    NSString *strHour = [NSString stringWithFormat:@"%02lld",(seconds%86400)/3600];
    
    // 分
    NSString *strMinute = [NSString stringWithFormat:@"%02lld",(seconds%3600)/60];
    
    // 秒
    NSString *strSecond = [NSString stringWithFormat:@"%02lld",seconds%60];
    
    // 拼接时间字符串
    NSString *formatTime = [NSString stringWithFormat:@"%@天%@小时%@分%@秒",strDay,strHour,strMinute,strSecond];
    return formatTime;
    
}

#pragma mark - 精确到分
+ (NSString *)hb_timeformatAccurateMinuteWithSeconds:(long long)seconds {
    
    // 天
    NSString *strDay = [NSString stringWithFormat:@"%lld",seconds/(86400)];
    
    // 小时
    NSString *strHour = [NSString stringWithFormat:@"%02lld",(seconds%86400)/3600];
    
    // 分
    NSString *strMinute = [NSString stringWithFormat:@"%02lld",(seconds%3600)/60];
    
    // 拼接时间字符串
    NSString *formatTime = [NSString stringWithFormat:@"%@天%@小时%@分",strDay,strHour,strMinute];
    return formatTime;
    
}

#pragma mark - 获取当前日期(字符串格式化)
+ (NSString *)hb_getCurrentDate {
    return [self hb_getCurrentDateWithDateFormatString:[NSString stringWithFormat:@"yyyy-MM-dd HH:mm:ss"]];
}

+ (NSString *)hb_getCurrentDateWithDateFormatString:(NSString *)formatString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

+ (NSString *)hb_getMonthAndDayWithDate:(NSDate *)date dateFormat:(NSString *)dateFormatStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatStr];
    NSTimeZone* zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    NSString *currentDateStr = [formatter stringFromDate:date];
    return currentDateStr;
}

+ (NSString *)hb_getMonthAndDayWithTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormatStr {
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval / 1000];
    return [self hb_getMonthAndDayWithDate:date dateFormat:dateFormatStr].copy;
}

+ (HBDateModel *)hb_timeformatWithSeconds:(long long)seconds {
    
    // 天
    NSString *strDay = [NSString stringWithFormat:@"%lld",seconds / (86400)];
    
    // 小时
    NSString *strHour = [NSString stringWithFormat:@"%02lld",(seconds % 86400) / 3600];
    
    // 分
    NSString *strMinute = [NSString stringWithFormat:@"%02lld",(seconds % 3600) / 60];
    
    // 秒
    NSString *strSecond = [NSString stringWithFormat:@"%02lld",seconds % 60];
    
    NSDictionary *timeDict = @{@"day":strDay,@"hour":strHour,@"minute":strMinute,@"second":strSecond};
    
    return [HBDateModel dateModelWithDictionary:timeDict];
}

@end
