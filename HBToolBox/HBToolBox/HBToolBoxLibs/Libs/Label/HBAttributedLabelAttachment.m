//
//  HBAttributedLabelAttachment.m
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBAttributedLabelAttachment.h"


/**
 HBAttributedLabelAttachment对象释放时，回调此函数

 @param ref 调用CTRunDelegateCreate时所传入的对象，这里传入的实际上是HBAttributedLabelAttachment对象
 */
void deallocCallback(void *ref) {
    
}


/**
 CoreText中的上行高度回调

 @param ref 调用CTRunDelegateCreate时所传入的对象，这里传入的实际上是HBAttributedLabelAttachment对象
 @return 上行高度
 */
CGFloat ascentCallback(void *ref) {
    HBAttributedLabelAttachment *image = (__bridge HBAttributedLabelAttachment *)ref;
    CGFloat ascent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case HBImageAlignmentTop:
            ascent = image.fontAscent;
            break;
        case HBImageAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            ascent = height / 2 + baseLine;
        }
            break;
        case HBImageAlignmentBottom:
            ascent = height - image.fontDescent;
            break;
        default:
            break;
    }
    return ascent;
}

/**
 CoreText中的下行高度回调
 
 @param ref 调用CTRunDelegateCreate时所传入的对象，这里传入的实际上是HBAttributedLabelAttachment对象
 @return 下行高度
 */
CGFloat descentCallback(void *ref) {
    HBAttributedLabelAttachment *image = (__bridge HBAttributedLabelAttachment *)ref;
    CGFloat descent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case HBImageAlignmentTop:
        {
            descent = height - image.fontAscent;
            break;
        }
        case HBImageAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            descent = height / 2 - baseLine;
        }
            break;
        case HBImageAlignmentBottom:
        {
            descent = image.fontDescent;
            break;
        }
        default:
            break;
    }
    
    return descent;
    
}

/**
 CoreText中的宽度回调
 
 @param ref 调用CTRunDelegateCreate时所传入的对象，这里传入的实际上是HBAttributedLabelAttachment对象
 @return 宽度
 */
CGFloat widthCallback(void *ref) {
    HBAttributedLabelAttachment *image  = (__bridge HBAttributedLabelAttachment *)ref;
    return [image boxSize].width;
}

@implementation HBAttributedLabelAttachment
+ (HBAttributedLabelAttachment *)attachmentWith:(id)content
                                          margin:(UIEdgeInsets)margin
                                       alignment:(HBImageAlignment)alignment
                                         maxSize:(CGSize)maxSize {
    HBAttributedLabelAttachment *attachment = [[HBAttributedLabelAttachment alloc] init];
    attachment.content = content;
    attachment.margin = margin;
    attachment.alignment = alignment;
    attachment.maxSize = maxSize;
    return attachment;
}


- (CGSize)boxSize {
    CGSize contentSize = [self attachmentSize];
    if (_maxSize.width > 0 &&_maxSize.height > 0 &&
        contentSize.width > 0 && contentSize.height > 0) {
        contentSize = [self calculateContentSize];
    }
    return CGSizeMake(contentSize.width + _margin.left + _margin.right,
                      contentSize.height + _margin.top  + _margin.bottom);
}


#pragma mark - 辅助方法
- (CGSize)calculateContentSize {
    CGSize attachmentSize = [self attachmentSize];
    CGFloat width = attachmentSize.width;
    CGFloat height = attachmentSize.height;
    CGFloat newWidth = _maxSize.width;
    CGFloat newHeight = _maxSize.height;
    if (width <= newWidth &&
        height<= newHeight) {
        return attachmentSize;
    }
    
    CGSize size;
    if (width / height > newWidth / newHeight) {
        size = CGSizeMake(newWidth, newWidth * height / width);
    } else {
        size = CGSizeMake(newHeight * width / height, newHeight);
    }
    return size;
}

#pragma mark 计算大小
- (CGSize)attachmentSize {
    CGSize size = CGSizeZero;
    if ([_content isKindOfClass:[UIImage class]]) {
        size = [((UIImage *)_content) size];
    } else if ([_content isKindOfClass:[UIView class]]) {
        size = [((UIView *)_content) bounds].size;
    }
    return size;
}

@end
