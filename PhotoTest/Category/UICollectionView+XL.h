//
//  UICollectionView+XL.h
//  PhotoTest
//
//  Created by Tuling Code on 16/7/14.
//  Copyright © 2016年 Tuling Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (XL)

+ (instancetype)xlCollectionView:(void (^)(UICollectionViewFlowLayout *layout))backBlock;

@end
