//
//  KKCollectionThumbImageCell.h
//  imagePickDemo
//
//  Created by KKK on 16/7/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

@import Photos;
#import <UIKit/UIKit.h>

@interface KKCollectionThumbImageCell : UICollectionViewCell

//about image
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

//about select

@end
