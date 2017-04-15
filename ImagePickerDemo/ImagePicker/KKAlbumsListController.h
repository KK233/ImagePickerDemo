//
//  KKAlbumsListController.h
//  imagePickDemo
//
//  Created by KKK on 16/7/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKAlbumsListController;
@class PHAsset;
@protocol KKAlbumsListControllerDelegate <NSObject>

@optional
/**
 *  dismiss by cancel action
 */
- (void)listControllerShouldCancel:(KKAlbumsListController *)listController;

@required
/**
 basic useage
 
 
 if (_selectImageView && [_selectImageView respondsToSelector:@selector(addImagesWithArray:)]) {
 [_selectImageView addImagesWithArray:array];
 }
 */
- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array;
@end


/**
 
 初始化方法
 
 KKAlbumsListController *vc = [[KKAlbumsListController alloc] initWithMaxCount:9];
 vc.delegate = self;
 UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
 navi.navigationItem.backBarButtonItem.title = @"all albums";
 [self presentViewController:navi animated:YES completion:nil];
 */

@interface KKAlbumsListController : UITableViewController

//factory init

/**
 *  初始化方法
 *
 *  @param maxCount 默认值是9
 */
- (instancetype)initWithMaxCount:(NSUInteger)maxCount;

- (void)pushToAllPhotosWhenEnter;

@property (nonatomic, weak) id<KKAlbumsListControllerDelegate> delegate;

@end
