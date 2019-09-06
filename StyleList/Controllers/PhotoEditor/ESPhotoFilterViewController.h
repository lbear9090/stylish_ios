//
//  ESPhotoFilterViewController.h
//  Style List
//
//  Created by 123 on 3/4/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESPhotoFilterViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btnDown;
@property (weak, nonatomic) IBOutlet UILabel *lblFilterType;
@property (weak, nonatomic) IBOutlet UIView *viewFilterType;
@property (strong, nonatomic)IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhotoFilter;
@property (weak, nonatomic) IBOutlet UIImageView *imgOriginalPhoto;

@end
