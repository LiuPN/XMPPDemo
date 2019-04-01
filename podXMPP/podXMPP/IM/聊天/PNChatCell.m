//
//  PNChatCell.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/4/1.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PNChatCell.h"
#import "UIImage+Scale.h"

@implementation PNChatCell

+ (PNChatCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath  fetchedResultsController: (NSFetchedResultsController *)fetchedResultsController{
    
    XMPPMessageArchiving_Message_CoreDataObject *object = [fetchedResultsController objectAtIndexPath:indexPath];
    
    
    NSString *ID = (object.isOutgoing) ? @"sendCell" : @"receiveCell";
    PNChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    
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

@end
