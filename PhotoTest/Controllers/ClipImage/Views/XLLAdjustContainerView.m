//
//  XLLAdjustContainerView.m
//  PhotoTest
//
//  Created by xiaoll on 2019/3/22.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import "XLLAdjustContainerView.h"
#import "XLLAdjustFrameView.h"
#import "XLLAdjustImageView.h"

@interface XLLAdjustContainerView ()

@property (nonatomic, strong) XLLAdjustFrameView *adjustFrameView;
@property (nonatomic, strong) XLLAdjustImageView *adjustImageView;

@property (nonatomic, weak, readwrite) UIView<XLLAdjustContainerProtocol> *adjustView;

@end

@implementation XLLAdjustContainerView

#pragma mark - lazy loading
- (XLLAdjustFrameView *)adjustFrameView
{
    if (_adjustFrameView == nil)
    {
        _adjustFrameView = [[XLLAdjustFrameView alloc] init];
    }
    return _adjustFrameView;
}

- (XLLAdjustImageView *)adjustImageView
{
    if (_adjustImageView == nil)
    {
        _adjustImageView = [[XLLAdjustImageView alloc] init];
    }
    return _adjustImageView;
}

#pragma mark - life circle
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupBase];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupBase];
    }
    return self;
}

#pragma mark - setupBase
- (void)setupBase
{
    //默认
    self.backgroundColor = [UIColor clearColor];
    self.windowType = XLLAdjustWindowTypeRound;
    self.aspectRatio = 1.0;
    self.originImage = [UIImage imageNamed:@"1"];
    self.adjustStyle = XLLAdjustStyleFrame;
    //布局
    [self.adjustView setupAdjustContents];
    [self addSubview:self.adjustView];
}

#pragma mark - setter
- (void)setAdjustStyle:(XLLAdjustStyle)adjustStyle
{
    [self.adjustView removeFromSuperview];
    _adjustStyle = adjustStyle;
    self.adjustView = (adjustStyle == XLLAdjustStyleFrame)?self.adjustFrameView:self.adjustImageView;
    self.adjustView.aspectRatio = self.aspectRatio;
    self.adjustView.windowType = self.windowType;
    self.adjustView.originImage = self.originImage;
    //布局
    [self.adjustView setupAdjustContents];
    [self addSubview:(UIView *)self.adjustView];
}

- (void)setWindowType:(XLLAdjustWindowType)windowType
{
    _windowType = windowType;
    self.adjustView.windowType = windowType;
}

- (void)setAspectRatio:(CGFloat)aspectRatio
{
    _aspectRatio = aspectRatio;
    self.adjustView.aspectRatio = aspectRatio;
}

- (void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    self.adjustView.originImage = originImage;
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.adjustView.frame = self.bounds;
    [self.adjustView layoutAdjustContents];
}

@end
