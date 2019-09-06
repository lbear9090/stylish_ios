//
//  ESConditionOptionCell.m
//  Style List
//
//  Created by 123 on 5/8/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESConditionOptionCell.h"

@implementation ESConditionOptionCell
@synthesize delegate;
@synthesize lblCondition, lblDetailCondition, btnCircle;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)onSelectCondition:(UIButton *)sender {
    NSInteger tag = sender.tag;
    NSLog(@"button tag --- %ld", (long)tag);

    if (self.delegate) {
        [self.delegate customCell:self btnTag:sender.tag];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
