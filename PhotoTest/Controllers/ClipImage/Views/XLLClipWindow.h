//
//  XLLClipWindow.h
//  PhotoTest
//
//  Created by xiaoll on 2019/3/18.
//  Copyright © 2019 Tuling Code. All rights reserved.
//  裁剪视窗

#import <UIKit/UIKit.h>
#import "XLLOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface XLLClipWindow : UIView

//视窗类型
@property (nonatomic, assign) XLLAdjustWindowType windowType;

/**
 根据拖动locationu获取拖动位置类型

 @param location 手势位置
 @return 位置类型
 */
- (XLLClipWindowDragOptions)getClipWindowDragOptions:(CGPoint)location;
- (UIBezierPath *)getCurrentWindowPath;

@end

NS_ASSUME_NONNULL_END
