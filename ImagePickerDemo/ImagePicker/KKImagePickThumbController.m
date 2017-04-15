//
//  KKImagePickThumbController.m
//  imagePickDemo
//
//  Created by KKK on 16/7/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

/**
 *
 * 图片选择器list 显示所有照片以及选择状态
 *
 * 右上角取消, 左下角预览,底部需要选择张数显示
 *
 * 点开预览大图(单张)
 * 点击按钮增加计数
 *
 */

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define DWDRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]// RGB色
#define DWDRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]// RGB色
#define UIColorFromRGB(rgbValue) UIColorFromRGBWithAlpha(rgbValue, 1.0f)
#define UIColorFromRGBWithAlpha(rgbValue, alpha1) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha1]//十六进制转RGB色
#define UIColorFromRGB(rgbValue) UIColorFromRGBWithAlpha(rgbValue, 1.0f)
#define UIColorFromRGBWithAlpha(rgbValue, alpha1) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha1]//十六进制转RGB色

/**
 *  cell的宽度,高度=宽度
 *  
 *  <11>img<11>img<11>img<11>img<11>
 *              <10>
 *  <11>img<11>img<11>img<11>img<11>
 *              <10>
 *  <11>img<11>img<11>img<11>img<11>
 *              <10>
 *  <11>img<11>img<11>img<11>img<11>
 *              <10>
 *  宽度 = (屏幕宽度 - 11 * 5) * 0.25
 *  高度 = 宽度
 *  横向间距 = 11
 *  纵向间距 = 10
 */
#define verMargin  2
#define horMargin  (1 + verMargin)
#define kCellWidth (kScreenWidth - horMargin * 5) * 0.25


@import Photos;
#import "KKImagePickThumbController.h"
#import "KKAlbumsListController.h"
#import "KKImagePreviewController.h"

#import "KKCollectionThumbImageCell.h"

#import "UICollectionView+kk_Convenience.h"

@interface KKImagePickThumbController () <UICollectionViewDelegate, UICollectionViewDataSource, KKImagePreviewControllerDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, weak) UILabel *bottomLabel;

@property (nonatomic, strong) PHCachingImageManager *imageManager;


@property CGRect previousPreheatRect;

@end

@implementation KKImagePickThumbController

static NSString *cellId = @"thumbCellId";
static CGSize AssetThumbnailSize;

- (instancetype)init {
    self = [super init];
    [self createCollectionView];
    [self createBottomToolBar];
    [self resetCachedAssets];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //取消按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick)];
    self.navigationItem.rightBarButtonItem = item;
    //create selectedArray
    if (_selectedArray == nil) {
        _selectedArray = [NSMutableArray array];
    }
    //toolbar
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    AssetThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    [self.collectionView reloadData];
    [self refreshToolBarStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self updateCachedAssets];
}

- (void)dealloc {
    [self.collectionView removeObserver:self
                             forKeyPath:@"contentSize"
                                context:NULL];
    
    NSLog(@"%s", __func__);
}

#pragma mark - Event Response
//取消按钮点击
- (void)cancelButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(pickThumbControllerShouldCancel:)]) {
        [_delegate pickThumbControllerShouldCancel:self];
    }
}

//预览按钮点击
- (void)previewButtonClick {
    //selectedArray卜等于0才响应
    if (_selectedArray.count == 0) return;
    
    KKImagePreviewController *vc = [[KKImagePreviewController alloc] initWithPhotosArray:_selectedArray];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//完成按钮点击
- (void)completeButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(pickThumbController:shouldCompleteWithArray:)]) {
        [_delegate pickThumbController:self shouldCompleteWithArray:_selectedArray];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary  *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat newHeight = [change[NSKeyValueChangeNewKey] CGSizeValue].height;
        CGFloat oldHeight = [change[NSKeyValueChangeOldKey] CGSizeValue].height;
        //只有高度增大的情况下才滚动到底部
        if (newHeight != oldHeight) {
            if (self.collectionView.contentSize.height > self.collectionView.bounds.size.height) {
                CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
                [self.collectionView setContentOffset:bottomOffset animated:NO];
//                NSLog(@"\n%f", self.collectionView.contentSize.height);
            }
        }
    }
}

#pragma mark - KKImagePriviewControllerDelegate
- (void)imagePreviewController:(KKImagePreviewController *)controller changedPhotosArray:(NSArray *)array {
    _selectedArray = [array mutableCopy];
//    NSLog(@"\n\nphotosArray:%@\n\nselectedArray:%@\n\n", array, _selectedArray);
}

