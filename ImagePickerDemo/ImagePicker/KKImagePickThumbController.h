//
//  KKImagePickThumbController.h
//  imagePickDemo
//
//  Created by KKK on 16/7/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKImagePickThumbController;
@class PHFetchResult;
@class PHAsset;

@protocol KKImagePickThumbControllerDelegate <NSObject>

@optional

/**
 *  dismiss by cancel action
 */
- (void)pickThumbControllerShouldCancel:(KKImagePickThumbController *)pickThumbController;

/**
 *  dismiss by complete action
 */
- (void)pickThumbController:(KKImagePickThumbController *)pickThumbController shouldCompleteWithArray:(NSArray<PHAsset *> *)array;
@end

@interface KKImagePickThumbController : UIViewController

//代理
@property (nonatomic, weak) id<KKImagePickThumbControllerDelegate> delegate;
//所有图片数组
@property (nonatomic, strong) PHFetchResult *allPhotos;
//最大值
@property (nonatomic, assign) NSUInteger maxCount;
//选中相册
@property (nonatomic, strong) NSMutableArray *selectedArray;

@end
