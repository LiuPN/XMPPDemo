//
//  CZXMPPTools.h
//  01-仿QQ
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

/**
 extern 关键字，表示常量在已经其他位置定义，可以直接使用，不用关心内部的定义细节
 
 跟 define 相比，define是的定义的宏，在编译的时候，会将宏的内容复制到相应位置
 
 而在OC中 @"hello world" 格式定义字符串，是保存在全局区的，意味着每使用一次宏，就会在全局区增加一个字符串
 
 而使用const的方法，在内存中只保留唯一的一个副本！
 */
// 用户名
extern NSString *const CZLoginUserNameKey;
// 密码
extern NSString *const CZLoginPasswordKey;
// 主机名
extern NSString *const CZLoginHostnameKey;

// 登录结果通知(成功／失败)
extern NSString *const CZLoginResultNotification;

@interface CZXMPPTools : NSObject

+ (instancetype)sharedXMPPTools;

/**
 所有和服务器的数据交互，都需要通过XMPPStream来进行
 
 readonly属性是避免其他类随意修改xmppStream或者重新实例化新的xmppStream的副本
 
 开闭原则，要尽量让内部的事情内部解决，能不开放就不开放！
 
 一旦指定了readonly，同时又重写getter方法，就会屏蔽掉默认的_成员变量！
 */
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

// 是否是注册用户的标记
@property (nonatomic, assign) BOOL isRegisterUser;

/**
 连接到服务器
 */
- (BOOL)connectionWithFailed:(void (^)(NSString *errorMessage))failed;

/**
 断开连接
 */
- (void)disconnect;

/**
 用户注销
 */
- (void)logout;

@end
