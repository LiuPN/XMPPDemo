//
//  UIImage+Scale.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/4/1.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)
- (UIImage *)imageScaleWithWidth:(CGFloat)width{
    
    if (width <= 0 || self.size.width < width) {
        return self;
    }
    
    CGFloat scale = self.size.width / width;
    CGFloat height = self.size.height / scale;
    
    // 绘制图片
    CGRect r = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(r.size);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return result;
    
}

@end
