//
//  NSString+HBPinyinString.h
//  HBKit
//
//  Created by DylanHu on 2015/9/12.
//  Copyright © 2015年 DylanHu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HBPinyinString)

/// change to pin for chinese, object changed must be a string
@property (nonatomic, copy, readonly) NSString *pinyinString;

@end
