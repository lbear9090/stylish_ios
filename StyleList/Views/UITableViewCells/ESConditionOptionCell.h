//
//  ESConditionOptionCell.h
//  Style List
//
//  Created by 123 on 5/8/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESConditionOptionCell;
@protocol ESConditionOptionCellDelegate

- (void) customCell:(ESConditionOptionCell *)cell btnTag:(NSInteger)selectBtnTag;

@end

@interface ESConditionOptionCell : UITableViewCell
@property (nonatomic, assign) id<ESConditionOptionCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblCondition;
@property (weak, nonatomic) IBOutlet UILabel *lblDetailCondition;
@property (weak, nonatomic) IBOutlet UIButton *btnCircle;


@end
