//
//  XLLOptions.h
//  PhotoTest
//
//  Created by xiaoll on 2019/3/22.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#ifndef XLLOptions_h
#define XLLOptions_h

//以哪种类型为参照物进行裁剪
typedef NS_ENUM(NSInteger, XLLAdjustStyle) {
    XLLAdjustStyleFrame,
    XLLAdjustStyleImage
};

//裁剪框样式
typedef NS_ENUM(NSInteger, XLLAdjustWindowType) {
    XLLAdjustWindowTypeRound,
    XLLAdjustWindowTypeRectangle,
    XLLAdjustWindowTypeTriangle
};

//拖动区域
typedef NS_OPTIONS(NSInteger, XLLClipWindowDragOptions) {
    XLLClipWindowDragOptionsNone    = 0,      //未知拖动区域
    XLLClipWindowDragOptionsTop     = 1 << 0, //顶部拖动区域
    XLLClipWindowDragOptionsLeft    = 1 << 1, //左边拖动区域
    XLLClipWindowDragOptionsRight   = 1 << 2, //右边拖动区域
    XLLClipWindowDragOptionsBottom  = 1 << 3  //底部拖动区域
};

#endif /* XLLOptions_h */
