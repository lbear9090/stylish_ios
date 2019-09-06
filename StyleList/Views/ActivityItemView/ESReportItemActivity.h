//
//  ESReportItemActivity.h
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESReportItemActivity;

@protocol ESReportItemActivityDelegate
- (void)reportItemButtonClicked:(ESReportItemActivity*)activity;
@end

@interface ESReportItemActivity : UIActivity

@property (nonatomic, weak) id <ESReportItemActivityDelegate> delegate;

@end
