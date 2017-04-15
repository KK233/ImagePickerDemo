//
//  KKSelectImageView.m
//  imagePickDemo
//
//  Created by KKK on 16/8/17.
//  Copyright © 2016年 KK. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kMargin 5
#define kImageWidth (kScreenWidth - kMargin * 5 - 1.0f) / 4.0f
#define kImageHeight kImageWidth

@import Photos;
#import "KKSelectImageView.h"
#import "KKDisplayImageCell.h"

#import "KKImagePreviewController.h"

@interface KKSelectImageView () <UICollectionViewDelegate, UICollectionViewDataSource, KKImagePreviewControllerDelegate>

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end

@implementation KKSelectImageView

static NSString *imageCellId = @"imagecellID";
static NSString *plusCellId = @"plusCellId";

#pragma mark - Public Method
- (void)addImagesWithArray:(NSArray<PHAsset *> *)array {
    NSMutableArray *photos;
    if (_photosArray.count > 0) {
        photos = [_photosArray mutableCopy];
    } else {
        photos = [NSMutableArray array];
    }
    [photos addObjectsFromArray:array];
    _photosArray = photos;
    if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(selectImageViewDidChangedPhotosArray:)]) {
        [_eventDelegate selectImageViewDidChangedPhotosArray:_photosArray];
    }
    [self reloadData];
    [self layoutIfNeeded];
}

- (instancetype)initWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = (CGSize){kImageWidth, kImageHeight};
    layout.minimumLineSpacing = kMargin;
    layout.minimumInteritemSpacing = kMargin;
    layout.sectionInset = UIEdgeInsetsMake(20, 5, 20, 5);
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.scrollEnabled = NO;
    
    self.dataSource = self;
    self.delegate = self;
    [self registerClass:[KKDisplayImageCell class] forCellWithReuseIdentifier:imageCellId];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:plusCellId];
    
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    
    [self addObserver:self
           forKeyPath:@"contentSize"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil];
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
        CGSize oldSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
        if (newSize.height != oldSize.height) {
            CGRect frame = self.frame;
            frame.size.height = newSize.height;
            self.frame = frame;
            if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(selectImageViewFrameChanged:)]) {
                [_eventDelegate selectImageViewFrameChanged:self.frame];
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_photosArray.count < 9) {
        return _photosArray.count + 1;
    }
    return _photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (indexPath.item == _photosArray.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:plusCellId forIndexPath:indexPath];
//        for (UIGestureRecognizer *gesture0 in cell.gestureRecognizers) {
//            [cell removeGestureRecognizer:gesture0];
//        }
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_add_image_new_record_normal"]];
        imgView.frame = (CGRect){0, 0, kImageWidth, kImageHeight};
        imgView.userInteractionEnabled = YES;
        [cell addSubview:imgView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addButtonClick)];
        
        [cell addGestureRecognizer:gesture];
    } else {
        //如果满了 不显示+号按钮
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:imageCellId forIndexPath:indexPath];
//        for (UIGestureRecognizer *gesture1 in cell.gestureRecognizers) {
//            [cell removeGestureRecognizer:gesture1];
//        }
//        PHAsset *asset = _photosArray[indexPath.item];
//        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
//            KKLog(@"imageUrl:%@", contentEditingInput.fullSizeImageURL);
//        }];
        
        [self.imageManager requestImageForAsset:_photosArray[indexPath.item]
                                     targetSize:(CGSize){kImageWidth, kImageHeight}
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                      cell.backgroundView = [[UIImageView alloc] initWithImage:result];
                                      cell.backgroundView.userInteractionEnabled = YES;
                                      cell.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
                                      cell.backgroundView.clipsToBounds = YES;
                                  }];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] initWithFrame:(CGRect){0, 0, KKScreenW, 30}];
//    reusableview.backgroundColor = [UIColor redColor];
//    UILabel *la = [UILabel new];
//    la.textColor = KKColorBody;
//    la.font = [UIFont systemFontOfSize:16];
//    [reusableview addSubview:la];
    UICollectionReusableView *reusableview = nil;
//
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
//        reusableview.backgroundColor = KKColorBackgroud;
        reusableview.backgroundColor = [UIColor blueColor];
        UILabel *la = [UILabel new];
        la.text = @"添加图片";
        la.textColor = [UIColor grayColor];
        la.font = [UIFont systemFontOfSize:14];
        la.frame = (CGRect){10, 10, kScreenWidth, 15};
        [reusableview addSubview:la];
    }
    
    return reusableview;
}

#pragma mark - UICollectionViewDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (CGSize){kScreenWidth, 40};
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    KKDisplayImageCell
    //    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //        NSIndexPath *cellIndexPath = [collectionView indexPathForCell:cell];
    if ([[collectionView cellForItemAtIndexPath:indexPath] isKindOfClass:[KKDisplayImageCell class]]) {
        
        KKImagePreviewController *vc = [[KKImagePreviewController alloc] initWithPhotosArray:_photosArray];
        vc.initIndex = indexPath.item;
        vc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        [[self viewController] presentViewController:navi animated:YES completion:^{
        }];
        
//        //alertController
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        __weak typeof(self) weakSelf = self;
//        UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"删除图片" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf removeImageObjectWithIndex:indexPath.item];
//        }];
//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [alertController addAction:action0];
//        [alertController addAction:action1];
//        [[self viewController] presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - KKImagePreviewControllerDelegate
- (void)imagePreviewController:(KKImagePreviewController *)controller changedPhotosArray:(NSArray *)array {
    _photosArray = array;
    [self reloadData];
    [self layoutIfNeeded];
}

- (void)imagePreviewControllerShouldComplete:(KKImagePreviewController *)controller {
    __weak typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.eventDelegate && [weakSelf.eventDelegate respondsToSelector:@selector(selectImageViewDidChangedPhotosArray:)]) {
            [weakSelf.eventDelegate selectImageViewDidChangedPhotosArray:weakSelf.photosArray];
        }
        [weakSelf reloadData];
        [weakSelf layoutIfNeeded];
    }];
}

#pragma mark - Private Method


//- (void)removeImageObjectWithIndex:(NSUInteger)index {
//    if (index < _photosArray.count) {
//        NSMutableArray *array = [_photosArray mutableCopy];
//        [array removeObjectAtIndex:index];
//        _photosArray = array;
//        [self reloadData];
//    }
//}

- (void)addButtonClick {
    if (_photosArray.count >= 9) {
        return;
    }
    if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(selectImageView:didClickAddImagesButtonWithMaxCount:)] ) {
        [_eventDelegate selectImageView:self didClickAddImagesButtonWithMaxCount:(9 - _photosArray.count)];
    };
}

- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - Setter Getter
- (void)setPhotosArray:(NSArray *)photosArray {
    _photosArray = photosArray;
    [self reloadData];
    [self layoutIfNeeded];
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        PHCachingImageManager *imageManager = [PHCachingImageManager new];
        //        imageManager.allowsCachingHighQualityImages = NO;
        _imageManager = imageManager;
    }
    return _imageManager;
}

@end
