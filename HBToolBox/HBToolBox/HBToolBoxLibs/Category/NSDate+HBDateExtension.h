//
//  NSDate+HBDateExtension.h
//  HBKit
//  日期格式化扩展
//  Created by DylanHu on 2015/10/18.
//  Copyright © 2015年 DylanHu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HBDateExtension)
/**
 *  根据秒数转换为天、小时、分、秒
 *
 *  @param seconds 总秒数
 *
 *  @return （XX天XX小时XX分XX秒）
 */
+ (NSString *)hb_timeformatAccurateSecondWithSeconds:(long long)seconds;

/**
 *  根据秒数转换为天、小时、分
 *
 *  @param seconds 总秒数
 *
 *  @return （XX天XX小时XX分）
 */
+ (NSString *)hb_timeformatAccurateMinuteWithSeconds:(long long)seconds;

/**
 获取当前日期
 @return 当前日期格式化字符串 (yy-MM-dd HH:mm:ss)
 */
+ (NSString *)hb_getCurrentDate;

/**
 以特定的格式获取当前日期
 @param formatString 日期显示格式
 @return 当前日期格式化字符串
 */
+ (NSString *)hb_getCurrentDateWithDateFormatString:(NSString *)formatString;

/**
 获取特定格式的日期
 
 @param date 被转换的NSDate对象
 @param dateFormatStr 日期格式化字符串
 @return 相应格式的字符串日期
 */
+ (NSString *)hb_getMonthAndDayWithDate:(NSDate *)date dateFormat:(NSString *)dateFormatStr;

/**
 获取特定格式的日期
 
 @param timeInterval timeInterval
 @param dateFormatStr 日期格式化字符串
 @return 相应格式的字符串日期
 */
+ (NSString *)hb_getMonthAndDayWithTimeInterval:(NSTimeInterval)timeInterval dateFormat:(NSString *)dateFormatStr;

@end

typedef NSString * HBCommonDateFormatStr;

/* 常用日期格式化样式 */
FOUNDATION_EXTERN HBCommonDateFormatStr const commonDateFormatStrDefault; // yyyy-MM-dd HH:mm:ss
FOUNDATION_EXTERN HBCommonDateFormatStr const commonDateFormatStrContainsYearMonthDayOnly; // yyyy-MM-dd
FOUNDATION_EXTERN HBCommonDateFormatStr const commonDateFormatStrContainsYearMonthOnly; // yyyy-MM
FOUNDATION_EXTERN HBCommonDateFormatStr const commonDateFormatStrContainsMonthDayOnly; // MM-dd
FOUNDATION_EXTERN HBCommonDateFormatStr const commonDateFormatStrWithoutSeconds;    // yyyy-MM-dd HH:mm
FOUNDATION_EXTERN HBCommonDateFormatStr const commonDateFormatStrWithoutYearAndSeconds;  // MM-dd HH:mm
