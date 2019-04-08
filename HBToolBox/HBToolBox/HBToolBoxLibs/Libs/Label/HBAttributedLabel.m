//
//  HBAttributedLabel.m
//  HBCoreText
//
//  Created by DylanHu on 2018/5/7.
//  Copyright © 2018年 DylanHu. All rights reserved.
//

#import "HBAttributedLabel.h"
#import "HBAttributedLabelAttachment.h"
#import "HBAttributedLabelURL.h"

static NSString *const HBUnicode16Character = @"\u2026";

static dispatch_queue_t hb_attributed_label_parse_queue;

static dispatch_queue_t get_hb_attributed_label_parse_queue() {
    if (hb_attributed_label_parse_queue == NULL) {
        hb_attributed_label_parse_queue = dispatch_queue_create("com.hb.parse_queue", 0);
    }
    return hb_attributed_label_parse_queue;
}

@interface HBAttributedLabel () {
    CTFrameRef _textFrame;
}
/// 存储需要被绘制的图片、UI控件等
@property (nonatomic, strong) NSMutableArray *attachments;
/// 将当前文本中的所有链接检测出来后，自定义新的链接经过绘制后存放到该容器中
@property (nonatomic, strong) NSMutableArray *linkLocations;
/// 使用coreText时文本的上行高度
@property (nonatomic, assign) CGFloat fontAscent;
/// 使用coreText是文本的下行高度
@property (nonatomic, assign) CGFloat fontDescent;
/// 字体大小
@property (nonatomic, assign) CGFloat fontHeight;
/// 属性文本
@property (nonatomic, strong) NSMutableAttributedString *attributedString;
/// 被点击的链接
@property (nonatomic, strong) HBAttributedLabelURL *touchedLink;
/// 是否检测链接
@property (nonatomic, assign) BOOL linkDetected;
/// 是否忽略重绘
@property (nonatomic, assign) BOOL ignoreRedraw;

@end

@implementation HBAttributedLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    if (_textFrame) {
        CFRelease(_textFrame);
    }
}

#pragma mark - 初始化
- (void)commonInit {
    _attributedString = [[NSMutableAttributedString alloc] init];
    _attachments = @[].mutableCopy;
    _linkLocations = @[].mutableCopy;
    _textFrame = nil;
    _linkColor = [UIColor blueColor];
    _font = [UIFont systemFontOfSize:15];
    _textColor = [UIColor blackColor];
    _highlightColor = [UIColor lightTextColor];
    _lineBreakMode = kCTLineBreakByWordWrapping;
    _underLineForLink = YES;
    _autoDetectLinks = YES;
    _lineSpacing = 0.0;
    _paragraphSpacing = 0.0;
    
    if (self.backgroundColor == nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    self.userInteractionEnabled = YES;
    [self resetFont];
}

#pragma mark 清除文本
- (void)cleanAll {
    _ignoreRedraw = NO;
    _linkDetected = NO;
    [_attachments removeAllObjects];
    [_linkLocations removeAllObjects];
    self.touchedLink = nil;
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    [self resetTextFrame];
}

#pragma mark 重置文本(CTFrame)
- (void)resetTextFrame {
    if (_textFrame) {
        CFRelease(_textFrame);
        _textFrame = nil;
    }
    if ([NSThread isMainThread] && !_ignoreRedraw) {
        [self setNeedsDisplay];
    }
}

#pragma mark 重置文本字体(CTFont)
- (void)resetFont {
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    if (fontRef) {
        _fontAscent = CTFontGetAscent(fontRef);
        _fontDescent = CTFontGetDescent(fontRef);
        _fontHeight = CTFontGetSize(fontRef);
        CFRelease(fontRef);
    }
}

#pragma mark - 属性设置
// 保证正常绘制，如果传入nil就直接不处理
- (void)setFont:(UIFont *)font {
    if (font && _font != font) {
        _font = font;
        
        [_attributedString hb_setFont:_font];
        [self resetFont];
        for (HBAttributedLabelAttachment *attachment in _attachments) {
            attachment.fontAscent = _fontAscent;
            attachment.fontDescent = _fontDescent;
        }
        [self resetTextFrame];
    }
}

#pragma mark 字体颜色
- (void)setTextColor:(UIColor *)textColor {
    if (textColor && _textColor != textColor) {
        _textColor = textColor;
        [_attributedString hb_setTextColor:textColor];
        [self resetTextFrame];
    }
}

#pragma mark 高亮颜色
- (void)setHighlightColor:(UIColor *)highlightColor {
    if (highlightColor && _highlightColor != highlightColor) {
        _highlightColor = highlightColor;
        [self resetTextFrame];
    }
}

#pragma mark 链接颜色
- (void)setLinkColor:(UIColor *)linkColor {
    if (_linkColor != linkColor) {
        _linkColor = linkColor;
        [self resetTextFrame];
    }
}

#pragma mark frame
- (void)setFrame:(CGRect)frame {
    CGRect oldRect = self.bounds;
    [super setFrame:frame];
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

#pragma mark bounds
- (void)setBounds:(CGRect)bounds {
    CGRect oldRect = self.bounds;
    [super setBounds:bounds];
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

#pragma mark 阴影颜色
- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor;
        [self resetTextFrame];
    }
}

#pragma mark 阴影偏移量
- (void)setShadowOffset:(CGSize)shadowOffset {
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        [self resetTextFrame];
    }
}

