//
//  KKAlbumsListController.m
//  imagePickDemo
//
//  Created by KKK on 16/7/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define listAlbumTitle @"albumTitle"
#define kFetchResult @"fetchResult"

#import "KKAlbumsListController.h"
#import "KKImagePickThumbController.h"

#import "KKAlbumsListCell.h"
@import Photos;

@interface KKAlbumsListController () <KKImagePickThumbControllerDelegate>

@property (nonatomic, strong) NSArray *albumsArray;

@property (nonatomic) NSUInteger maxCount;

@end

@implementation KKAlbumsListController

#pragma mark - Life Cycle

static NSString *cellId = @"cellID";

- (instancetype) initWithMaxCount:(NSUInteger)maxCount {
    self = [super init];
    if (!maxCount || maxCount > 9 || maxCount < 1) {
        _maxCount = 9;
    } else {
        _maxCount = maxCount;
    }
    
    [self pushToAllPhotosWhenEnter];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"相册列表";
    //    KKImagePickThumbController *vc = [KKImagePickThumbController new];
    //    vc.delegate = self;
    //    [self.navigationController pushViewController:vc animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissButtonClick)];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerClass:[KKAlbumsListCell class] forCellReuseIdentifier:cellId];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAlbums];
}

#pragma mark - Event Response
- (void)dismissButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(listControllerShouldCancel:)]) {
        [_delegate listControllerShouldCancel:self];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *element = self.albumsArray[indexPath.row];
    KKAlbumsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@(%zd)", , ];
    PHAsset *asset = [(PHFetchResult *)(element[kFetchResult]) lastObject];
    cell.representedAssetIdentifier = asset.localIdentifier;
    PHImageRequestOptions *opt = [PHImageRequestOptions new];
    opt.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:(CGSize){60, 60}
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                                    
                                                    [cell setCellData:result
                                                           mainString:element[listAlbumTitle]
                                                         secondString:[NSString stringWithFormat:@"%zd 张", (unsigned long)[(PHFetchResult *)(element[kFetchResult]) count]]];
                                                }
                                            }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushWhenCellDidSelectedWithIndex:indexPath.row];
}

#pragma mark - KKImagePickThumbControllerDelegate
- (void)pickThumbControllerShouldCancel:(KKImagePickThumbController *)pickThumbController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickThumbController:(KKImagePickThumbController *)pickThumbController shouldCompleteWithArray:(NSArray<PHAsset *> *)array {
    if (_delegate && [_delegate respondsToSelector:@selector(listController:completeWithPhotosArray:)]) {
        [_delegate listController:self completeWithPhotosArray:array];
    }
}

#pragma mark - Private Method
- (void)getAlbums {
        //    PHFetchOptions *smartOptions = [PHFetchOptions new];
        //        smartOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        //    smartOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    //智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //用户相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    //创建array,逐个添加,去掉video
    NSMutableArray *albumsArray = [NSMutableArray array];
    [albumsArray addObjectsFromArray:[self imageAlbumArrayWithAlbumsList:smartAlbums]];
    [albumsArray addObjectsFromArray:[self imageAlbumArrayWithAlbumsList:userAlbums]];
    _albumsArray = albumsArray;
    [self.tableView reloadData];
}

- (NSArray *)imageAlbumArrayWithAlbumsList:(PHFetchResult *)albumsList {
    NSMutableArray *array = [NSMutableArray array];
    for (PHAssetCollection *album in albumsList) {
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *albumResult = [PHAsset fetchAssetsInAssetCollection:album options:options];
        if (albumResult.count == 0) continue;
        NSDictionary *dict = @{
                               listAlbumTitle : album.localizedTitle,
                               kFetchResult : albumResult,
                               };
        [array addObject:dict];
    }
    return array;
}

- (void)pushWhenCellDidSelectedWithIndex:(NSUInteger)index {
    NSDictionary *dict = self.albumsArray[index];
    KKImagePickThumbController *vc = [KKImagePickThumbController new];
    vc.maxCount = _maxCount;
    
    vc.title = dict[listAlbumTitle];
    vc.allPhotos = dict[kFetchResult];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToAllPhotosWhenEnter {
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:options];
        KKImagePickThumbController *vc = [KKImagePickThumbController new];
        vc.maxCount = _maxCount;
        vc.title = @"所有照片";
        vc.allPhotos = allPhotos;
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:NO];
        });
}

@end
