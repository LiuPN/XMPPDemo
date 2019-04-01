//
//  PNChatCell.h
//  podXMPP
//
//  Created by 刘攀妞 on 2019/4/1.
//  Copyright © 2019年 刘攀妞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZXMPPTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

+ (PNChatCell *)cellWithTableView:(UITableView *)tb indexPath:(NSIndexPath *)indexPath  fetchedResultsController: (NSFetchedResultsController *)fetchedResultsController;
@end

NS_ASSUME_NONNULL_END
