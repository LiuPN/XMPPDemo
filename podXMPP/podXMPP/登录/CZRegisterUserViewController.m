//
//  CZRegisterUserViewController.m
//  01-仿QQ
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "CZRegisterUserViewController.h"
#import "CZXMPPTools.h"

@interface CZRegisterUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *hostNameText;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation CZRegisterUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 显示导航栏
    self.navigationController.navigationBarHidden = NO;
    self.title = @"注册新用户";
    
    // 取消掉导航栏的拖拽返回
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
}

// 返回
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)textChanged {
    // 确保三个文本都输入了内容
    self.registerButton.enabled = (self.nameText.text.length > 0
                                   && self.passwordText.text.length > 0
                                   && self.hostNameText.text.length > 0);
}

// 注册用户
- (IBAction)regisgerUser {
    // 保存至用户偏好
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.nameText.text forKey:CZLoginUserNameKey];
    [defaults setObject:self.passwordText.text forKey:CZLoginPasswordKey];
    [defaults setObject:self.hostNameText.text forKey:CZLoginHostnameKey];
    
    [defaults synchronize];
    
    // 要向服务器注册用户，首先也需要连接到服务器
    [CZXMPPTools sharedXMPPTools].isRegisterUser = YES;
    
    [[CZXMPPTools sharedXMPPTools] connectionWithFailed:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

@end
