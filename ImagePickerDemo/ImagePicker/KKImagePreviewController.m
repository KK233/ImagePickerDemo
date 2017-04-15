//
//  KKImagePreviewController.m
//  imagePickDemo
//
//  Created by KKK on 16/8/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define DWDRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]// RGB色
#define DWDRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]// RGB色
#define UIColorFromRGB(rgbValue) UIColorFromRGBWithAlpha(rgbValue, 1.0f)
#define UIColorFromRGBWithAlpha(rgbValue, alpha1) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha1]//十六进制转RGB色
#define DisplayLabelBlackgroundColor UIColorFromRGB(0x486db9)
#define RightBarbuttonItemSelectedColor [UIColor greenColor]
#define RightBarbuttonItemNormalColor [UIColor whiteColor]

@import Photos;
#import "KKImagePreviewController.h"
#import "KKPreviewImageCell.h"
#import "UIImage+extend.h"

/**
 
 #大图预览
 
 - 左上角返回键
 - 是否选中
 - 右下角完成键 带数字
 
 - 图片大小
 - - 图片长边 > 屏幕的长
 - - - 图片长边缩放至屏幕长,短边根据长边比例缩放
 - - 图片长边 <= 屏幕长
 - - - 原比例
 
 */

#define selectedKey @"selectedKey"
#define PhassetKey @"PhassetKey"

@interface KKImagePreviewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
//UI
@property (nonatomic, weak) UIButton *rightBarButton;
@property (nonatomic, weak) UILabel *bottomLabel;
@property (nonatomic, weak) UIToolbar *bottomToolbar;
@property (nonatomic) BOOL statusBarHidden;

@end

@implementation KKImagePreviewController

static NSString *cellID = @"cellID";
#pragma mark - Public Method
- (instancetype)initWithPhotosArray:(NSArray<PHAsset *> *)photosArray {
    //layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
//    self = [super initWithCollectionViewLayout:layout];
    self = [super init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    //设置collectionView 初始数据
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    [collectionView registerClass:[KKPreviewImageCell class] forCellWithReuseIdentifier:cellID];
    [collectionView setContentSize:(CGSize){_photosArray.count * kScreenWidth, kScreenHeight}];
//    self.view.frame = (CGRect){0, -64, [UIScreen mainScreen].bounds.size};
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _initIndex = 0;
    
//    _originArray = [photosArray copy];
    NSMutableArray *array = [NSMutableArray array];
    for (PHAsset *asset in photosArray) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: @1, selectedKey, asset,  PhassetKey, nil];
        [array addObject:dict];
    }
    _photosArray = array;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView reloadData];
//    });
    _statusBarHidden = NO;
    [self createBottomToolBar];
    
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
        //初始化操作


    
    //init view button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(didClickRightBarButtonItem)
     forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"btn_point_marquee_preview_normal"]
            forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_point_marquee_preview_selected"]
            forState:UIControlStateSelected];
    button.frame = (CGRect){0, 0, 22, 22};
    [button setSelected:YES];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = right;
    _rightBarButton = button;
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageWithColor:[UIColor blackColor]] renderAtAphla:0.44 completion:nil] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.44]] forBarMetrics:UIBarMetricsDefault];
    
    if (_initIndex > 9) {
        _initIndex = 9;
    }
    
    [self.collectionView setContentOffset:(CGPoint){_initIndex * kScreenWidth, 0} animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

#pragma mark - Event Response
- (void)didClickRightBarButtonItem {
    if ([self.collectionView isDecelerating] || [self.collectionView isDragging]) return;
    NSUInteger index = (self.collectionView.contentOffset.x + 1) / [UIScreen mainScreen].bounds.size.width;
    NSMutableDictionary *dict = [_photosArray[index] mutableCopy];
    
    if ([dict[selectedKey] isEqualToNumber:@1]) {
        //从选中状态变成未选中状态
        [dict setObject:@0 forKey:selectedKey];
        [self rightBarButtonItemUpdateWithSelected:NO];
    } else {
        //从未选中状态变成选中状态
        //保持数组插入位置和原本顺序相同
        [dict setObject:@1 forKey:selectedKey];
        
        [self rightBarButtonItemUpdateWithSelected:YES];
    }
    [_photosArray replaceObjectAtIndex:index withObject:dict];
    
    //更新列表控制器数据
    if (_delegate && [_delegate respondsToSelector:@selector(imagePreviewController:changedPhotosArray:)]) {
        [_delegate imagePreviewController:self changedPhotosArray:[self resultArray]];
    }
    [self refreshBottomToolBar];
}

- (void)didTapCell {
    _statusBarHidden = !_statusBarHidden;
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    [self.navigationController setNavigationBarHidden:_statusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
    [_bottomToolbar setHidden:_statusBarHidden];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
//    [self.collectionView reloadData];
    
}

- (void)completeButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(imagePreviewControllerShouldComplete:)]) {
        [_delegate imagePreviewControllerShouldComplete:self];
    }
}

