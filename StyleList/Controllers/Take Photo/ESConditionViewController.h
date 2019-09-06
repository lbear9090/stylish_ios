//
//  ESConditionViewController.h
//  Style List
//
//  Created by 123 on 5/8/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESConditionOptionCell.h"

@interface ESConditionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,ESConditionOptionCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblCondition;

@end
