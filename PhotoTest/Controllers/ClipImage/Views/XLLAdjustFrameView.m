//
//  XLLAdjustFrameView.m
//  PhotoTest
//
//  Created by xiaoll on 2019/3/18.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import "XLLAdjustFrameView.h"
#import "XLLClipWindow.h"

@interface XLLAdjustFrameView ()
{
    //裁剪框最小宽高
    CGFloat _minClipWindowWH;
}

//源图片容器
@property (nonatomic, strong) UIImageView *originImgView;
//裁剪视窗
@property (nonatomic, strong) XLLClipWindow *clipWindow;
//蒙层
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@property (nonatomic, assign) XLLClipWindowDragOptions currentDragOption;

@end

@implementation XLLAdjustFrameView
@synthesize windowType = _windowType;
@synthesize aspectRatio = _aspectRatio;
@synthesize originImage = _originImage;

#pragma mark - lazy loading
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
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    }
    return _maskView;
}

- (XLLClipWindow *)clipWindow
{
    if (_clipWindow == nil)
    {
        _clipWindow = [[XLLClipWindow alloc] init];
    }
    return _clipWindow;
}

#pragma mark - XLLAdjustContainerProtocol
- (void)setupAdjustContents
{
    _minClipWindowWH = 15 * 3 + 2;
    
    [self addSubview:self.originImgView];
    [self.originImgView addSubview:self.maskView];
    [self.originImgView addSubview:self.clipWindow];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureHandle:)];
    [self.clipWindow addGestureRecognizer:panGesture];
}

- (void)layoutAdjustContents
{
    //防止在IB上计算为0，导致显示出现问题bug
    CGFloat imageWidth = MAX(self.originImage.size.width, 1);
    CGFloat imageHeight = MAX(self.originImage.size.height, 1);
    if (imageWidth > imageHeight)
    {
        CGFloat originImgHeight = self.frame.size.width * imageHeight / imageWidth;
        self.originImgView.frame = CGRectMake(0, (self.frame.size.height - originImgHeight) * 0.5, self.frame.size.width, originImgHeight);
    } else {
        CGFloat originImgWidth = self.frame.size.height * imageWidth / imageHeight;
        self.originImgView.frame = CGRectMake((self.frame.size.width - originImgWidth) * 0.5, 0, originImgWidth, self.frame.size.height);
    }
    [self resetClipViewAndMaskViewFrame];
}