- (void)imagePreviewControllerShouldComplete:(KKImagePreviewController *)controller {
    if (_delegate && [_delegate respondsToSelector:@selector(pickThumbController:shouldCompleteWithArray:)]) {
        [_delegate pickThumbController:self shouldCompleteWithArray:_selectedArray];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KKCollectionThumbImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId
                                                                                 forIndexPath:indexPath];
    PHAsset *asset = self.allPhotos[indexPath.item];
    cell.asset = asset;
    cell.representedAssetIdentifier = asset.localIdentifier;
    if ([_selectedArray containsObject:asset]) {
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath
                                     animated:NO
                               scrollPosition:UICollectionViewScrollPositionNone];
    }
    /**
     *  targetSize is Pixel size, not point size
     */
//    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//    options.synchronous = NO;
//    options.resizeMode = PHImageRequestOptionsResizeModeFast;
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          cell.thumbImage = result;
                                  }
                              }];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedArray.count < _maxCount) return YES;
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![_selectedArray containsObject:_allPhotos[indexPath.item]] && _selectedArray.count < _maxCount) {
        [_selectedArray addObject:_allPhotos[indexPath.item]];
    }
    [self refreshToolBarStatus];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectedArray containsObject:_allPhotos[indexPath.item]]) {
        [_selectedArray removeObject:_allPhotos[indexPath.item]];
    }
    [self refreshToolBarStatus];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}

#pragma mark - Private Method
//创建collectionView
- (void)createCollectionView {
    //创建layout
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = (CGSize){kCellWidth, kCellWidth};
    layout.minimumLineSpacing = verMargin;
    layout.minimumInteritemSpacing = horMargin;
    layout.sectionInset = UIEdgeInsetsMake(horMargin, horMargin, horMargin + 64 + 44, horMargin);
    //创建collectionView
    UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    view.allowsMultipleSelection = YES;
    [self.view addSubview:view];
    view.delegate = self;
    view.dataSource = self;
    _collectionView = view;
    
//    view.backgroundColor = DWDColorBackgroud;
    view.backgroundColor = [UIColor grayColor];
    [view registerClass:[KKCollectionThumbImageCell class] forCellWithReuseIdentifier:cellId];
    
    [view addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)createBottomToolBar {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.tintColor = [UIColor whiteColor];
    //0
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithTitle:@"预览"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(previewButtonClick)];
    [item0 setTitleTextAttributes:@{NSForegroundColorAttributeName : DWDRGBColor(51, 51, 51),
                                    NSFontAttributeName : [UIFont systemFontOfSize:16]}
                         forState:UIControlStateNormal];
//    [item0 setTitleTextAttributes:@{NSForegroundColorAttributeName : DWDRGBColor(51, 51, 51),
//                                    NSFontAttributeName : [UIFont systemFontOfSize:16]}
//                         forState:UIControlStateHighlighted];
//    [item0 setTitleTextAttributes:@{NSForegroundColorAttributeName : DWDRGBColor(51, 51, 51),
//                                    NSFontAttributeName : [UIFont systemFontOfSize:16]}
//                         forState:UIControlStateSelected];
    //fix
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //1
    UILabel *displayLabel = [UILabel new];
    displayLabel.textAlignment = NSTextAlignmentCenter;
    displayLabel.textColor = [UIColor whiteColor];
    displayLabel.text = [NSString stringWithFormat:@"%zd", _selectedArray.count];
    displayLabel.font = [UIFont systemFontOfSize:14];
    displayLabel.backgroundColor = UIColorFromRGB(0x486db9);
    [displayLabel sizeToFit];
    CGRect labelFrame = displayLabel.frame;
    labelFrame.size.height = MAX(displayLabel.frame.size.height, displayLabel.frame.size.width);
    labelFrame.size.width = labelFrame.size.height;
    displayLabel.frame = labelFrame;
    displayLabel.layer.cornerRadius = displayLabel.bounds.size.width * 0.5;
    displayLabel.layer.masksToBounds = YES;
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:displayLabel];
    _bottomLabel = displayLabel;
    //2
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(completeButtonClick)];
    [item2 setTitleTextAttributes:@{NSForegroundColorAttributeName : DWDRGBColor(90, 136, 231),
                                    NSFontAttributeName : [UIFont systemFontOfSize:16]}
                         forState:UIControlStateNormal];
    toolbar.items = @[item0, fixedItem, item1, item2];
    toolbar.frame = (CGRect){0, self.view.bounds.size.height - 44, kScreenWidth, 44};
    [self.view insertSubview:toolbar aboveSubview:self.collectionView];
}

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView kk_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView kk_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.allPhotos[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

//刷新底部状态栏
- (void)refreshToolBarStatus {
    _bottomLabel.text = [NSString stringWithFormat:@"%zd", _selectedArray.count];
    [_bottomLabel setNeedsDisplay];
}
#pragma mark - Setter / Getter

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        PHCachingImageManager *imageManager = [PHCachingImageManager new];
//        imageManager.allowsCachingHighQualityImages = NO;
        _imageManager = imageManager;
    }
    return _imageManager;
}

@end
