//
//  PNAudioRecorder.h
//  podXMPP
//
//  Created by 刘攀妞 on 2019/4/1.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//  录音单例

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNAudioRecorder : NSObject
+ (instancetype)shareInstance;
/// 开始录音
- (void)startRecord;

/// 停止录音
- (void)stopRecordSuccess:(void (^)(NSURL *url, NSTimeInterval time))success faild:(void(^)(void))faild;

/// 播放音频
- (void)playAudioWithData:(NSData *)data completion:(void (^)())completion;
@end

NS_ASSUME_NONNULL_END
