//
//  KKImagePriviewController.h
//  imagePickDemo
//
//  Created by KKK on 16/8/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;
@class KKImagePreviewController;

@protocol KKImagePreviewControllerDelegate <NSObject>

@required
- (void)imagePreviewController:(KKImagePreviewController *)controller changedPhotosArray:(NSArray *)array;
- (void)imagePreviewControllerShouldComplete:(KKImagePreviewController *)controller;
@end

@interface KKImagePreviewController : UIViewController

@property (nonatomic, weak) id<KKImagePreviewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger initIndex;

- (instancetype)initWithPhotosArray:(NSArray<PHAsset *> *)photosArray;

@end
