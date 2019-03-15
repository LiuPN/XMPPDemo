//
//  PNAddContactViewController.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/3/12.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PNAddContactViewController.h"
#import "CZXMPPTools.h"

@interface PNAddContactViewController ()<UITextFieldDelegate>

@end

@implementation PNAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新建联系人";
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *name = textField.text;
    
    if (name.length > 0) {
        
        NSRange range = [name rangeOfString:@"@"];
        if (range.location == NSNotFound) {
            name = [name stringByAppendingFormat:@"@%@", [CZXMPPTools sharedXMPPTools].xmppStream.myJID.domain];
        }
        
        [self addFriendWithName:name];
    }
    
    return YES;
}
- (void)addFriendWithName:(NSString *)name{
    
    XMPPJID *jid = [XMPPJID jidWithString:name];
    
    // 判断是否已经是好友
   BOOL exit = [[CZXMPPTools sharedXMPPTools].xmppRosterCoreDataStorage userExistsWithJID:jid xmppStream:[CZXMPPTools sharedXMPPTools].xmppStream];
    if (exit) {
        
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"已经是好友" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    // 添加订阅
    [[CZXMPPTools sharedXMPPTools].xmppRoster subscribePresenceToUser:jid];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
