//
//  ESMessageSellerActivity.h
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESMessageSellerActivity;

@protocol ESMessageSellerActivityDelegate
- (void)msgSellerButtonClicked:(ESMessageSellerActivity*)activity seller:(PFUser*)user;
@end

@interface ESMessageSellerActivity : UIActivity

@property (nonatomic, weak) id <ESMessageSellerActivityDelegate> delegate;

@end
