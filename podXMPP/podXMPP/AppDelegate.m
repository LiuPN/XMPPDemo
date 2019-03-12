//
//  AppDelegate.m
//  01-仿QQ
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "AppDelegate.h"
#import "CZXMPPTools.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
/**
 一个应用程序启动后并且退出到后台，如果系统的内存紧张，系统有可能会将应用程序销毁！
 
 didFinishLaunchingWithOptions应用程序第一次启动会执行，如果应用程序被销毁，再次启动程序，仍然会执行此方法！
 
 应用程序被销毁后，会调用单例的dealloc方法
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];

    // 注册通知，监听连接登录的状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatus:) name:CZLoginResultNotification object:nil];
    
    // 会根据系统偏好中的内容 & 登录情况，决定显示那一个视图控制器
    // 启动的视图控制器是不确定！
    // 如果进入系统，用户偏好中保存的信息是正确的，应该先登录一下服务器，登录成功后，进入主界面
    // 如果用户在其他客户端修改了密码，再次登录，会使用旧的密码验证，会出现验证失败，应该进入登录界面
    if (![[CZXMPPTools sharedXMPPTools] connectionWithFailed:nil]) {
        // 显示登录视图控制器
        [self setupWindowViewControllerWithName:@"Login"];
    }else{
        [self setupWindowViewControllerWithName:@"Main"];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

// 登录状态变化
- (void)loginStatus:(NSNotification *)notification {
    
    NSLog(@"接收到通知 %@ %@", [NSThread currentThread], notification);
    
    // 根据notification的object的数值，判断加载的stroyboard
    if ([notification.object intValue]) {
        // 登录成功
        [self setupWindowViewControllerWithName:@"Main"];
    } else {
        // 登录失败
        [self setupWindowViewControllerWithName:@"Login"];
    }
}

// 设置window的视图控制器
- (void)setupWindowViewControllerWithName:(NSString *)name {
    // 根据name加载Storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:name bundle:nil];
    
    // 切换视图控制器
    self.window.rootViewController = sb.instantiateInitialViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // 断开连接
    [[CZXMPPTools sharedXMPPTools] disconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 重新连接
    [[CZXMPPTools sharedXMPPTools] connectionWithFailed:^(NSString *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的密码可能在其他的计算机上被修改，请重新登录。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (void)dealloc {
    // 删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