#pragma mark 阴影blur
- (void)setShadowBlur:(CGFloat)shadowBlur {
    if (_shadowBlur != shadowBlur) {
        _shadowBlur = shadowBlur;
        [self resetTextFrame];
    }
}

#pragma mark - 辅助方法
#pragma mark 获取属性文本
- (NSAttributedString *)attributedString:(NSString *)text {
    if ([text length]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:text];
        [string hb_setFont:self.font];
        [string hb_setTextColor:self.textColor];
        return string;
    } else {
        return [[NSAttributedString alloc] init];
    }
}

#pragma mark 获取需要展示的行数
- (NSInteger)numberOfDisplayedLines {
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    return _numberOfLines > 0 ? MIN(CFArrayGetCount(lines), _numberOfLines) : CFArrayGetCount(lines);
}

#pragma mark 属性文本绘制
- (NSAttributedString *)attributedStringForDraw {
    if (_attributedString) {
        // 添加排版格式
        NSMutableAttributedString *drawString = [_attributedString mutableCopy];
        
        // 如果LineBreakMode为TranncateTail,那么默认排版模式改成kCTLineBreakByCharWrapping,使得尽可能地显示所有文字
        CTLineBreakMode lineBreakMode = self.lineBreakMode;
        if (self.lineBreakMode == kCTLineBreakByTruncatingTail) {
            lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByTruncatingTail : kCTLineBreakByWordWrapping;
        }
        CGFloat fontLineHeight = self.font.lineHeight;  // 使用全局fontHeight作为最小lineHeight
        
        CTParagraphStyleSetting settings[] = {
            {kCTParagraphStyleSpecifierAlignment,sizeof(_textAlignment),&_textAlignment},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode),&lineBreakMode},
            {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
            {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(_paragraphSpacing),&_paragraphSpacing},
            {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(fontLineHeight),&fontLineHeight},
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings,sizeof(settings) / sizeof(settings[0]));
        [drawString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphStyle range:NSMakeRange(0, [drawString length])];
        CFRelease(paragraphStyle);
    
        for (HBAttributedLabelURL *url in _linkLocations) {
            if (url.range.location + url.range.length > [_attributedString length]) {
                continue;
            }
            
            UIColor *drawLinkColor = url.color ? : self.linkColor;
            [drawString hb_setTextColor:drawLinkColor range:url.range];
            [drawString hb_setUnderlineStyle:_underLineForLink ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone
                                     modifier:kCTUnderlinePatternSolid
                                        range:url.range];
        }
        return drawString;
    } else {
        return nil;
    }
}

#pragma mark 获取HBAttributedLabelURL
- (HBAttributedLabelURL *)urlForPoint:(CGPoint)point {
    static const CGFloat kVMargin = 5;
    if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kVMargin), point)
        || _textFrame == nil) {
        return nil;
    }
    
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    if (!lines)
        return nil;
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0,0), origins);
    
    CGAffineTransform transform = [self transformForCoreText];
    CGFloat verticalOffset = 0; //不像Nimbus一样设置文字的对齐方式，都统一是TOP,那么offset就为0
    
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        rect = CGRectInset(rect, 0, -kVMargin);
        rect = CGRectOffset(rect, 0, verticalOffset);
        
        if (CGRectContainsPoint(rect, point)) {
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            HBAttributedLabelURL *url = [self linkAtIndex:idx];
            if (url) {
                return url;
            }
        }
    }
    return nil;
}

