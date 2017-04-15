//
//  KKPhotosHelper.h
//  EduChat
//
//  Created by KKK on 16/9/23.
//  Copyright © 2016年 KK. All rights reserved.
//

/**
 此类是Photos框架的helper相关,如果有需求自行添加
 */

#import <Foundation/Foundation.h>

//@class PHAsset;
@import Photos;
@interface KKPhotosHelper : NSObject

+ (instancetype)defaultHelper;

/**
 上传图片根据phasset的数据数组
 */
- (void)uploadPhotosWithPhotosArray:(NSArray <PHAsset *> *)photos
                         completion:(void (^)(NSArray *photoNames, BOOL success))completionBlock;

/**
 保存相机拍下来的图片
 @param info            传入的是 由UIImagePickerController成功回调拿到的info
 */

- (void)SaveCaptureImageInfo:(NSDictionary *)info completion:(void (^)(PHAsset *asset, BOOL success, NSError *error))completionBlock;

/**
 根据原尺寸生成合适尺寸（最终尺寸）的图片尺寸
 */
- (CGSize)fitSizeWithOriginSize:(CGSize)originSize;

- (void)saveLocalAssetToSandBox:(PHAsset *)asset urlStr:(NSString *)urlString completion:(void (^)(BOOL success))completion;

@end
