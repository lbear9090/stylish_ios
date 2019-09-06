//
//  ESRetweetCell.h
//  StyleList
//
//  Created by Eric Schanet on 11.11.17.
//  Copyright © 2017 Eric Schanet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@interface ESRetweetCell: UITableViewCell
@property (nonatomic, strong) UIButton *itemButton;
@property (nonatomic, strong) KILabel *postText;
@property (nonatomic, strong) KILabel *OPmentionName;
@property (nonatomic, strong) UILabel *OPName;
@property (nonatomic, strong) UILabel *retweetLabel;

@end
