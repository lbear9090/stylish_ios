//
//  ESCategoryViewController.h
//  Style List
//
//  Created by 123 on 3/26/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESCategoryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tblCategory;

@end
