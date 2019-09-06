//
//  ESPhotoEditorDetailsFooterView.m
//  Style List
//
//  Created by 123 on 3/3/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESPhotoEditorDetailsFooterView.h"

@implementation ESPhotoEditorDetailsFooterView

@synthesize commentFieldEditor;
@synthesize mainViewEditor;
@synthesize hideDropShadowEditor;
@synthesize categoryView, categorySubView,customView, lblCategoryItem, lblYourCurrentItem, txtCategoryName, btnDown;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //========== category view=======//
    
        categoryView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 100.0f)];
        categoryView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [self addSubview:categoryView];
        lblYourCurrentItem = [[UILabel alloc]initWithFrame:CGRectMake(5.0f, 5.0f, [UIScreen mainScreen].bounds.size.width -50, 30.0f)];
        lblYourCurrentItem.text = @"What sale type is this item?";
        lblYourCurrentItem.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14.0f];
        [categoryView addSubview:lblYourCurrentItem];
        categorySubView = [[UIView alloc]initWithFrame:CGRectMake(5.0f, lblYourCurrentItem.frame.size.height+5.0f, [UIScreen mainScreen].bounds.size.width, 40.0f)];
        categorySubView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [categoryView addSubview:categorySubView];
        txtCategoryName = [[UITextField alloc]initWithFrame:CGRectMake(0.0f, 0.0f, categorySubView.frame.size.width-100.0f, categorySubView.frame.size.height)];
        [txtCategoryName.layer setBorderColor:[UIColor blackColor].CGColor];
        [txtCategoryName.layer setBorderWidth:1.0f];
        txtCategoryName.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:13.0f];
        txtCategoryName.placeholder = @" Select";
        [categorySubView addSubview:txtCategoryName];
        btnDown = [[UIButton alloc]initWithFrame:CGRectMake(categorySubView.frame.size.width-130.0f, 5.0f, 30.0f, 30.0f)];
        [btnDown setImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateNormal];
        [categorySubView addSubview:btnDown];
     
        
        mainViewEditor = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 80.0f, [UIScreen mainScreen].bounds.size.width, 51.0f)]; //10, 300
        mainViewEditor.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
        [self addSubview:mainViewEditor];
        
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconAddComment"]];
        messageIcon.frame = CGRectMake( 9.0f, 17.0f, 19.0f, 17.0f);
        [mainViewEditor addSubview:messageIcon];
        
        UIImageView *commentBox = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"TextFieldComment"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0f, 10.0f, 5.0f, 10.0f)]];
        commentBox.backgroundColor = [UIColor whiteColor];
        commentBox.frame = CGRectMake(35.0f, 8.0f, [UIScreen mainScreen].bounds.size.width - 50, 35.0f);
        [mainViewEditor addSubview:commentBox];
        
        commentFieldEditor = [[UITextField alloc] initWithFrame:CGRectMake( 40.0f, 10.0f, [UIScreen mainScreen].bounds.size.width - 55, 31.0f)];
        commentFieldEditor.font = [UIFont systemFontOfSize:14.0f];
        commentFieldEditor.placeholder = NSLocalizedString(@"Add a comment", nil);
        commentFieldEditor.returnKeyType = UIReturnKeySend;
        commentFieldEditor.textColor = [UIColor darkGrayColor];
        commentFieldEditor.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [commentFieldEditor setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
        [mainViewEditor addSubview:commentFieldEditor];
        
        customView = [[UIView alloc]initWithFrame:CGRectMake(5.0f, 75.0f, txtCategoryName.frame.size.width, 90.0f)];
        
        [customView setHidden:YES];
        [self addSubview:customView];
    }
    return self;
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!hideDropShadowEditor) {
        [ESUtility drawSideAndBottomDropShadowForRect:mainViewEditor.frame inContext:UIGraphicsGetCurrentContext()];
    }
}


#pragma mark - ESPhotoDetailsFooterView

+ (CGRect)rectForViewEditor {
 
    return CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 169.0f);
 
}


@end
