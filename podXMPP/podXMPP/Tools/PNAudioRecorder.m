//
//  PNAudioRecorder.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/4/1.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PNAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface PNAudioRecorder()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSURL *recordUrl;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, copy) void (^completion)();
@end

@implementation PNAudioRecorder
+ (instancetype)shareInstance{
    static PNAudioRecorder *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}
- (instancetype)init{
    if (self = [super init]) {
        // 设置回话分类
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
        
        // 录音设置字典
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:8000.0], AVSampleRateKey, // 采样率
                                        [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey, // 文件个数
                                        [NSNumber numberWithInt:1], AVNumberOfChannelsKey, // 声道
                                        [NSNumber numberWithInt:AVAudioQualityLow], AVEncoderAudioQualityKey // 音质
                                        , nil];
        
        // 实例化录音机
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"record.caf"]; // 临时文件
        _recordUrl = [NSURL fileURLWithPath:path];
        _recorder = [[AVAudioRecorder alloc] initWithURL:_recordUrl settings:recordSettings error:NULL];
        
        // 准备录音 , 速度快
        [_recorder prepareToRecord];
    }
    return self;
}
- (void)startRecord{
    [self.recorder record];
}
- (void)stopRecordSuccess:(void (^)(NSURL *url, NSTimeInterval time))success faild:(void(^)(void))faild{
    
    NSTimeInterval time = self.recorder.currentTime; // 录音时间
    
     [self.recorder stop];
    
    if (time <= 1) {
        // 提示用户
        if (faild) {
            faild();
        }
        
    }else{
        // 录音成功
        if (success) {
            success(self.recordUrl, time);
        }
    }
    
   
}
#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    if (self.completion) {
        self.completion();
    }
}
/// 播放音频
- (void)playAudioWithData:(NSData *)data completion:(void (^)())completion{
    if (self.player.isPlaying) {// 之前正在播放的时候停止
        [self.player stop];
    }
    self.completion = completion;
    
    self.player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
    self.player.delegate = self;
    [self.player prepareToPlay];
    [self.player play];
}
@end






















