//
//  HBSnapShotView.h
//  HBTabView
//
//  Created by DylanHu on 2019/3/14.
//  Copyright © 2019 DylanHu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HBSaveSnapImageBlock)( UIImage * _Nonnull image);
typedef void(^HBShareSnapImageBlock)( UIImage * _Nonnull image);

@interface HBSnapShotView : UIView

@property (nonatomic, copy) HBSaveSnapImageBlock saveSnapImageBlock;
@property (nonatomic, copy) HBShareSnapImageBlock shareSnapImageBlock;
+ (instancetype)snapShotViewWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