- (UIImage *)getClipedImage
{
    CGFloat scaleFactorX = self.originImage.size.width * self.originImage.scale / self.originImgView.frame.size.width;
    CGFloat scaleFactorY = self.originImage.size.height * self.originImage.scale / self.originImgView.frame.size.height;
    
    CGRect rect = CGRectMake(self.clipWindow.frame.origin.x * scaleFactorX, self.clipWindow.frame.origin.y * scaleFactorY, self.clipWindow.frame.size.width * scaleFactorX, self.clipWindow.frame.size.height * scaleFactorY);
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

#pragma mark - event
- (void)onPanGestureHandle:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translationPos = [panGesture translationInView:panGesture.view];
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    CGPoint locationPos = [panGesture locationInView:panGesture.view];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.currentDragOption = [self.clipWindow getClipWindowDragOptions:locationPos];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.currentDragOption & XLLClipWindowDragOptionsTop)
            {
                //往上translation.y小于0，所以高度会增加,y会减小
                CGRect currentRect = panGesture.view.frame;
                CGFloat changeHeight = currentRect.size.height - translationPos.y;
                //获取高度最大最小值
                CGFloat maxHeight = CGRectGetMaxY(currentRect);
                CGFloat minHeight = _minClipWindowWH;
                CGFloat resultHeight = MIN(maxHeight, MAX(minHeight, changeHeight));
                currentRect.origin.y = CGRectGetMaxY(currentRect) - resultHeight;
                currentRect.size.height = resultHeight;
                panGesture.view.frame = currentRect;
            }
            if (self.currentDragOption & XLLClipWindowDragOptionsLeft) {
                //往左translation.x小于0，所以宽度会增加,x会减小
                CGRect currentRect = panGesture.view.frame;
                CGFloat changeWidth = currentRect.size.width - translationPos.x;
                //获取宽度最大最小值
                CGFloat maxWidth = CGRectGetMaxX(currentRect);
                CGFloat minWidth = _minClipWindowWH;
                CGFloat resultWidth = MIN(maxWidth, MAX(minWidth, changeWidth));
                currentRect.origin.x = CGRectGetMaxX(currentRect) - resultWidth;
                currentRect.size.width = resultWidth;
                panGesture.view.frame = currentRect;
            }
            if (self.currentDragOption & XLLClipWindowDragOptionsRight) {
                //往右translation.x大于0，所以宽度会增加
                CGRect currentRect = panGesture.view.frame;
                CGFloat changeWidth = currentRect.size.width + translationPos.x;
                //获取宽度最大最小值
                CGFloat maxWidth = self.originImgView.frame.size.width - currentRect.origin.x;
                CGFloat minWidth = _minClipWindowWH;
                CGFloat resultWidth = MIN(maxWidth, MAX(minWidth, changeWidth));
                currentRect.size.width = resultWidth;
                panGesture.view.frame = currentRect;
            }
            if (self.currentDragOption & XLLClipWindowDragOptionsBottom) {
                //往下translation.y大于0，所以宽度会增加
                CGRect currentRect = panGesture.view.frame;
                CGFloat changeHeight = currentRect.size.height + translationPos.y;
                //获取高度最大最小值
                CGFloat maxHeight = self.originImgView.frame.size.height - currentRect.origin.y;
                CGFloat minHeight = _minClipWindowWH;
                CGFloat resultHeight = MIN(maxHeight, MAX(minHeight, changeHeight));
                currentRect.size.height = resultHeight;
                panGesture.view.frame = currentRect;
            }
            if (self.currentDragOption == XLLClipWindowDragOptionsNone) {
                CGPoint changeCenter = CGPointMake(panGesture.view.center.x + translationPos.x, panGesture.view.center.y + translationPos.y);
                //计算出centerX的最大最小值
                CGFloat minCenterX = panGesture.view.frame.size.width * 0.5;
                CGFloat maxCenterX = self.originImgView.frame.size.width - panGesture.view.frame.size.width * 0.5;
                //计算出centerY的最大最小值
                CGFloat minCenterY = panGesture.view.frame.size.height * 0.5;
                CGFloat maxCenterY = self.originImgView.frame.size.height - panGesture.view.frame.size.height * 0.5;
                panGesture.view.center = CGPointMake(MIN(maxCenterX, MAX(minCenterX, changeCenter.x)), MIN(maxCenterY, MAX(minCenterY, changeCenter.y)));
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            self.currentDragOption = XLLClipWindowDragOptionsNone;
        }
            break;
            
        default:
            break;
    }
    [self resetClipWindowTransparentArea];
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

#pragma mark - private methods
- (void)resetClipViewAndMaskViewFrame
{
    if (CGSizeEqualToSize(self.originImage.size, CGSizeZero)) return;
    CGFloat clipWindowWidth = 0;
    CGFloat clipWindowHeight = 0;
    CGFloat imageWidth = self.originImgView.frame.size.width;
    CGFloat imageHeight = self.originImgView.frame.size.height;
    if (imageWidth > imageHeight) //横向
    {
        if (self.aspectRatio > 1 && imageHeight * self.aspectRatio > imageWidth)
        {
            clipWindowWidth = self.originImgView.frame.size.width * 3 / 4.0;
            clipWindowHeight = clipWindowWidth / self.aspectRatio;
        } else {
            clipWindowHeight = imageHeight * 3 / 4.0;
            clipWindowWidth = clipWindowHeight * self.aspectRatio;
        }
    } else {
        if (self.aspectRatio < 1 && self.aspectRatio < imageHeight < imageWidth)
        {
            clipWindowHeight = self.originImgView.frame.size.height * 3 / 4.0;
            clipWindowWidth = clipWindowHeight * self.aspectRatio;
        } else {
            clipWindowWidth = imageWidth * 3 / 4.0;
            clipWindowHeight = clipWindowWidth / self.aspectRatio;
        }
    }
    self.clipWindow.frame = CGRectMake((self.originImgView.frame.size.width - clipWindowWidth) * 0.5, (self.originImgView.frame.size.height - clipWindowHeight) * 0.5, clipWindowWidth, clipWindowHeight);
    self.maskView.frame = self.originImgView.bounds;
    self.clipWindow.windowType = self.windowType;
    [self resetClipWindowTransparentArea];
}

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
        case XLLAdjustWindowTypeRectangle:
        {
            clearPath = [[UIBezierPath bezierPathWithRect:self.clipWindow.frame] bezierPathByReversingPath];
        }
            break;
        case XLLAdjustWindowTypeRound:
        {
            clearPath = [[UIBezierPath bezierPathWithOvalInRect:self.clipWindow.frame] bezierPathByReversingPath];
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

@end
