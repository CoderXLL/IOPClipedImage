//
//  XLLAdjustContainerProtocol.h
//  PhotoTest
//
//  Created by xiaoll on 2019/3/22.
//  Copyright © 2019 Tuling Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLLOptions.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XLLAdjustContainerProtocol <NSObject>

@required
@property (nonatomic, strong) UIImage *originImage;
- (void)setupAdjustContents;
- (void)layoutAdjustContents;
- (UIImage *)getClipedImage;

@optional
@property (nonatomic, assign) XLLAdjustWindowType windowType;
@property (nonatomic, assign) CGFloat aspectRatio;

@end

NS_ASSUME_NONNULL_END
