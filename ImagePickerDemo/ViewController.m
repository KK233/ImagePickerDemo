//
//  ViewController.m
//  ImagePickerDemo
//
//  Created by 张琰博 on 2017/4/15.
//  Copyright © 2017年 KKK. All rights reserved.
//

#import "ViewController.h"

#import "KKAlbumsListController.h"
#import "KKImagePreviewController.h"

#import "KKSelectImageView.h"

@interface ViewController () <KKSelectImageViewDelegate, KKAlbumsListControllerDelegate>

@property (nonatomic, weak) KKSelectImageView *imgView;

@property (nonatomic, strong) NSArray *photosArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
    KKSelectImageView *imgsView = [[KKSelectImageView alloc] initWithFrame:(CGRect){0, 150, [UIScreen mainScreen].bounds.size.width, 200}];
    //    imgsView.backgroundColor = [UIColor redColor];
    imgsView.eventDelegate = self;
    [self.view addSubview:imgsView];
    _imgView = imgsView;
}

#pragma mark - KKSelectImageViewDelegate
- (void)selectImageView:(KKSelectImageView *)view didClickAddImagesButtonWithMaxCount:(NSUInteger)maxCount {
    KKAlbumsListController *vc = [[KKAlbumsListController alloc] initWithMaxCount:(9 -_photosArray.count)];
    vc.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationItem.backBarButtonItem.title = @"所有相册";
    
    // 此处写权限控制 相册权限通过后打开
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)selectImageViewDidChangedPhotosArray:(NSArray<PHAsset *> *)photosArray {
    _photosArray = photosArray;
}

- (void)listControllerShouldCancel:(KKAlbumsListController *)listController {
    [listController dismissViewControllerAnimated:YES completion:nil];
}

- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array {
    [listController dismissViewControllerAnimated:YES completion:^{
        if (_imgView && [_imgView respondsToSelector:@selector(addImagesWithArray:)]) {
            [_imgView addImagesWithArray:array];
        }
    }];
}



@end
