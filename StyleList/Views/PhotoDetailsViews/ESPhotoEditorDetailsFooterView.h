//
//  ESPhotoEditorDetailsFooterView.h
//  Style List
//
//  Created by 123 on 3/3/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESPhotoEditorDetailsFooterView : UIView

/**
 *  Textfield in which the comment is typed
 */
@property (nonatomic, strong) UITextField *commentFieldEditor;
/**
 *  Wether we hide the shadow or not
 */
@property (nonatomic) BOOL hideDropShadowEditor;
/**
 *  Container view of the header
 */
@property (nonatomic, strong) UIView *mainViewEditor;
/**
 *  Defining the size of the footer
 *
 *  @return size of the footer
 */
@property (strong, nonatomic) UIView *categoryView;
@property (strong, nonatomic) UILabel *lblYourCurrentItem;
@property (strong, nonatomic) UILabel *lblCategoryItem;
@property (strong, nonatomic) UIView *categorySubView;
@property (strong, nonatomic) UIView *customView;
@property (strong, nonatomic) UITextField *txtCategoryName;
@property (strong, nonatomic) UIButton *btnDown;

+ (CGRect)rectForViewEditor;
@end