#pragma mark HBAttributedLabelURL的linkData
- (id)linkDataForPoint:(CGPoint)point {
    HBAttributedLabelURL *url = [self urlForPoint:point];
    return url ? url.linkData : nil;
}

#pragma mark 对coreText文本做矩阵变换
- (CGAffineTransform)transformForCoreText {
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
}

#pragma mark 获取CTLineRef的CGSize
- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(point.x, point.y - descent, width, height);
}

#pragma mark 根据Index获取HBAttributedLabelURL
- (HBAttributedLabelURL *)linkAtIndex:(CFIndex)index {
    for (HBAttributedLabelURL *url in _linkLocations) {
        if (NSLocationInRange(index, url.range)) {
            return url;
        }
    }
    return nil;
}


- (CGRect)rectForRange:(NSRange)range
                inLine:(CTLineRef)line
            lineOrigin:(CGPoint)lineOrigin {
    
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
    // intersect with the range.
    for (CFIndex k = 0; k < runCount; k++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        CFRange stringRunRange = CTRunGetStringRange(run);
        NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
        NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);
        
        if (intersectedRunRange.length == 0) {
            // This run doesn't intersect the range, so skip it.
            continue;
        }
        
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        
        // Use of 'leading' doesn't properly highlight Japanese-character link.
        CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                           CFRangeMake(0, 0),
                                                           &ascent,
                                                           &descent,
                                                           NULL); //&leading);
        CGFloat height = ascent + descent;
        
        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
        
        CGRect linkRect = CGRectMake(lineOrigin.x + xOffset - leading, lineOrigin.y - descent, width + leading, height);
        
        linkRect.origin.y = roundf(linkRect.origin.y);
        linkRect.origin.x = roundf(linkRect.origin.x);
        linkRect.size.width = roundf(linkRect.size.width);
        linkRect.size.height = roundf(linkRect.size.height);
        
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
    }
    
    return rectForRange;
}

#pragma mark 添加占位元素(如图文混排时，图片需要预先计算占位空间)
- (void)appendAttachment:(HBAttributedLabelAttachment *)attachment {
    attachment.fontAscent = _fontAscent;
    attachment.fontDescent = _fontDescent;
    unichar objectReplacementChar = 0xFFFC;
    NSString *objectReplacementString  = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attachText = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    callbacks.dealloc = deallocCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)attachment);
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,kCTRunDelegateAttributeName, nil];
    [attachText setAttributes:attr range:NSMakeRange(0, 1)];
    CFRelease(delegate);
    
    [_attachments addObject:attachment];
    [self appendAttributedText:attachText];
}


#pragma mark - 设置文本
#pragma mark 设置普通文本
- (void)setText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self setAttributedText:attributedText];
}

#pragma mark 设置属性文本
- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [self cleanAll];
}

- (NSString *)text {
    return [_attributedString string];
}

- (NSAttributedString *)attributedText {
    return [_attributedString copy];
}

#pragma mark - 添加文本
- (void)appendText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self appendAttributedText:attributedText];
}

- (void)appendAttributedText:(NSAttributedString *)attributedText {
    [_attributedString appendAttributedString:attributedText];
    [self resetTextFrame];
}


#pragma mark - 添加图片
- (void)appendImage:(UIImage *)image {
    [self appendImage:image
              maxSize:image.size];
}

- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize {
    [self appendImage:image
              maxSize:maxSize
               margin:UIEdgeInsetsZero];
}

- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin {
    [self appendImage:image
              maxSize:maxSize
               margin:margin
            alignment:HBImageAlignmentBottom];
}

- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin
          alignment:(HBImageAlignment)alignment {
    HBAttributedLabelAttachment *attachment = [HBAttributedLabelAttachment attachmentWith:image
                                                                                     margin:margin
                                                                                  alignment:alignment
                                                                                    maxSize:maxSize];
    [self appendAttachment:attachment];
}

#pragma mark - 添加UI控件
- (void)appendView:(UIView *)view {
    [self appendView:view
              margin:UIEdgeInsetsZero];
}

- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin {
    [self appendView:view
              margin:margin
           alignment:HBImageAlignmentBottom];
}


- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin
         alignment:(HBImageAlignment)alignment {
    HBAttributedLabelAttachment *attachment = [HBAttributedLabelAttachment attachmentWith:view
                                                                                     margin:margin
                                                                                  alignment:alignment
                                                                                    maxSize:CGSizeZero];
    [self appendAttachment:attachment];
}

#pragma mark - 添加链接(自定义链接数据、range)
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range {
    [self addCustomLink:linkData
               forRange:range
              linkColor:self.linkColor];
    
}

#pragma mark 添加自定义链接(自定义链接数据、Color、range)
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range
            linkColor:(UIColor *)color {
    HBAttributedLabelURL *url = [HBAttributedLabelURL urlWithLinkData:linkData
                                                                  range:range
                                                                  color:color];
    [_linkLocations addObject:url];
    [self resetTextFrame];
}

#pragma mark - 计算大小
- (CGSize)sizeThatFits:(CGSize)size {
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString == nil) {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter) {
        CFRelease(framesetter);
    }
    
    //hack:
    //1.需要加上额外的一部分size,有些情况下计算出来的像素点并不是那么精准
    //2.iOS7 的 CTFramesetterSuggestFrameSizeWithConstraints方法比较残,需要多加一部分 height
    //3.iOS7 多行中如果首行带有很多空格，会导致返回的 suggestionWidth 远小于真实 width ,那么多行情况下就是用传入的 width
    if (newSize.height < _fontHeight * 2) {
        return CGSizeMake(ceilf(newSize.width) + 2.0, ceilf(newSize.height) + 4.0);
    } else {
        return CGSizeMake(size.width, ceilf(newSize.height) + 4.0);
    }
}


- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)];
}


#pragma mark - 绘制方法
- (void)drawRect:(CGRect)rect {
    // 获取绘图上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil) {
        return;
    }
    // 保存当前绘图上下文状态
    CGContextSaveGState(ctx);
    CGAffineTransform transform = [self transformForCoreText];
    CGContextConcatCTM(ctx, transform);
    
    [self recomputeLinksIfNeeded];
    
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString) {
        [self prepareTextFrame:drawString rect:rect];
        [self drawHighlightWithRect:rect];
        [self drawAttachments];
        [self drawShadow:ctx];
        [self drawText:drawString
                  rect:rect
               context:ctx];
    }
    CGContextRestoreGState(ctx);
}

- (void)prepareTextFrame:(NSAttributedString *)string rect:(CGRect)rect {
    if (_textFrame == nil) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil,rect);
        _textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
}

- (void)drawHighlightWithRect:(CGRect)rect {
    if (self.touchedLink && self.highlightColor) {
        [self.highlightColor setFill];
        NSRange linkRange = self.touchedLink.range;
        
        CFArrayRef lines = CTFrameGetLines(_textFrame);
        CFIndex count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), lineOrigins);
        NSInteger numberOfLines = [self numberOfDisplayedLines];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        for (CFIndex i = 0; i < numberOfLines; i++) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CFRange stringRange = CTLineGetStringRange(line);
            NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
            NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
            if (intersectedRange.length == 0) {
                continue;
            }
            
            CGRect highlightRect = [self rectForRange:linkRange
                                               inLine:line
                                           lineOrigin:lineOrigins[i]];
            highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);
            if (!CGRectIsEmpty(highlightRect)) {
                CGFloat pi = (CGFloat)M_PI;
                
                CGFloat radius = 1.0f;
                CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
                CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius,
                                radius, pi, pi / 2.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                                        highlightRect.origin.y + highlightRect.size.height);
                CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                                highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
                CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius,
                                radius, 0.0f, -pi / 2.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
                CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius,
                                -pi / 2, pi, 1);
                CGContextFillPath(ctx);
            }
        }
        
    }
}

- (void)drawShadow:(CGContextRef)ctx {
    if (self.shadowColor) {
        CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    }
}

