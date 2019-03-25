//
//  XLLAdjustContainerView.h
//  PhotoTest
//
//  Created by xiaoll on 2019/3/22.
//  Copyright © 2019 Tuling Code. All rights reserved.
//  利用IOP思想处理代码

#import <UIKit/UIKit.h>
#import "XLLAdjustContainerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface XLLAdjustContainerView : UIView

#if TARGET_INTERFACE_BUILDER
    @property (nonatomic, assign) IBInspectable NSInteger adjustStyle;
    @property (nonatomic, assign) IBInspectable NSInteger windowType;
#else
    @property (nonatomic, assign) XLLAdjustStyle adjustStyle;
    @property (nonatomic, assign) XLLAdjustWindowType windowType;
#endif

@property (nonatomic, assign) IBInspectable CGFloat aspectRatio;
@property (nonatomic, strong) IBInspectable UIImage *originImage;

@property (nonatomic, weak, readonly) UIView<XLLAdjustContainerProtocol> *adjustView;

@end

NS_ASSUME_NONNULL_END
