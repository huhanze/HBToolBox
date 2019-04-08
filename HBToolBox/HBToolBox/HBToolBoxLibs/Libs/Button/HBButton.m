//
//  HBButton.m
//  HBKit
//
//  Created by DylanHu on 2018/6/14.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBButton.h"
#import <objc/runtime.h>

typedef NSString * const HBContolStateKey;

HBContolStateKey kControlNormalKey = @"normal";
HBContolStateKey kControlSelectedKey = @"selected";
HBContolStateKey kControlHighlightedKey = @"highlighted";
HBContolStateKey kControlDisabledKey = @"disabled";

@interface UIImage(HBExtension)

- (NSString *)imageAssetName;

@end

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

static CIContext *_context;
@interface HBButton () {
    CIFilter *_filter;
}
/// 标题Label
@property (nonatomic, strong) UILabel *titleLabel;
/// 显示图片的图层
@property (nonatomic, strong) CALayer *imageLayer;
/// 控件状态
@property (nonatomic, assign) UIControlState controlState;
/// 存储不同ControlState下的title
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *titleAttributesInfo;
/// 存储不同ControlState下的titleColor
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIColor *> *titleColors;
/// 当前状态下的标题
@property (nonatomic, copy) NSString *currentTitle;
/// 当前状态下的标题颜色
@property (nonatomic, strong) UIColor *currentTitleColor;
/// 当前状态下的image
@property (nonatomic, strong) UIImage *currentImage;
/// 当前状态下的背景图片UIImage对象
@property (nonatomic, strong) UIImage *currentBackGroundImage;
/// 存储不同状态下的图片
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *imageAssetNames;
/// 存储不同状态下的背景图片
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *backGroundImageAssetNames;
/// 是否是selected状态
@property (nonatomic, assign) BOOL itemSelected;
/// 是否可交互
@property (nonatomic, assign) BOOL itemEnable;
/// image的scale
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) BOOL touched;

@end

@implementation HBButton

- (instancetype)init {
    if (self = [super init]) {
        [self commonInitial];
    }
    return self;
}

- (void)commonInitial {
    _controlState = UIControlStateNormal;
    _titleEdgeInsets = UIEdgeInsetsMake(2.5, 2.5, 2.5, 2.5);
    _imageEdgeInsets = _titleEdgeInsets;
    _itemEnable = YES;
    _scale = [UIScreen mainScreen].scale;
    _adjustsImageWhenHighlighted = YES;
    _context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
    _filter = [CIFilter filterWithName:@"CIColorControls"];
}

#pragma mark - Properties
#pragma mark 存储不同state下的title
- (NSMutableDictionary <NSString *, NSString *> *)titleAttributesInfo {
    if (!_titleAttributesInfo) {
        _titleAttributesInfo = @{}.mutableCopy;
    }
    return _titleAttributesInfo;
}

#pragma mark 存储不同state下的titleColor
- (NSMutableDictionary<NSString *,UIColor *> *)titleColors {
    if (!_titleColors) {
        _titleColors = @{@"normal":[UIColor blackColor]}.mutableCopy;
    }
    return _titleColors;
}

#pragma mark 存储不同state下的imageAssetName
- (NSMutableDictionary<NSString *,NSString *> *)imageAssetNames {
    if (!_imageAssetNames) {
        _imageAssetNames = @{}.mutableCopy;
    }
    return _imageAssetNames;
}

#pragma mark 存储不同state下的backGroundImageAssetName
- (NSMutableDictionary<NSString *,NSString *> *)backGroundImageAssetNames {
    if (!_backGroundImageAssetNames) {
        _backGroundImageAssetNames = @{}.mutableCopy;
    }
    return _backGroundImageAssetNames;
}

