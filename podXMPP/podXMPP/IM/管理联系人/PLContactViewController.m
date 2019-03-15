//
//  PLContactViewController.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/3/12.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PLContactViewController.h"
#import "CZXMPPTools.h"
#import "PNChartViewController.h"

@interface PLContactViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PLContactViewController

#pragma mark - lazy
- (NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    // 在线状态 sectionNum  用section崩溃
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort1, sort2];
    
    /// 过滤掉对方没有确认的好友 subscription == none的过滤掉
    request.predicate = [NSPredicate predicateWithFormat:@"!(subscription CONTAINS 'none')"];
    
    NSManagedObjectContext *ctx = [CZXMPPTools sharedXMPPTools].xmppRosterCoreDataStorage.mainThreadManagedObjectContext;;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    // 设置代理
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 查询
    [self.fetchedResultsController performFetch:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.fetchedResultsController.fetchedObjects.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"contentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    XMPPUserCoreDataStorageObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // 判断离线在线外出 section
    NSString *status = [self userStatusWithUserSection:object.sectionNum];
    
    // both双向  none是还没确认添加  应该过滤到不显示
    // to 我关注对方
    // from 对方关注我
    // both 互粉 object.jid.domain不带@符号
    NSRange deleRange = [object.displayName rangeOfString:[@"@" stringByAppendingString:object.jid.domain]];
    
    NSMutableString *strM = [NSMutableString stringWithString:object.displayName];
    [strM replaceCharactersInRange:deleRange withString:@""];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ | %@", strM, object.subscription]; // 显示用户名
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", status];
    return cell;
   
}

- (NSString *)userStatusWithUserSection:(NSNumber *)sectionNum{
    
    // 0 在线
    // 1 离开
    // 2 离线
    switch ([sectionNum intValue]) {
        case 0:
            return @"在线";
            break;
        case 1:
            return @"离开";
            break;
        case 2:
            return @"离线";
            break;
            
        default:
            break;
    }
    return @"其他";
    
}

#pragma mark - 删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        XMPPUserCoreDataStorageObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSLog(@"删除------%@", object.displayName);
        
        // 提醒用户删除
       UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确认要删除%@用户吗？", object.displayName] preferredStyle:UIAlertControllerStyleAlert];
        
        [alertView addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertView addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            // 添加订阅  subscribe 订阅
            [[CZXMPPTools sharedXMPPTools].xmppRoster removeUser:object.jid];
            
        }]];
        [self presentViewController:alertView animated:YES completion:nil];
        
        
        
    }
}

#pragma mark - NSFetchedResultsControllerDelegate  绑定数据内容变化
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData]; // 刷新表格
}
@end
