//
//  PNChartViewController.h
//  podXMPP
//
//  Created by 刘攀妞 on 2019/3/15.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZXMPPTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNChartViewController : UIViewController
/// 当前聊天的jid
@property (nonatomic, strong) XMPPJID *chatJID;
@end

NS_ASSUME_NONNULL_END
