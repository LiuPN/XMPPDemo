//
//  PNChatCell.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/4/1.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PNChatCell.h"
#import "UIImage+Scale.h"
#import "PNAudioRecorder.h"

@interface PNChatCell()

@property (nonatomic, strong) NSData *audioData;

@end

@implementation PNChatCell

+ (PNChatCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath  fetchedResultsController: (NSFetchedResultsController *)fetchedResultsController{
    
    XMPPMessageArchiving_Message_CoreDataObject *object = [fetchedResultsController objectAtIndexPath:indexPath];
    
    
    NSString *ID = (object.isOutgoing) ? @"sendCell" : @"receiveCell";
    PNChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    // 注册点击播放音频事件
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(playAudio)];
    [cell.messageLabel addGestureRecognizer:recognizer];
    
    
    if([object.body isEqualToString:@"image"]){
        // 图片消息
        XMPPMessage *msg = object.message;
        
        for (XMPPElement *node in msg.children) {
            
            if ([node.name isEqualToString:@"attachment"]) {
                // 图片
                NSData *data = [[NSData alloc] initWithBase64EncodedString:node.stringValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *image = [UIImage imageWithData:data];
                
                // 图文混排 attachment
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = [image imageScaleWithWidth:200];
                NSAttributedString *attributedStr = [NSAttributedString attributedStringWithAttachment:attachment];
                cell.messageLabel.attributedText = attributedStr;

            }
        }
        
    }else if([object.body hasPrefix:@"audio"]){
        // 音频文件
        XMPPMessage *msg = object.message;
        
        for (XMPPElement *node in msg.children) {
            
            if ([node.name isEqualToString:@"attachment"]) {
                // 音频信息
                NSData *data = [[NSData alloc] initWithBase64EncodedString:node.stringValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                cell.audioData  = data; // 记录二进制
                cell.messageLabel.text = object.body;
            }
        }
        
        
    }else{
        // 文字消息
        cell.messageLabel.text = object.body;
    }
    
    
//    if(object.body){
//        cell.messageLabel.text = object.body;
//
//    }else{
//        NSLog(@"对方正在输入...");
//    }
    
    return cell;
}


- (void)playAudio{
    self.messageLabel.textColor = [UIColor redColor];
    __weak typeof(self) weakSelf = self;
    [[PNAudioRecorder shareInstance] playAudioWithData:self.audioData completion:^{
        weakSelf.messageLabel.textColor = [UIColor blackColor];
    }];
    
}

@end