#pragma mark 显示标题的UILable
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    if (![self.subviews containsObject:_titleLabel]) {
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

#pragma mark 获取当前状态下的title
- (nullable NSString *)currentTitle {
    if ([self.titleAttributesInfo.allKeys containsObject:[self _getCurrentStateKey]]) {
        return [self.titleAttributesInfo objectForKey:[self _getCurrentStateKey]];
    }
    return nil;
}

- (nullable UIColor *)currentTitleColor {
    if ([self.titleColors.allKeys containsObject:[self _getCurrentStateKey]]) {
        return [self.titleColors objectForKey:[self _getCurrentStateKey]];
    }
    return nil;
}

- (nullable UIImage *)currentImage {
    if ([self.imageAssetNames.allKeys containsObject:[self _getCurrentStateKey]]) {
        return [UIImage imageNamed:[self.imageAssetNames objectForKey:[self _getCurrentStateKey]]];
    }
    return nil;
}

- (nullable UIImage *)currentBackGroundImage {
    if ([self.backGroundImageAssetNames.allKeys containsObject:[self _getCurrentStateKey]]) {
        return [UIImage imageNamed:[self.backGroundImageAssetNames objectForKey:[self _getCurrentStateKey]]];
    }
    return nil;
}

#pragma mark imageLayer - 显示图片的CALayer
/*
 图片不涉及交互，所以这里用CALayer来替代原生UIButton中的UIImageView
 */
- (CALayer *)imageLayer {
    if (!_imageLayer) {
        _imageLayer = [[CALayer alloc] init];
    }
    if (![self.layer.sublayers containsObject:_imageLayer]) {
        [self.layer addSublayer:_imageLayer];
    }
    return _imageLayer;
}

#pragma mark 设置图片布局样式
- (void)setImageAlignment:(HBButtonImageAlignment)imageAlignment {
    _imageAlignment = imageAlignment;
    [self setFramesForSubViews];
}

#pragma mark 是否总是根据内容的大小自适应
- (void)setAlwaysSizeToFit:(BOOL)alwaysSizeToFit {
    _alwaysSizeToFit = alwaysSizeToFit;
    if (alwaysSizeToFit) {
        [self sizeToFit];
    }
}

#pragma mark 设置title的边距
- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    _titleEdgeInsets = titleEdgeInsets;
}

#pragma mark 设置图片的边距
- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    _imageEdgeInsets = imageEdgeInsets;
}

#pragma mark 设置selected状态
- (void)setSelected:(BOOL)selected {
    self.controlState = selected ? UIControlStateSelected : UIControlStateNormal;
    self.itemSelected = selected;
    if (self.alwaysSizeToFit) {
        [self sizeToFit];
    }
}

- (BOOL)isSelected {
    return self.itemSelected;
}

#pragma mark 设置enable状态
- (BOOL)isEnabled {
    return self.itemEnable;
}

- (void)setEnabled:(BOOL)enabled {
    self.controlState = enabled ? UIControlStateNormal : UIControlStateDisabled;
    self.itemEnable = enabled;
    if (self.alwaysSizeToFit) {
        [self sizeToFit];
    }
}

#pragma mark 设置controlState
- (void)setControlState:(UIControlState)controlState {
    _controlState = controlState;
    NSString *key = [self _getControlStateKeyWithState:controlState];
    if ([self.titleAttributesInfo.allKeys containsObject:key]) {
        self.titleLabel.text = [self.titleAttributesInfo objectForKey:key];
    }
    
    if ([self.titleColors.allKeys containsObject:key]) {
        self.titleLabel.textColor = [self.titleColors objectForKey:key];
    } else {
        self.titleLabel.textColor = [UIColor clearColor];
    }
    [self _setBackGroundImageWithState:controlState];
    [self setFramesForSubViews];
}

- (UIControlState)state {
    return self.controlState;
}

#pragma mark 重写frame
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setFramesForSubViews];
}

- (void)setAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted {
    _adjustsImageWhenHighlighted = adjustsImageWhenHighlighted;
}

#pragma mark - 设置标题属性
#pragma mark 设置state下的title
- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state {
    if (!title || !title.length) return;
    [self.titleAttributesInfo setValue:title forKey:[self _getControlStateKeyWithState:state]];
    if (self.state == state) {
        [self setFramesForSubViews];
    }
}

#pragma mark 设置state下的titleColor
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state {
    if (!color) return;
    [self.titleColors setValue:color forKey:[self _getControlStateKeyWithState:state]];
    if (self.state == state) {
        self.titleLabel.textColor = color;
    }
}