#pragma mark 绘制文本
- (void)drawText:(NSAttributedString *)attributedString
            rect:(CGRect)rect
         context:(CGContextRef)context {
    if (_textFrame) {
        if (_numberOfLines > 0) {
            CFArrayRef lines = CTFrameGetLines(_textFrame);
            NSInteger numberOfLines = [self numberOfDisplayedLines];
            
            CGPoint lineOrigins[numberOfLines];
            CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, numberOfLines), lineOrigins);
            
            for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
                CGPoint lineOrigin = lineOrigins[lineIndex];
                CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
                CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
                
                BOOL shouldDrawLine = YES;
                // 处理最后一行line
                if (lineIndex == numberOfLines - 1 &&
                    _lineBreakMode == kCTLineBreakByTruncatingTail) {
                    // 找到最后一行并检查是否需要 truncatingTail
                    CFRange lastLineRange = CTLineGetStringRange(line);
                    if (lastLineRange.location + lastLineRange.length < attributedString.length) {
                        CTLineTruncationType truncationType = kCTLineTruncationEnd;
                        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                        
                        NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                                             effectiveRange:NULL];
                        NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:HBUnicode16Character
                                                                                          attributes:tokenAttributes];
                        CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                        
                        NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                        
                        if (lastLineRange.length > 0) {
                            //移除掉最后一个对象...（其实这个地方有点问题,也有可能需要移除最后 2 个对象，因为 attachment 宽度的关系）
                            [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                        }
                        
                        [truncationString appendAttributedString:tokenString];
                        
                        CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                        if (!truncatedLine) {
                            truncatedLine = CFRetain(truncationToken);
                        }
                        CFRelease(truncationLine);
                        CFRelease(truncationToken);
                        
                        CTLineDraw(truncatedLine, context);
                        CFRelease(truncatedLine);
                        
                        
                        shouldDrawLine = NO;
                    }
                }
                
                // 使用CTLineDraw 绘制line
                if(shouldDrawLine) {
                    CTLineDraw(line, context);
                }
            }
        } else {
            CTFrameDraw(_textFrame,context);
        }
    }
}

#pragma mark 绘制其它文本元素(UI控件，如UIImage等)
- (void)drawAttachments {
    if ([_attachments count] == 0) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), lineOrigins);
    NSInteger numberOfLines = [self numberOfDisplayedLines];
    for (CFIndex i = 0; i < numberOfLines; i++) {
        // 取出line
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 取出line的runs
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 获取runs的数量
        CFIndex runCount = CFArrayGetCount(runs);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        CGFloat lineHeight = lineAscent + lineDescent;
        CGFloat lineBottomY = lineOrigin.y - lineDescent;
        
        // 遍历以找到对应的 attachment 进行绘制
        for (CFIndex k = 0; k < runCount; k++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (nil == delegate) {
                continue;
            }
            HBAttributedLabelAttachment* attributedImage = (HBAttributedLabelAttachment *)CTRunDelegateGetRefCon(delegate);
            
            CGFloat ascent = 0.0f;
            CGFloat descent = 0.0f;
            CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,CFRangeMake(0, 0),&ascent,&descent,NULL);
            CGFloat imageBoxHeight = [attributedImage boxSize].height;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
            
            CGFloat imageBoxOriginY = 0.0f;
            switch (attributedImage.alignment)
            {
                case HBImageAlignmentTop:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
                    break;
                case HBImageAlignmentCenter:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0;
                    break;
                case HBImageAlignmentBottom:
                    imageBoxOriginY = lineBottomY;
                    break;
            }
            
            CGRect rect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight);
            UIEdgeInsets flippedMargins = attributedImage.margin;
            CGFloat top = flippedMargins.top;
            flippedMargins.top = flippedMargins.bottom;
            flippedMargins.bottom = top;
            
            CGRect attatchmentRect = UIEdgeInsetsInsetRect(rect, flippedMargins);
            
            if (i == numberOfLines - 1 &&
                k >= runCount - 2 &&
                _lineBreakMode == kCTLineBreakByTruncatingTail) {
                //最后行最后的2个CTRun需要做额外判断
                CGFloat attachmentWidth = CGRectGetWidth(attatchmentRect);
                const CGFloat kMinEllipsesWidth = attachmentWidth;
                if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth) {
                    continue;
                }
            }
            
            // content可能是UIImage对象也可能是UI控件
            id content = attributedImage.content;
            if ([content isKindOfClass:[UIImage class]]) {
                CGContextDrawImage(ctx, attatchmentRect, ((UIImage *)content).CGImage);
            } else if ([content isKindOfClass:[UIView class]]) {
                UIView *view = (UIView *)content;
                if (view.superview == nil) {
                    [self addSubview:view];
                }
                CGRect viewFrame = CGRectMake(attatchmentRect.origin.x,self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height,attatchmentRect.size.width,attatchmentRect.size.height);
                view.frame = viewFrame;
            } else {
                NSLog(@"Attachment Content Not Supported %@",content);
            }
            
        }
    }
}


