//
//  XLLClipWindow.m
//  PhotoTest
//
//  Created by xiaoll on 2019/3/18.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import "XLLClipWindow.h"

@interface XLLClipWindow ()

@property (nonatomic, strong) CAShapeLayer *roundLayer;
@property (nonatomic, strong) CAShapeLayer *rectangleLayer;
@property (nonatomic, strong) CAShapeLayer *triangleLayer;

@end

@implementation XLLClipWindow
static const CGFloat DragSafeArea = 30.f;

#pragma mark - setter
- (void)setWindowType:(XLLAdjustWindowType)windowType
{
    _windowType = windowType;
    if (self.rectangleLayer && self.rectangleLayer.superlayer)
    {
        [self.rectangleLayer removeFromSuperlayer];
    }
    if (self.roundLayer && self.roundLayer.superlayer)
    {
        [self.roundLayer removeFromSuperlayer];
    }
    switch (windowType) {
        case XLLAdjustWindowTypeRectangle:
        {
            [self createRectangleLayer];
        }
            break;
        case XLLAdjustWindowTypeRound:
        {
            [self createRoundLayer];
        }
            break;
        case XLLAdjustWindowTypeTriangle:
        {
            [self createTriangleLayer];
        }
            break;
            
        default:
            break;
    }
}

- (void)createTriangleLayer
{
    if (self.triangleLayer && self.triangleLayer.superlayer)
    {
        [self.triangleLayer removeFromSuperlayer];
    }
    self.triangleLayer = [CAShapeLayer layer];
    self.triangleLayer.strokeColor = [UIColor yellowColor].CGColor;
    self.triangleLayer.fillColor = [UIColor clearColor].CGColor;
    self.triangleLayer.lineWidth = 2.f;
    self.triangleLayer.lineJoin = kCALineJoinRound;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.frame.size.width * 0.5, 0)];
    [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [path closePath];
    self.triangleLayer.path = path.CGPath;
    [self.layer addSublayer:self.triangleLayer];
}

- (void)createRoundLayer
{
    if (self.roundLayer && self.roundLayer.superlayer)
    {
        [self.roundLayer removeFromSuperlayer];
    }
    self.roundLayer = [CAShapeLayer layer];
    self.roundLayer.strokeColor = [UIColor yellowColor].CGColor;
    self.roundLayer.fillColor = [UIColor clearColor].CGColor;
    self.roundLayer.lineWidth = 2.f;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [path moveToPoint:CGPointMake(0, self.frame.size.height * 0.5)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height * 0.5)];
    [path moveToPoint:CGPointMake(self.frame.size.width * 0.5, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height)];
    self.roundLayer.path = path.CGPath;
    [self.layer addSublayer:self.roundLayer];
}

- (void)createRectangleLayer
{
    if (self.rectangleLayer && self.rectangleLayer.superlayer)
    {
        [self.rectangleLayer removeFromSuperlayer];
    }
    self.rectangleLayer = [CAShapeLayer layer];
    self.rectangleLayer.strokeColor = [UIColor yellowColor].CGColor;
    self.rectangleLayer.fillColor = [UIColor clearColor].CGColor;
    self.rectangleLayer.lineWidth = 2.f;
    
    UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:self.bounds];
    [rectanglePath moveToPoint:CGPointMake(self.frame.size.width / 3.f, 0)];
    [rectanglePath addLineToPoint:CGPointMake(self.frame.size.width / 3.f, self.frame.size.height)];
    
    [rectanglePath moveToPoint:CGPointMake(self.frame.size.width * 2 / 3.f, 0)];
    [rectanglePath addLineToPoint:CGPointMake(self.frame.size.width * 2 / 3.f, self.frame.size.height)];
    
    [rectanglePath moveToPoint:CGPointMake(0, self.frame.size.height / 3.f)];
    [rectanglePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height / 3.f)];
    
    [rectanglePath moveToPoint:CGPointMake(0, self.frame.size.height * 2 / 3.f)];
    [rectanglePath addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height * 2 / 3.f)];
    self.rectangleLayer.path = rectanglePath.CGPath;
    [self.layer addSublayer:self.rectangleLayer];
}

#pragma mark - public methods
- (UIBezierPath *)getCurrentWindowPath
{
    switch (self.windowType) {
        case XLLAdjustWindowTypeRound:
            return [UIBezierPath bezierPathWithCGPath:self.roundLayer.path];
        case XLLAdjustWindowTypeRectangle:
            return [UIBezierPath bezierPathWithCGPath:self.rectangleLayer.path];
        case XLLAdjustWindowTypeTriangle:
            return [UIBezierPath bezierPathWithCGPath:self.triangleLayer.path];
        default:
            goto fail;
            break;
    }
    goto fail;
fail:
    NSAssert(0, @"请正确设置windowType");
}

- (XLLClipWindowDragOptions)getClipWindowDragOptions:(CGPoint)location
{
    if (location.x > DragSafeArea &&
        location.x < self.frame.size.width - DragSafeArea &&
        location.y > -DragSafeArea &&
        location.y < DragSafeArea) {
        
        return XLLClipWindowDragOptionsTop;
    } else if (location.x > -DragSafeArea &&
               location.x < DragSafeArea &&
               location.y > DragSafeArea &&
               location.y < self.frame.size.height - DragSafeArea) {
        
        return XLLClipWindowDragOptionsLeft;
    } else if (location.x > DragSafeArea &&
               location.x < self.frame.size.width - DragSafeArea &&
               location.y > self.frame.size.height - DragSafeArea &&
               location.y < self.frame.size.height + DragSafeArea) {
        
        return XLLClipWindowDragOptionsBottom;
    } else if (location.x > self.frame.size.width - DragSafeArea &&
               location.x < self.frame.size.width + DragSafeArea &&
               location.y > DragSafeArea &&
               location.y < self.frame.size.height - DragSafeArea) {
        
        return XLLClipWindowDragOptionsRight;
    } else if (location.x > -DragSafeArea &&
               location.x < DragSafeArea &&
               location.y > -DragSafeArea &&
               location.y < DragSafeArea) {
        
        return XLLClipWindowDragOptionsTop | XLLClipWindowDragOptionsLeft;
    } else if (location.x > -DragSafeArea &&
               location.x < DragSafeArea &&
               location.y > self.frame.size.height - DragSafeArea &&
               location.y < self.frame.size.height + DragSafeArea) {
        
        return XLLClipWindowDragOptionsBottom | XLLClipWindowDragOptionsLeft;
    } else if (location.x > self.frame.size.width - DragSafeArea &&
               location.x < self.frame.size.width + DragSafeArea &&
               location.y > -DragSafeArea &&
               location.y < DragSafeArea) {
        
        return XLLClipWindowDragOptionsTop | XLLClipWindowDragOptionsRight;
    } else if (location.x > self.frame.size.width - DragSafeArea &&
               location.x < self.frame.size.width + DragSafeArea &&
               location.y > self.frame.size.height - DragSafeArea &&
               location.y < self.frame.size.height + DragSafeArea) {
        
        return XLLClipWindowDragOptionsBottom | XLLClipWindowDragOptionsRight;
    }
    return XLLClipWindowDragOptionsNone;
}

#pragma mark - layoutLayer
- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    self.windowType = _windowType;
}

@end
