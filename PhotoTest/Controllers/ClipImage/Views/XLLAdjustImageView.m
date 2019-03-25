//
//  XLLAdjustImageView.m
//  PhotoTest
//
//  Created by xiaoll on 2019/3/21.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import "XLLAdjustImageView.h"
#import "XLLClipWindow.h"

@interface XLLAdjustImageView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
//源图片容器
@property (nonatomic, strong) UIImageView *originImgView;
//裁剪视窗
@property (nonatomic, strong) XLLClipWindow *clipWindow;
//蒙层
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation XLLAdjustImageView
@synthesize windowType = _windowType;
@synthesize aspectRatio = _aspectRatio;
@synthesize originImage = _originImage;

#pragma mark - lazy loading
- (UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        _scrollView.clipsToBounds = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIImageView *)originImgView
{
    if (_originImgView == nil)
    {
        _originImgView = [[UIImageView alloc] init];
        _originImgView.userInteractionEnabled = YES;
    }
    return _originImgView;
}

- (UIView *)maskView
{
    if (_maskView == nil)
    {
        _maskView = [[UIView alloc] init];
        _maskView.userInteractionEnabled = NO;
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _maskView;
}

- (XLLClipWindow *)clipWindow
{
    if (_clipWindow == nil)
    {
        _clipWindow = [[XLLClipWindow alloc] init];
        _clipWindow.userInteractionEnabled = NO;
    }
    return _clipWindow;
}

#pragma mark - XLLAdjustContainerProtocol
- (void)setupAdjustContents
{
    self.aspectRatio = 1.5f;
    self.clipsToBounds = YES;
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.originImgView];
    [self addSubview:self.maskView];
    [self addSubview:self.clipWindow];
}

- (void)layoutAdjustContents
{
    self.maskView.frame = self.bounds;
    CGFloat imageWidth = MAX(self.originImage.size.width, 1);
    CGFloat imageHeight = MAX(self.originImage.size.height, 1);
    if (imageWidth > imageHeight)
    {
        //横向
        CGFloat originImgHeight = CGRectGetWidth(self.frame) * imageHeight / imageWidth;
        self.originImgView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), originImgHeight);
        //计算clipWindow初始位置
        if (self.aspectRatio > 1 && self.aspectRatio * imageHeight > imageWidth)
        {
            //clipWindow的宽度以self.frame.size.width为主
            CGFloat clipWindowW = self.frame.size.width * 3 / 4.0;
            CGFloat clipWindowH = clipWindowW / self.aspectRatio;
            self.clipWindow.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - clipWindowH) * 0.5, clipWindowW, clipWindowH);
        } else {
            //clipWindow的高度以originImgHeight为主
            CGFloat clipWindowH = originImgHeight * 3 / 4.0;
            CGFloat clipWindowW = clipWindowH * self.aspectRatio;
            self.clipWindow.frame = CGRectMake((CGRectGetWidth(self.frame) - clipWindowW) * 0.5, (CGRectGetHeight(self.frame) - clipWindowH) * 0.5, clipWindowW, clipWindowH);
        }
    } else {
        CGFloat originImgWidth = CGRectGetHeight(self.frame) * imageWidth / imageHeight;
        self.originImgView.frame = CGRectMake(0, 0, originImgWidth, CGRectGetHeight(self.frame));
        //计算clipWindow初始位置
        if (self.aspectRatio < 1 && self.aspectRatio *imageHeight < imageWidth)
        {
            //clipWindow的高度以self.frame.size.height为主
            CGFloat clipWindowH = self.frame.size.height * 3 / 4.0;
            CGFloat clipWindowW = clipWindowH * self.aspectRatio;
            self.clipWindow.frame = CGRectMake((CGRectGetWidth(self.frame) - clipWindowW) * 0.5, (CGRectGetHeight(self.frame) - clipWindowH) * 0.5, clipWindowW, clipWindowH);
        } else {
            //clipWindow的宽度以originImgWidth为主
            CGFloat clipWindowW = originImgWidth * 3 / 4.0;
            CGFloat clipWindowH = clipWindowW / self.aspectRatio;
            self.clipWindow.frame = CGRectMake((CGRectGetWidth(self.frame) - clipWindowW) * 0.5, (CGRectGetHeight(self.frame) - clipWindowH) * 0.5, clipWindowW, clipWindowH);
        }
    }
    self.scrollView.frame = self.clipWindow.frame;
    self.originImgView.center = CGPointMake(self.scrollView.frame.size.width * 0.5, self.scrollView.frame.size.height * 0.5);
    self.scrollView.contentSize = self.originImgView.frame.size;
    //调整originImgView中心
    [self scrollViewDidZoom:self.scrollView];
    [self.scrollView setContentOffset:CGPointMake((CGRectGetWidth(self.originImgView.frame) - CGRectGetWidth(self.scrollView.frame)) * 0.5, (CGRectGetHeight(self.originImgView.frame) - CGRectGetHeight(self.scrollView.frame)) * 0.5) animated:NO];
    self.clipWindow.windowType = self.windowType;
    [self resetClipWindowTransparentArea];
}