#pragma mark - 点击事件处理
- (BOOL)onLabelClick:(CGPoint)point {
    id linkData = [self linkDataForPoint:point];
    if (linkData) {
        if (self.linkDidClickedBlock) {
            self.linkDidClickedBlock(self, linkData);
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(attributedLabel:clickedOnLink:)]) {
            [_delegate attributedLabel:self clickedOnLink:linkData];
        } else {
            NSURL *url = nil;
            if ([linkData isKindOfClass:[NSString class]]) {
                url = [NSURL URLWithString:linkData];
            } else if([linkData isKindOfClass:[NSURL class]]) {
                url = linkData;
            }
            if (url) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        return YES;
    }
    return NO;
}


#pragma mark - 链接处理
- (void)recomputeLinksIfNeeded {
    const NSInteger kMinHttpLinkLength = 5;
    if (!_autoDetectLinks || _linkDetected) {
        return;
    }
    NSString *text = [[_attributedString string] copy];
    NSUInteger length = [text length];
    if (length <= kMinHttpLinkLength) {
        return;
    }
    // 文本的长度小于或等于50时(文本长度足够短)可直接在主线程中检测链接，否则放到异步线程检测链接
    BOOL sync = length <= HBMinAsyncDetectLinkLength;
    [self computeLink:text
                 sync:sync];
}

#pragma mark 检测文本中的链接
- (void)computeLink:(NSString *)text
               sync:(BOOL)sync {
    __weak typeof(self) weakSelf = self;
    typedef void (^HBLinkBlock) (NSArray *);
    HBLinkBlock block = ^(NSArray *links) {
        weakSelf.linkDetected = YES;
        if ([links count]) {
            for (HBAttributedLabelURL *link in links) {
                [weakSelf addAutoDetectedLink:link];
            }
            [weakSelf resetTextFrame];
        }
    };
    
    if (sync) {
        _ignoreRedraw = YES;
        NSArray *links = [HBAttributedLabelURL detectLinks:text];
        block(links);
        _ignoreRedraw = NO;
    } else {
        dispatch_async(get_hb_attributed_label_parse_queue(), ^{
            NSArray *links = [HBAttributedLabelURL detectLinks:text];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *plainText = [[weakSelf attributedString] string];
                if ([plainText isEqualToString:text]) {
                    block(links);
                }
            });
        });
    }
}

- (void)addAutoDetectedLink:(HBAttributedLabelURL *)link {
    NSRange range = link.range;
    for (HBAttributedLabelURL *url in _linkLocations) {
        if (NSIntersectionRange(range, url.range).length != 0) {
            return;
        }
    }
    [self addCustomLink:link.linkData
               forRange:link.range];
}

#pragma mark - 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchedLink == nil) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        self.touchedLink =  [self urlForPoint:point];
    }
    
    if (self.touchedLink) {
        [self setNeedsDisplay];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    HBAttributedLabelURL *touchedLink = [self urlForPoint:point];
    if (self.touchedLink != touchedLink) {
        self.touchedLink = touchedLink;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.touchedLink) {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if(![self onLabelClick:point]) {
        [super touchesEnded:touches withEvent:event];
    }
    
    if (self.touchedLink) {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    HBAttributedLabelURL *touchedLink = [self urlForPoint:point];
    if (touchedLink == nil) {
        NSArray *subViews = [self subviews];
        for (UIView *view in subViews) {
            CGPoint hitPoint = [view convertPoint:point
                                         fromView:self];
            
            UIView *hitTestView = [view hitTest:hitPoint
                                      withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return nil;
    } else {
        return self;
    }
}

#pragma mark - 设置自定义的连接检测block
+ (void)setCustomDetectMethod:(HBCustomDetectLinkBlock)block {
    [HBAttributedLabelURL setCustomDetectMethod:block];
}

@end
