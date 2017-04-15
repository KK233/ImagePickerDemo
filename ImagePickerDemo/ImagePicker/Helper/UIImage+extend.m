//
//  UIImage+extend.m
//  ImagePickerDemo
//
//  Created by 张琰博 on 2017/4/15.
//  Copyright © 2017年 KKK. All rights reserved.
//

#import "UIImage+extend.h"

@implementation UIImage (extend)

+ (UIImage *)imageWithColor:(UIColor *) color;
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

@end