#pragma mark - 设置图片
#pragma mark 设置state下的图片
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state {
    if (!image) return;
    [self .imageAssetNames setValue:image.imageAssetName forKey:[self _getControlStateKeyWithState:state]];
    if (self.state == state) {
        [self setFramesForSubViews];
    }
}

#pragma mark 设置背景图片
- (void)setBackgroundImage:(nullable UIImage *)image forState:(UIControlState)state {
    if (!image) return;
    [self.backGroundImageAssetNames setValue:image.imageAssetName forKey:[self _getControlStateKeyWithState:state]];
    if (state == self.state) {
        [self _setBackGroundImageWithState:state];
    }
}

#pragma mark - 内容相关frame设置
#pragma mark 重写自适应大小
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize imageSize = CGSizeZero;
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    CGImageRef image = (__bridge CGImageRef) self.imageLayer.contents;
    imageSize = CGSizeMake(CGImageGetWidth(image) / self.scale, CGImageGetHeight(image) / self.scale);
    CGImageRef backGroundImage = NULL;
    CGSize backGroundImageSize = CGSizeZero;
    if (self.layer.contents) {
        backGroundImage = (__bridge CGImageRef)self.layer.contents;
        backGroundImageSize = CGSizeMake(CGImageGetWidth(backGroundImage), CGImageGetHeight(backGroundImage));
    }
    
    [self.titleLabel sizeToFit];
    CGSize titleSize = self.titleLabel.bounds.size;
    
    switch (self.imageAlignment) {
        case HBButtonImageAlignmentLeft:
        case HBButtonImageAlignmentRight:
        {
            maxWidth = self.imageEdgeInsets.left + imageSize.width + self.imageEdgeInsets.right + self.titleEdgeInsets.left + titleSize.width + self.titleEdgeInsets.right;
            maxHeight = MAX(imageSize.height, titleSize.height) + MAX(self.imageEdgeInsets.top + self.imageEdgeInsets.bottom, self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
        }
            break;
        case HBButtonImageAlignmentTop:
        case HBButtonImageAlignmentBottom:
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

- (CGRect)imageRectForContenRect:(CGRect)contenRect {
    self.imageLayer.frame = contenRect;
    return contenRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contenRect {
    self.titleLabel.frame = contenRect;
    return contenRect;
}

#pragma mark 计算图片的frame
- (CGRect)caculatedImageFrame:(CGRect)frame {
    CGSize size = frame.size;
    CGFloat imageLeft = self.imageEdgeInsets.left;
    CGFloat imageTop = self.imageEdgeInsets.top;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    if (!self.imageLayer.contents) {
        return CGRectZero;
    }
    
    CGImageRef image = (__bridge CGImageRef)(self.imageLayer.contents);
    imageWidth = CGImageGetWidth(image) / self.scale;
    imageHeight = CGImageGetHeight(image) / self.scale;
    CGFloat whratio = imageWidth / imageHeight;
    CGFloat hwratio = imageHeight / imageWidth;
    
    
    if (self.imageAlignment == HBButtonImageAlignmentLeft || self.imageAlignment == HBButtonImageAlignmentRight) {
        if (imageWidth > imageHeight) {
            imageWidth = imageHeight * whratio;
        } else {
            imageHeight = imageWidth * hwratio;
        }
    }
    
    if (self.imageAlignment == HBButtonImageAlignmentTop || self.imageAlignment == HBButtonImageAlignmentBottom) {
        if (imageHeight > imageWidth) {
            imageHeight = imageWidth * hwratio;
        } else {
            imageWidth = imageHeight * hwratio;
        }
    }
    
    switch (self.imageAlignment) {
        case HBButtonImageAlignmentLeft:
        {
            imageTop = (size.height - imageHeight) * 0.5;
        }
            break;
        case HBButtonImageAlignmentTop:
        {
            imageLeft = (size.width - imageWidth) * 0.5;
        }
            break;
        case HBButtonImageAlignmentBottom:
        {
            imageTop = size.height - imageHeight - self.imageEdgeInsets.bottom;
            imageLeft = (size.width - imageWidth) * 0.5;
        }
            break;
        case HBButtonImageAlignmentRight:
        {
            imageLeft = size.width - imageWidth - self.imageEdgeInsets.right;
            imageTop = (size.height - imageHeight) * 0.5;
        }
            break;
        default:
            break;
    }
    return CGRectMake(imageLeft, imageTop, imageWidth, imageHeight);
}

#pragma mark 计算子控件的frame
- (void)setFramesForSubViews {
    NSString *key = [self _getCurrentStateKey];
    CGRect imageRect = CGRectZero;
    CGRect titleRect = CGRectZero;
    CGSize selfSize = self.bounds.size;
    if ([self.titleAttributesInfo.allKeys containsObject:key]) {
        self.titleLabel.text = [self.titleAttributesInfo objectForKey:key];
    }
    
    if (self.titleLabel.text.length) {
        [self.titleLabel sizeToFit];
        titleRect = self.titleLabel.bounds;
    }
    
    if ([self.imageAssetNames.allKeys containsObject:key]) {
        UIImage *image = [UIImage imageNamed:[self.imageAssetNames objectForKey:key]];
        self.imageLayer.contents = (__bridge id)image.CGImage;
        self.imageLayer.contentsGravity = kCAGravityResizeAspect;
        if (image.scale != [UIScreen mainScreen].scale) {
            self.scale = image.scale;
        }
        self.imageLayer.contentsScale = self.scale;
        imageRect = [self caculatedImageFrame:self.bounds];
        
        if (!self.titleLabel.text.length) {
            imageRect = CGRectMake((selfSize.width - imageRect.size.width) * 0.5, (selfSize.height - imageRect.size.height) * 0.5, imageRect.size.width, imageRect.size.height);
        }
        self.imageLayer.frame = imageRect;
    }
    
    CGFloat titleX = self.titleEdgeInsets.left;
    CGFloat titleY = self.titleEdgeInsets.top;
    CGFloat titleWidth = titleRect.size.width;
    CGFloat titleHeight = titleRect.size.height;
    switch (self.imageAlignment) {
        case HBButtonImageAlignmentTop:
        {
            titleY = (self.bounds.size.height - CGRectGetMaxY(self.imageLayer.frame) - titleHeight) * 0.5 + CGRectGetMaxY(self.imageLayer.frame);
            titleWidth = titleWidth > self.bounds.size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right ? self.bounds.size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right : titleWidth;
        }
            break;
        case HBButtonImageAlignmentLeft:
        {
            titleX = CGRectGetMaxX(self.imageLayer.frame) + self.titleEdgeInsets.left * 0.5;
            titleY = (self.bounds.size.height - titleHeight) * 0.5;
            titleWidth = self.bounds.size.width - titleX - self.titleEdgeInsets.right;
        }
            break;
        case HBButtonImageAlignmentBottom:
        {
            titleWidth = titleWidth > self.bounds.size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right ? self.bounds.size.width - self.titleEdgeInsets.left - self.titleEdgeInsets.right : titleWidth;
            titleY = (self.bounds.size.height - imageRect.size.height - self.imageEdgeInsets.bottom -  titleHeight) * 0.5 ;
        }
            break;
        case HBButtonImageAlignmentRight:
        {
            titleY = (self.bounds.size.height - titleHeight) * 0.5;
            titleWidth = self.bounds.size.width - (CGRectGetMaxX(self.imageLayer.frame) - CGRectGetMinX(self.imageLayer.frame)) - self.titleEdgeInsets.right;
        }
            break;
        default:
            break;
    }
    
    titleRect = CGRectMake(titleX, titleY, titleWidth, titleHeight);
    if (!self.imageLayer.contents) {
        titleRect = CGRectMake((selfSize.width - titleRect.size.width) * 0.5, (selfSize.height - titleRect.size.height) * 0.5, titleRect.size.width, titleRect.size.height);
    }
    self.titleLabel.frame = titleRect;
}


#pragma mark - 获取指定状态下的标题文本
- (nullable NSString *)titleForState:(UIControlState)state {
    NSString *key = [self _getControlStateKeyWithState:state];
    if ([self.titleAttributesInfo.allKeys containsObject:key]) {
        return [self.titleAttributesInfo objectForKey:key];
    }
    return nil;
}


#pragma mark 获取指定状态下的标题文本颜色
- (nullable UIColor *)titleColorForState:(UIControlState)state {
    NSString *key = [self _getControlStateKeyWithState:state];
    if ([self.titleColors.allKeys containsObject:key]) {
        return [self.titleColors objectForKey:key];
    }
    return nil;
}

#pragma mark 获取指定状态下的图片image
- (nullable UIImage *)imageForState:(UIControlState)state {
    NSString *key = [self _getControlStateKeyWithState:state];
    if ([self.imageAssetNames.allKeys containsObject:key]) {
        return [UIImage imageNamed:[self.imageAssetNames objectForKey:key]];
    }
    return nil;
}

#pragma mark 获取指定状态下的背景图片Image
- (nullable UIImage *)backgroundImageForState:(UIControlState)state {
    NSString *key = [self _getControlStateKeyWithState:state];
    if ([self.backGroundImageAssetNames.allKeys containsObject:key]) {
        return [UIImage imageNamed:[self.backGroundImageAssetNames objectForKey:key]];
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _setHighlightedImageWithTouched:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _setHighlightedImageWithTouched:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _setHighlightedImageWithTouched:NO];
}

#pragma mark - Private方法
#pragma mark 设置背景图片
- (void)_setBackGroundImageWithState:(UIControlState)state {
    NSString *key = [self _getControlStateKeyWithState:state];
    if ([self.backGroundImageAssetNames.allKeys containsObject:key]) {
        UIImage *bgImage = [UIImage imageNamed:[self.backGroundImageAssetNames objectForKey:key]];
        self.layer.contents = (__bridge id)bgImage.CGImage;
        self.layer.contentsGravity = kCAGravityResize;
        self.layer.contentsScale = bgImage.scale;
    } else {
        self.layer.contents = nil;
    }
}

#pragma mark 获取当前state下的key
- (NSString *)_getCurrentStateKey {
    return [self _getControlStateKeyWithState:self.state];
}

- (NSString *)_getControlStateKeyWithState:(UIControlState)state {
    NSString *key = kControlNormalKey;
    switch (state) {
        case UIControlStateHighlighted:
            key = kControlHighlightedKey;
            break;
        case UIControlStateDisabled:
            key = kControlDisabledKey;
            break;
        case UIControlStateSelected:
            key = kControlSelectedKey;
            break;
        default:
            break;
    }
    return key;
}

- (void)_setHighlightedImageWithTouched:(BOOL)touched{
    self.touched = touched;
    if (!self.adjustsImageWhenHighlighted) {
        return;
    }
    if ([self.imageAssetNames.allKeys containsObject:kControlNormalKey]) {
        [self _setHighLightedEffectWithImageLayer:self.imageLayer image:[UIImage imageNamed:[self.imageAssetNames objectForKey:kControlNormalKey]]];
    }
    if ([self.backGroundImageAssetNames.allKeys containsObject:kControlNormalKey]) {
        [self _setHighLightedEffectWithImageLayer:self.layer image:[UIImage imageNamed:[self.backGroundImageAssetNames objectForKey:kControlNormalKey]]];
    }
}

- (void)_setHighLightedEffectWithImageLayer:(CALayer *)imageLayer image:(UIImage *)image {
    [_filter setValue:[CIImage imageWithCGImage:image.CGImage] forKey:kCIInputImageKey];
    [_filter setValue:@(-0.4) forKey:@"inputBrightness"];
    [_filter setValue:@(0.7) forKey:@"inputSaturation"];
    [_filter setValue:@(0.3) forKey:@"inputContrast"];
    CGImageRef cgImage = [_context createCGImage:_filter.outputImage fromRect:_filter.outputImage.extent];
    if (self.touched) {
        imageLayer.contents = (__bridge id _Nullable)(cgImage);
        imageLayer.contentsGravity = kCAGravityResize;
    } else {
        imageLayer.contents = (__bridge id _Nullable)(image.CGImage);
        imageLayer.contentsGravity = kCAGravityResize;
    }
    CGImageRelease(cgImage);
}

@end

