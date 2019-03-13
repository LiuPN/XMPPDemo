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
    // 添加订阅
    [[CZXMPPTools sharedXMPPTools].xmppRoster subscribePresenceToUser:jid];
}

@end
