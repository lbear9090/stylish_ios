//
//  ESMakeFeaturedActivity.h
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESMakeFeaturedActivity;

@protocol ESMakeFeaturedActivityDelegate
- (void)makeFeaturedButtonClicked:(ESMakeFeaturedActivity*)activity;
@end

@interface ESMakeFeaturedActivity : UIActivity

@property (nonatomic, weak) id <ESMakeFeaturedActivityDelegate> delegate;

@end
