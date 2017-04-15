//
//  KKAlbumsListCell.h
//  EduChat
//
//  Created by KKK on 16/10/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKAlbumsListCell : UITableViewCell

@property (nonatomic, copy) NSString *representedAssetIdentifier;

@property (nonatomic, weak) UIImageView *photoView;

@property (nonatomic, weak) UILabel *mainLabel;
@property (nonatomic, weak) UILabel *secondLabel;




- (void)setCellData:(UIImage *)img mainString:(NSString *)mainString secondString:(NSString *)secondString;

@end
