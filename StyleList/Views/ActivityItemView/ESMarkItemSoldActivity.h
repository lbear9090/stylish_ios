//
//  ESMarkItemSoldActivity.h
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESMarkItemSoldActivity;

@protocol ESMarkItemSoldActivityDelegate
- (void)markItemSoldButtonClicked:(ESMarkItemSoldActivity*)activity;
@end

@interface ESMarkItemSoldActivity : UIActivity

@property (nonatomic, weak) id <ESMarkItemSoldActivityDelegate> delegate;

@end
