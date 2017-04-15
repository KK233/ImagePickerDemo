//
//  UICollectionView+kk_Convenience.m
//  imagePickDemo
//
//  Created by KKK on 16/7/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "UICollectionView+kk_Convenience.h"

@implementation UICollectionView (kk_Convenience)

- (NSArray *)kk_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end
