//
//  CZXMPPTools.m
//  01-仿QQ
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "CZXMPPTools.h"
#import "XMPPLogging.h"
#import "DDTTYLogger.h"

// 用户偏好的键值
// 用户名
NSString *const CZLoginUserNameKey = @"CZLoginUserNameKey";
// 密码
NSString *const CZLoginPasswordKey = @"CZLoginPasswordKey";
// 主机名
NSString *const CZLoginHostnameKey = @"CZLoginHostnameKey";

// 通知字符串定义
NSString *const CZLoginResultNotification = @"CZLoginResultNotification";

//static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface CZXMPPTools() <XMPPStreamDelegate, XMPPRosterDelegate>

/** 连接失败处理块代码 */
@property (nonatomic, strong) void (^failed) (NSString *errrorMessage);

// 重新连接模块
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;

@end

@implementation CZXMPPTools
// 合成指令@synthesize，用来指定属性对应的成员变量
@synthesize xmppStream = _xmppStream;

+ (instancetype)sharedXMPPTools {
    static CZXMPPTools *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 1. 设置Logger
//        [DDTTYLogger sharedInstance].colorsEnabled = YES;
//        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
//        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor darkGrayColor] backgroundColor:nil forFlag:XMPP_LOG_FLAG_SEND_RECV];
//        [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV | LOG_LEVEL_INFO];
    }
    return self;
}

- (void)dealloc {
    // 应用程序被销毁后，会调用单例的dealloc方法
    // 清理xmpp相关属性
    [self teardownXmppStream];
}

// 设置XMPPStream
- (XMPPStream *)xmppStream {
    if (_xmppStream == nil) {
        // 1. 实例化
        _xmppStream = [[XMPPStream alloc] init];
        
        // 2. 实例化模块
        // 重新连接模块只要添加到XMPPStream之上，并且激活即可，只要用户登录成功(打开流，认证成功)
        // 重新连接模块就会自动执行重新的工作
        _xmppReconnect = [[XMPPReconnect alloc] init];
        
        // 管理好友
        _xmppRosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterCoreDataStorage dispatchQueue:dispatch_get_global_queue(0, 0)];
        _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO; // 不自动添加好友
        
        // 聊天模块
        _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
        
        // 3. 激活模块
        [_xmppReconnect activate:_xmppStream];
        [_xmppRoster activate:_xmppStream];
        [_xmppMessageArchiving activate:_xmppStream];
        
        // 4. 添加代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
//        [_xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _xmppStream;
}

// 销毁XMPP流相关属性
- (void)teardownXmppStream {
    // 1. 删除代理
    [_xmppStream removeDelegate:self];
    [_xmppRoster removeDelegate:self];
//    [_xmppMessageArchiving removeDelegate:self];
    // 2. 禁用模块
    [_xmppReconnect deactivate];
    [_xmppRoster deactivate];
    [_xmppMessageArchiving deactivate];
    
    // 3. 内存清理工作
    _xmppMessageArchivingCoreDataStorage = nil;
    _xmppMessageArchiving = nil;
    _xmppRosterCoreDataStorage = nil;
    _xmppRoster = nil;
    _xmppReconnect = nil;
    _xmppStream = nil;
    
}

#pragma mark - XMPP方法
/**
 连接到服务器
 */
- (BOOL)connectionWithFailed:(void (^)(NSString *))failed {
    
    // 需要指定myJID & hostName
    NSString *hostName = [[NSUserDefaults standardUserDefaults] stringForKey:CZLoginHostnameKey];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:CZLoginUserNameKey];
    
    // 判断hostName & userName 是否有内容
    if (hostName.length == 0 || username.length == 0) {
        // 用户偏好中没有记录
        return NO;
    }
    
    // 保存块代码
    self.failed = failed;
    
    // 设置xmppStream的连接信息
    self.xmppStream.hostName = hostName;
    username = [username stringByAppendingFormat:@"@%@", hostName];
    self.xmppStream.myJID = [XMPPJID jidWithString:username];
    
    // 连接到服务器，如果连接已经存在，则不做任何事情
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:NULL];
    
    return YES;
}

// 断开连接方法
- (void)disconnect {
    // 通知服务器，用户下线
    [self goOffline];
    
    // 断开与服务器的连接
    [self.xmppStream disconnect];
}

// 用户上线
- (void)goOnline {
    XMPPPresence *p = [XMPPPresence presence];
    
    [self.xmppStream sendElement:p];
}

- (void)goOffline {
    XMPPPresence *p = [XMPPPresence presenceWithType:@"unavailable"];
    
    [self.xmppStream sendElement:p];
}

- (void)logout {
    // 所有用户信息是保存在用户偏好，注销应该删除用户偏好记录
    [self clearUserDefaults];
    
    // 下线，并且断开连接
    [self disconnect];
}

#pragma mark - XMPPStream的代理方法
// 完成连接
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"连接成功");
    
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:CZLoginPasswordKey];
    
    if (self.isRegisterUser) {
        // 将用户密码发送给服务器，进行用户注册
        [self.xmppStream registerWithPassword:password error:NULL];
        
        // 将注册标记复位
        self.isRegisterUser = NO;
    } else {
        // 将用户密码发送给服务器，进行用户登录
        [self.xmppStream authenticateWithPassword:password error:NULL];
    }
}

// 断开连接
// 参数：如果是服务器无法连接，error会有内容，如果是用户主动断开连接，error == nil
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"断开连接 %@", [NSThread currentThread]);
    
    // 在主线程更新UI
    if (self.failed && error) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"无法连接到服务器");});
    }
}

// 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"登录成功");
    
    // 通知服务器用户上线
    [self goOnline];
    
    // 登录成功之后，登录界面不需要任何回调信息，可以直接切换到主界面
    // 谁负责切换界面？
    // 在主线程利用通知发送广播
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CZLoginResultNotification object:@(YES)];
    });
}

// 密码错误
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"登录失败");
    
    // 断开与服务器的连接
    [self disconnect];
    // 清理用户偏好
    [self clearUserDefaults];
    
    // 在主线程更新UI
    if (self.failed) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"用户名或者密码错误！");});
    }
    
    // 如果是由AppDelegate调用的，同样应该发送一个通知，告诉AppDelegate登录失败
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CZLoginResultNotification object:@(NO)];
    });
}

// 清理用户偏好
- (void)clearUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:CZLoginUserNameKey];
    [defaults removeObjectForKey:CZLoginPasswordKey];
    [defaults removeObjectForKey:CZLoginHostnameKey];
    
    [defaults synchronize];
}

// 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"注册成功");
    
    // 让用户上线
    [self goOnline];
    
    // 发送通知，切换控制器
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CZLoginResultNotification object:@(YES)];
    });
}

// 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    NSLog(@"注册失败，通常因为用户已经存在");
    
    if (self.failed) {
        dispatch_async(dispatch_get_main_queue(), ^ {self.failed(@"您申请的账号已经被占用！");});
    }
}

#pragma mark - XMPPRosterDelegate 添加好友
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"=========%@", presence.from);
    
    // 通知用户 UI修改
    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSString *message = [NSString stringWithFormat:@"%@添加你为好友，是否同意？", presence.from.user];
       UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请求通知" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"通过" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
            
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    });
}

@end
