//
//  KKCollectionThumbImageCell.m
//  imagePickDemo
//
//  Created by KKK on 16/7/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "KKCollectionThumbImageCell.h"

@interface KKCollectionThumbImageCell ()
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIImageView *markedView;
@end

@implementation KKCollectionThumbImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
//    imageView.backgroundColor = [UIColor grayColor];
    imageView.frame = self.contentView.bounds;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    //create selected mark view
    //22 * 22
    UIImageView *view = [[UIImageView alloc] init];
    view.userInteractionEnabled = YES;
    [view setImage:[UIImage imageNamed:@"btn_point_marquee_preview_normal"]];
    [view setHighlightedImage:[UIImage imageNamed:@"btn_point_marquee_preview_selected"]];
    view.frame = (CGRect){self.contentView.bounds.size.width - 22 - 5, 5, 22, 22};
    [self.contentView addSubview:view];
    view.highlighted = NO;
    _markedView = view;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //layout markImageView
    _markedView.frame = (CGRect){self.contentView.bounds.size.width - 22 - 5, 5, 22, 22};
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _imageView.image = nil;
}

- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbImage = thumbImage;
    _imageView.image = thumbImage;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.25f animations:^{
        [_markedView setHighlighted:selected];
    }];
    
}

@end
