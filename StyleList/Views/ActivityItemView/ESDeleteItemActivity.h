//
//  ESDeleteItemActivity.h
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESDeleteItemActivity;

@protocol ESDeleteItemActivityDelegate
- (void)deleteItemButtonClicked:(ESDeleteItemActivity*)activity deleteObj:(PFObject *)obj;
@end

@interface ESDeleteItemActivity : UIActivity

@property (nonatomic, weak) id <ESDeleteItemActivityDelegate> delegate;

@end
