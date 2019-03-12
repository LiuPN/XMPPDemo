//
//  CZMainViewController.m
//  01-仿QQ
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "CZMainViewController.h"
#import "CZXMPPTools.h"

@interface CZMainViewController ()

@end

@implementation CZMainViewController

// 注销操作
- (IBAction)logout {
    [[CZXMPPTools sharedXMPPTools] logout];
    
    // 切换界面
    [[NSNotificationCenter defaultCenter] postNotificationName:CZLoginResultNotification object:@(NO)];
}

@end
