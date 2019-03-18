//
//  PNChartViewController.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/3/15.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PNChartViewController.h"

@interface PNChartViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextViewDelegate>
/// 聊天tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
/// 底部视图距离底部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
/// 文本框的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTextHeight;
/// 底部视图的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;

@end

@implementation PNChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"jid:  %@", self.chatJID);
    NSString *str = [NSString stringWithFormat:@"%@", self.chatJID];
    NSRange deleRange = [str rangeOfString:[NSString stringWithFormat:@"@%@", self.chatJID.domainJID]];
    NSMutableString *strM = [NSMutableString stringWithString:str];
    [strM replaceCharactersInRange:deleRange withString:@""];
    
    self.title = strM;
    [self.fetchedResultsController performFetch:NULL]; // 查询开始
    
    // 监听键盘的变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToBottom) name:UIKeyboardDidChangeFrameNotification object:nil];
    
     [self scrollToBottom]; // 滚动到最低端
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchedResultsController.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"chartCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    XMPPMessageArchiving_Message_CoreDataObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if(object.body){
        cell.textLabel.text = [NSString stringWithFormat:@"%@", object.body];
    }else{
        NSLog(@"对方正在输入...");
    }
    
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData]; // 刷新数据
    
    [self scrollToBottom]; // 滚动到最新的位置上
}

#pragma mark - 监听键盘的frame变化
- (void)keyboardChanged:(NSNotification *)noti{
    NSLog(@"noti: %@", noti);
    
    CGRect keyboardRect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.bottomViewConstraint.constant = keyboardRect.size.height;
  
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    // 计算文本的高度
    CGSize textRect = textView.bounds.size;
    NSDictionary *dict = @{NSFontAttributeName : textView.font};
    CGFloat textHeight = [textView.text boundingRectWithSize:CGSizeMake(textRect.width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size.height;

    NSLog(@"textHeight : %f", textHeight);
    if (textHeight > 34 && textHeight < 60) { // 超过一行的高度
        self.inputTextHeight.constant = textHeight;
    }else if(textHeight < 34){
        self.inputTextHeight.constant = 34;
    }
    self.bottomViewHeightConstraint.constant = self.inputTextHeight.constant + 10;
    
    
    if ([text isEqualToString:@"\n"]) {
        [self sendMsg:textView.text];
        textView.text = nil;
        
        // 回到原高度
        self.inputTextHeight.constant = 34;
        self.bottomViewHeightConstraint.constant = self.inputTextHeight.constant + 10;
        return NO;
    }
    return YES;
}
- (void)sendMsg:(NSString *)text{
    
    if ([self isBlankString:text]) {
        NSLog(@"不能发送空内容");
        return;
    }
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    [message addBody:text];
    
    [[CZXMPPTools sharedXMPPTools].xmppStream sendElement:message];
    
    
}
- (BOOL)isBlankString:(NSString*)string{
    
    NSString *str = [NSString stringWithFormat:@"%@",string];
    if (str == nil) {
        return YES;
    }
    if (str == NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([str isEqualToString:@""]) {
        return YES;
    }
    if ([str isEqual:[NSNull null]]) {
        return YES;
    }
    if ([str isEqualToString:@"<null>"]) {
        return YES;
    }
    if ([str isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([str isEqualToString:@"null"]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    /// 判断是不是空格
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    NSString *timedString = [str stringByTrimmingCharactersInSet:set];
    if ([timedString length] == 0) {
        return YES;
    }
    return NO;
    
}
/// 滚动到最新的位置上
- (void)scrollToBottom{
    
    NSInteger row = self.fetchedResultsController.fetchedObjects.count;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - lazy
- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    // 在线状态 sectionNum  用section崩溃
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    /// 只给jid聊天 表格
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
    NSManagedObjectContext *ctx = [CZXMPPTools sharedXMPPTools].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    // 设置代理
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
