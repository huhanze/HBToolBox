//
//  UIButton+HBExtension.m
//  HBKit
//
//  Created by DylanHu on 2018/6/20.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "UIButton+HBExtension.h"
#import <objc/runtime.h>

static char imageAlignmentKey;
static char keyAlwaysSizeToFit;

@implementation UIButton (HBExtension)

- (void)setImageAlignment:(HBUIButtonImageAlignment)imageAlignment {
    objc_setAssociatedObject(self, &imageAlignmentKey, @(imageAlignment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HBUIButtonImageAlignment)imageAlignment {
    id value = objc_getAssociatedObject(self, &imageAlignmentKey);
    return [((NSNumber *)value) integerValue];
}

- (void)setAlwaysSizeToFit:(BOOL)alwaysSizeToFit {
    objc_setAssociatedObject(self, &keyAlwaysSizeToFit, @(alwaysSizeToFit), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)alwaysSizeToFit {
    id value = objc_getAssociatedObject(self, &keyAlwaysSizeToFit);
    return [(NSNumber *)value boolValue];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.alwaysSizeToFit) {
        [self sizeToFit];
    }
    [self setFrameForSubviews];
}

- (void)setFrameForSubviews {
    CGSize size = self.bounds.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {return;}
    
    [self.titleLabel sizeToFit];
    if (!self.imageView.image) {
        self.imageView.image = [self imageForState:self.state];
    }
    CGSize titleSize = self.titleLabel.bounds.size;
    CGFloat titleX = self.titleEdgeInsets.left;
    CGFloat titleY = self.titleEdgeInsets.top;
    CGFloat titleWidth = titleSize.width;
    CGFloat titleHeight = titleSize.height;
    
    CGSize imageSize = self.imageView.image.size;
    CGFloat imageTop = self.imageEdgeInsets.left;
    CGFloat imageLeft = self.imageEdgeInsets.top;
    CGFloat imageWidth = MIN(imageSize.width, size.width);
    CGFloat imageHeight = MIN(imageSize.height, size.height);
    
    CGFloat whratio = imageWidth / imageHeight;
    CGFloat hwratio = imageHeight / imageWidth;
    
    HBUIButtonImageAlignment alignment = self.imageAlignment;
    if (alignment == HBUIButtonImageAlignmentLeft || alignment == HBUIButtonImageAlignmentRight) {
        if (imageWidth > imageHeight) {
            imageWidth = imageHeight * whratio;
        } else {
            imageHeight = imageWidth * hwratio;
        }
    }
    
    if (alignment == HBUIButtonImageAlignmentTop || alignment == HBUIButtonImageAlignmentBottom) {
        if (imageHeight > imageWidth) {
            imageHeight = imageWidth * hwratio;
        } else {
            imageWidth = imageHeight * hwratio;
        }
    }
    
    switch (alignment) {
        case HBUIButtonImageAlignmentLeft:
        {
            imageTop = (size.height - imageHeight) * 0.5;
            titleX = imageWidth + self.imageEdgeInsets.left + self.imageEdgeInsets.right + self.titleEdgeInsets.left * 0.5;
            titleY = (size.height - titleHeight) * 0.5;
            titleWidth = size.width - titleX - self.titleEdgeInsets.right;
        }
            break;
        case HBUIButtonImageAlignmentBottom:
        {
            imageTop = size.height - imageHeight - self.imageEdgeInsets.bottom;
            imageLeft = (size.width - imageWidth) * 0.5;
            titleY = (size.height - imageHeight - self.imageEdgeInsets.bottom -  titleHeight) * 0.5 ;
            titleWidth = titleWidth > size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right ? size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right : titleWidth;
            titleHeight = titleHeight < size.height - imageHeight - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom ? titleHeight : size.height - imageHeight - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom;
            
        }
            break;
        case HBUIButtonImageAlignmentRight:
        {
            imageLeft = size.width - imageWidth - self.imageEdgeInsets.right;
            imageTop = (size.height - imageHeight) * 0.5;
            
            titleY = (size.height - titleHeight) * 0.5;
            titleWidth = size.width - imageWidth - self.titleEdgeInsets.right;
        }
            break;
        case HBUIButtonImageAlignmentTop:
        {
            imageLeft = (size.width - imageWidth) * 0.5;
            titleY = (size.height - imageHeight - self.imageEdgeInsets.top - self.titleEdgeInsets.top - self.imageEdgeInsets.bottom - titleHeight - self.titleEdgeInsets.bottom) * 0.5 + imageHeight + self.imageEdgeInsets.top + self.imageEdgeInsets.bottom;
            titleWidth = titleWidth > size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right ? size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right : titleWidth;
            titleHeight = titleHeight < size.height - imageHeight - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom ? titleHeight : size.height - imageHeight - self.imageEdgeInsets.top - self.imageEdgeInsets.bottom - self.titleEdgeInsets.top - self.titleEdgeInsets.bottom;
        }
            break;
        default:
            break;
    }
    
    if (self.imageView.image) {
        self.imageView.frame = CGRectMake(imageLeft, imageTop, imageWidth, imageHeight);
    }
    if (self.titleLabel) {
        self.titleLabel.frame = CGRectMake(titleX, titleY, titleWidth, titleHeight);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.imageView.image) {
        self.imageView.image = [self imageForState:self.state];
    }
    CGSize imageSize = self.imageView.image.size;
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    CGImageRef backGroundImage = NULL;
    CGSize backGroundImageSize = CGSizeZero;
    if (self.layer.contents) {
        backGroundImage = (__bridge CGImageRef)self.layer.contents;
        backGroundImageSize = CGSizeMake(CGImageGetWidth(backGroundImage), CGImageGetHeight(backGroundImage));
    }
    
    [self.titleLabel sizeToFit];
    CGSize titleSize = self.titleLabel.bounds.size;
    
    switch (self.imageAlignment) {
        case HBUIButtonImageAlignmentLeft:
        case HBUIButtonImageAlignmentRight:
        {
            maxWidth = self.imageEdgeInsets.left + imageSize.width + self.imageEdgeInsets.right + self.titleEdgeInsets.left + titleSize.width + self.titleEdgeInsets.right;
            maxHeight = MAX(imageSize.height, titleSize.height) + MAX(self.imageEdgeInsets.top + self.imageEdgeInsets.bottom, self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
        }
            break;
        case HBUIButtonImageAlignmentTop:
        case HBUIButtonImageAlignmentBottom:
        {
            maxWidth = MAX(imageSize.width, titleSize.width) + MAX(self.imageEdgeInsets.left + self.imageEdgeInsets.right, self.titleEdgeInsets.left + self.titleEdgeInsets.right);
            maxHeight = self.imageEdgeInsets.top + imageSize.height + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top + titleSize.height + self.titleEdgeInsets.bottom;
        }
            break;
        default:
            break;
    }
    
    maxWidth = maxWidth >= backGroundImageSize.width ? maxWidth : backGroundImageSize.width;
    maxHeight = maxHeight >= backGroundImageSize.height ? maxHeight : backGroundImageSize.height;
    return CGSizeMake(maxWidth,maxHeight);
}

@end