- (UIImage *)getClipedImage
{
    CGFloat scaleFactorX = self.originImage.size.width * self.originImage.scale / (self.originImgView.frame.size.width / self.scrollView.zoomScale);
    CGFloat scaleFactorY = self.originImage.size.height * self.originImage.scale / (self.originImgView.frame.size.height / self.scrollView.zoomScale);
    CGRect rect = [self.clipWindow convertRect:self.clipWindow.bounds toView:self.originImgView];
    rect = CGRectMake(CGRectGetMinX(rect) * scaleFactorX, CGRectGetMinY(rect) * scaleFactorY, CGRectGetWidth(rect) * scaleFactorX, CGRectGetHeight(rect) * scaleFactorY);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.originImage CGImage], rect);
    UIImage* newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsBeginImageContextWithOptions(newImage.size, NO, 0);
    UIBezierPath *clipPath = [UIBezierPath bezierPath];
    if (self.windowType == XLLAdjustWindowTypeRound)
    {
        clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
    } else {
        [clipPath moveToPoint:CGPointMake(newImage.size.width * 0.5, 0)];
        [clipPath addLineToPoint:CGPointMake(0, newImage.size.height)];
        [clipPath addLineToPoint:CGPointMake(newImage.size.width, newImage.size.height)];
        [clipPath closePath];
    }
    [clipPath addClip];
    [newImage drawAtPoint:CGPointZero];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - private methods
- (void)resetClipWindowTransparentArea
{
    if (self.maskLayer && self.maskLayer.superlayer)
    {
        [self.maskLayer removeFromSuperlayer];
    }
    self.maskLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.maskView.bounds];
    UIBezierPath *clearPath;
    switch (self.windowType) {
        case XLLAdjustWindowTypeRound:
        {
            clearPath = [[UIBezierPath bezierPathWithOvalInRect:self.clipWindow.frame] bezierPathByReversingPath];
        }
            break;
        case XLLAdjustWindowTypeRectangle:
        {
            clearPath = [[UIBezierPath bezierPathWithRect:self.clipWindow.frame] bezierPathByReversingPath];
        }
            break;
        case XLLAdjustWindowTypeTriangle:
        {
            clearPath = [[UIBezierPath bezierPath] bezierPathByReversingPath];
            [clearPath moveToPoint:CGPointMake(CGRectGetMidX(self.clipWindow.frame), CGRectGetMinY(self.clipWindow.frame))];
            [clearPath addLineToPoint:CGPointMake(CGRectGetMinX(self.clipWindow.frame), CGRectGetMaxY(self.clipWindow.frame))];
            [clearPath addLineToPoint:CGPointMake(CGRectGetMaxX(self.clipWindow.frame), CGRectGetMaxY(self.clipWindow.frame))];
            [clearPath closePath];
        }
            break;
            
        default:
            break;
    }
    [path appendPath:clearPath];
    self.maskLayer.path = path.CGPath;
    self.maskView.layer.mask = self.maskLayer;
}

#pragma mark - setter
- (void)setAspectRatio:(CGFloat)aspectRatio
{
    _aspectRatio = aspectRatio;
    [self layoutAdjustContents];
}

- (void)setOriginImage:(UIImage *)originImage
{
    _originImage = originImage;
    self.originImgView.image = originImage;
    [self layoutAdjustContents];
}

- (void)setWindowType:(XLLAdjustWindowType)windowType
{
    _windowType = windowType;
    [self layoutAdjustContents];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.originImgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.originImgView.center = CGPointMake(self.scrollView.contentSize.width * 0.5, self.scrollView.contentSize.height * 0.5);
}

@end
