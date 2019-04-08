//
//  HBSnapShotView.m
//  HBTabView
//
//  Created by DylanHu on 2019/3/14.
//  Copyright © 2019 DylanHu. All rights reserved.
//

#import "HBSnapShotView.h"

@interface HBSnapShotView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, weak) UIImageView *snapShopImageView;
@property (nonatomic, weak) UIButton *saveButton;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) BOOL isSaved;
@end

@implementation HBSnapShotView

#pragma mark 初始化方法
- (instancetype)init {
    if (self = [super init]) {
        [self _initSubviews];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    HBSnapShotView *snapShotView = [[HBSnapShotView alloc] init];
    snapShotView.snapShopImageView.image = image;
    return snapShotView;
}

+ (instancetype)snapShotViewWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsUpdateConstraints];
}

- (void)_initSubviews {
    self.backgroundColor = [UIColor orangeColor];
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 0.8;
    self.layer.borderColor = [UIColor redColor].CGColor;
    self.margin = 0.8;
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.backgroundColor = [UIColor yellowColor];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 5;
    
    [self addSubview:stackView];
    self.stackView = stackView;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *snapShopImageView = [[UIImageView alloc] init];
    [self addSubview:snapShopImageView];
    self.snapShopImageView = snapShopImageView;
    snapShopImageView.translatesAutoresizingMaskIntoConstraints = NO;

    UIButton *saveButton = [[UIButton alloc] init];
    [stackView addArrangedSubview:saveButton];
    self.saveButton = saveButton;
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    saveButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    UIButton *shareButton = [[UIButton alloc] init];
    [stackView addArrangedSubview:shareButton];
    self.saveButton = saveButton;
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize:15];
    shareButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [shareButton addTarget:self action:@selector(shareButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 保存截图点击事件监听
- (void)saveButtonTouchUpInside:(UIButton *)sender {
    if (self.isSaved) {
        return;
    }
    !self.saveSnapImageBlock ?: self.saveSnapImageBlock(self.snapShopImageView.image);
    if (self.snapShopImageView.image) {
        sender.enabled = NO;
        UIImageWriteToSavedPhotosAlbum(self.snapShopImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if (!error) {
        self.isSaved = YES;
    }
    self.saveButton.enabled = YES;
}

#pragma mark - 分享截图点击事件监听
- (void)shareButtonTouchUpInside:(UIButton *)sender {
    !self.shareSnapImageBlock ?: self.shareSnapImageBlock(self.snapShopImageView.image);
}

#pragma mark - 布局子视图
- (void)layoutSubviews {
    [super layoutSubviews];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[imageView]-margin-[stackView(<=maxStackH)]-margin-|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"margin":@(self.margin),@"maxStackH":@"30"} views:@{@"imageView":self.snapShopImageView,@"stackView":self.stackView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[imageView]-margin-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"margin":@(self.margin)} views:@{@"imageView":self.snapShopImageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[stackView]-margin-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"margin":@(self.margin)} views:@{@"stackView":self.stackView}]];
    [super updateConstraints];
}

@end