#pragma mark - Private Method

- (NSArray *)resultArray {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *dict in _photosArray) {
        if ([dict[selectedKey] isEqualToNumber:@1]) {
            [resultArray addObject:dict[PhassetKey]];
        }
    }
    
    return resultArray;
}

- (void)rightBarButtonItemUpdateWithSelected:(BOOL)isSelected {
    [UIView animateWithDuration:0.5f animations:^{
        if (isSelected) {
            [_rightBarButton setSelected:YES];
        } else {
            [_rightBarButton setSelected:NO];
        }
    }];
}

- (void)createBottomToolBar {
    UIToolbar *toolbar = [[UIToolbar alloc] init];
//    toolbar.barStyle = UIBarStyleBlack;
//    toolbar.translucent = NO;
//    toolbar.barTintColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.44];
    [toolbar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.44]] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //fix
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //0
    UILabel *displayLabel = [UILabel new];
    displayLabel.font = [UIFont systemFontOfSize:14];
    displayLabel.textAlignment = NSTextAlignmentCenter;
    displayLabel.textColor = [UIColor whiteColor];
    displayLabel.text = [NSString stringWithFormat:@"%zd", _photosArray.count];
    displayLabel.backgroundColor = DisplayLabelBlackgroundColor;
    [displayLabel sizeToFit];
    CGRect labelFrame = displayLabel.frame;
    labelFrame.size.height = MAX(displayLabel.frame.size.height, displayLabel.frame.size.width);
    labelFrame.size.width = labelFrame.size.height;
    displayLabel.frame = labelFrame;
    displayLabel.layer.cornerRadius = displayLabel.bounds.size.width * 0.5;
//    displayLabel.layer.borderWidth = 1;
//    displayLabel.layer.borderColor = [[UIColor grayColor] CGColor];
    displayLabel.layer.masksToBounds = YES;
    _bottomLabel = displayLabel;
    UIView *dView = [[UIView alloc] initWithFrame:(CGRect){0, 0, labelFrame.size}];
    [dView addSubview:displayLabel];
    UIBarButtonItem *item0 = [[UIBarButtonItem alloc] initWithCustomView:dView];
    //2
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(completeButtonClick)];
    [item1 setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                    NSFontAttributeName : [UIFont systemFontOfSize:16]}
                         forState:UIControlStateNormal];
    toolbar.items = @[fixedItem, item0, item1];
    toolbar.frame = (CGRect){0, kScreenHeight - 44, kScreenWidth, 44};
    [self.view insertSubview:toolbar aboveSubview:self.collectionView];
    _bottomToolbar = toolbar;
}

