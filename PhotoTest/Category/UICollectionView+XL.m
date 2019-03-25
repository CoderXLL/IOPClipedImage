//
//  UICollectionView+XL.m
//  PhotoTest
//
//  Created by Tuling Code on 16/7/14.
//  Copyright © 2016年 Tuling Code. All rights reserved.
//

#import "UICollectionView+XL.h"

@implementation UICollectionView (XL)

+ (instancetype)xlCollectionView:(void (^)(UICollectionViewFlowLayout *layout))backBlock
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[self alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    
    if (backBlock)
    {
        backBlock(layout);
    }
    
    return collectionView;
}

@end
