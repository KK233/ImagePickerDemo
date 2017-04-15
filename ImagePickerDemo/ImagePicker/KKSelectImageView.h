//
//  KKSelectImageView.h
//  imagePickDemo
//
//  Created by KKK on 16/8/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKSelectImageView;
@class PHAsset;

@protocol KKSelectImageViewDelegate <NSObject>
@optional
//press add button
//then should push
- (void)selectImageView:(KKSelectImageView *)view didClickAddImagesButtonWithMaxCount:(NSUInteger)maxCount;

- (void)selectImageViewDidChangedPhotosArray:(NSArray <PHAsset *>*)photosArray;

- (void)selectImageViewFrameChanged:(CGRect)frame;

@end

@interface KKSelectImageView : UICollectionView
@property (nonatomic, strong) NSArray *photosArray;
@property (nonatomic, weak) id<KKSelectImageViewDelegate> eventDelegate;


//添加图片
- (void)addImagesWithArray:(NSArray<PHAsset *> *)array;
@end