- (void)refreshBottomToolBar {
    //正则筛选selectedkey为1的个数
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = 1", selectedKey]];
    NSArray *array = [_photosArray filteredArrayUsingPredicate:predicate];
    
    
    _bottomLabel.text = [NSString stringWithFormat:@"%zd", array.count];
////    NSURL
//    CGRect labelFrame = _bottomLabel.frame;
//    labelFrame.size.height = MAX(_bottomLabel.frame.size.height, _bottomLabel.frame.size.width);
//    labelFrame.size.width = labelFrame.size.height;
//    _bottomLabel.frame = labelFrame;
    [_bottomLabel setNeedsDisplay];
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _photosArray[indexPath.item];
    PHAsset *asset = dict[PhassetKey];
    KKPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell)];
    [cell addGestureRecognizer:tapGest];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGRect newRect = [self finalSizeWithPixelWidth:asset.pixelWidth height:asset.pixelHeight];
    NSLog(@"\noriginWidth:%zd\noriginHeight:%zd", asset.pixelWidth, asset.pixelHeight);
    NSLog(@"\nexpectX:%f\nexpectY:%f\nexpectWidth:%f\nexpectHeight:%f",newRect.origin.x, newRect.origin.y, newRect.size.width, newRect.size.height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:newRect];
    [cell.contentView addSubview:imgView];
    cell.representedAssetIdentifier = asset.localIdentifier;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:newRect.size
                                contentMode:PHImageContentModeAspectFit
                                    options:nil
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                      NSLog(@"\nimageWidth:%f\nimageHeight:%f", result.size.width, result.size.height);
                                      imgView.image = result;
                                  }
                              }];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //当滚动时根据位置判断右上角的选中按钮是否是选中状态
    NSUInteger index = (scrollView.contentOffset.x + kScreenWidth * 0.5 - 1) / kScreenWidth;
    NSDictionary *dict = _photosArray[index];
    if ([dict[selectedKey] isEqualToNumber:@1]) {
        [self rightBarButtonItemUpdateWithSelected:YES];
    } else {
        [self rightBarButtonItemUpdateWithSelected:NO];
    }
}


- (UIImage *)imageWithColor:(UIColor *) color;
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (CGRect)finalSizeWithPixelWidth:(NSInteger)width height:(NSInteger)height {
    CGFloat newX = 0;
    CGFloat newY = 0;
    CGFloat newWidth = width;
    CGFloat newHeight = height;
    //宽 > 高
    if (width > height) {
        newX = 0;
        if (width > kScreenWidth) {
            //宽 > 高 && 宽 > 屏幕宽
            //new宽 = 屏幕宽
            newWidth = kScreenWidth;
            //new高 = 屏幕宽 / 宽 * 高
            newHeight = kScreenWidth / 1.0 / width * height;
        } else {
            //宽 > 高 && 宽 <= 屏幕宽
            //new宽 = 宽
            //new高 = 高
        }
        newY = (kScreenHeight - newHeight) * 0.5;
    }
    //高 > 宽
    else {
        if (height > kScreenHeight) {
            //高 > 宽 && 高 <= 屏幕高 && 宽 > 屏幕宽
            if (width > kScreenWidth) {
                //new宽 = 屏幕宽
                newWidth = kScreenWidth;
                //new高 = 屏幕宽 / 宽 * 高
                newHeight = kScreenWidth / 1.0 / width * height;
                newX = 0;
                newY = (kScreenHeight - newHeight) * 0.5;
            } else {
                //高 > 宽 && 高 > 屏幕宽
                //高 = 屏幕高
                newHeight = kScreenHeight;
                //宽 = 屏幕高 / 高 * 宽
                newWidth = kScreenHeight / 1.0 / height * width;
                
                newX = (kScreenWidth - newWidth) * 0.5;
                newY = 0;
            }
        } else {
            if (width > kScreenWidth) {
                //new宽 = 屏幕宽
                newWidth = kScreenWidth;
                //new高 = 屏幕宽 / 宽 * 高
                newHeight = kScreenWidth / 1.0 / width * height;
                newX = 0;
                newY = (kScreenHeight - newHeight) * 0.5;
            }
        }
    }
    
    return (CGRect){newX, newY, newWidth, newHeight};
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
