//
//  PNChartViewController.m
//  podXMPP
//
//  Created by 刘攀妞 on 2019/3/15.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import "PNChartViewController.h"

@interface PNChartViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
/// 聊天tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PNChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"123";
    [self.fetchedResultsController performFetch:NULL]; // 查询开始
    
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
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", object.body];
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData]; // 刷新数据
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
    
    NSManagedObjectContext *ctx = [CZXMPPTools sharedXMPPTools].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    // 设置代理
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
