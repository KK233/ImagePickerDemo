//
//  KKAlbumsListCell.m
//  EduChat
//
//  Created by KKK on 16/10/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "KKAlbumsListCell.h"

#import <Masonry.h>

@interface KKAlbumsListCell ()

@end

@implementation KKAlbumsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
//    @property (nonatomic, weak) UIImageView *photoView;
//    
//    @property (nonatomic, weak) UILabel *mainLabel;
//    @property (nonatomic, weak) UILabel *secondLabel;
    UIImageView *imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(10);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.height.width.mas_equalTo(60);
    }];
    _photoView = imgView;
    
    UILabel *mainLabel = [UILabel new];
    mainLabel.font = [UIFont systemFontOfSize:16];
//    mainLabel.textColor = DWDColorBody;
    mainLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:mainLabel];
    [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(imgView.mas_right).offset(20);
        make.top.mas_equalTo(imgView);
    }];
    _mainLabel = mainLabel;
   
    UILabel *secondLabel = [UILabel new];
    secondLabel.font = [UIFont systemFontOfSize:14];
//    secondLabel.textColor = DWDColorContent;
    secondLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:secondLabel];
    [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(mainLabel);
        make.bottom.mas_equalTo(imgView.mas_bottom);
    }];
    _secondLabel = secondLabel;
    
    UIImageView *pushTagView = [UIImageView new];
    [self.contentView addSubview:pushTagView];
    [pushTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
    
    return self;
}

- (void)setCellData:(UIImage *)img
         mainString:(NSString *)mainString
       secondString:(NSString *)secondString {
    
    //设置数据
    [_photoView setImage:img];
    _mainLabel.text = mainString;
    _secondLabel.text = secondString;
}

@end
