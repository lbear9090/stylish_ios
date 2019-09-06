//
//  ESItemTagView.h
//  Style List
//
//  Created by 123 on 3/17/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESItemTagView;

@protocol ESItemTagViewDelegate
- (void)hashTagButtonClicked:(ESItemTagView*)view hashTagBtnTag:(UIButton*)buttonTag;
- (void)bookmarkButtonClicked:(ESItemTagView*)view bookmarkBtnTag:(UIButton*)buttonTag;
- (void)ownButtonClicked:(ESItemTagView*)view ownBtnTag:(UIButton*)buttonTag;
@end

@interface ESItemTagView : UIView

@property (nonatomic, strong) UIButton              *btnBookmark;
@property (nonatomic, strong) UIButton              *btnHashTag;
@property (nonatomic, strong) UIView                *tagTitleBar;
@property (nonatomic, strong) UILabel               *tagLabel;
@property (nonatomic, strong) UILabel               *costtagLabel;
@property (nonatomic, strong) UIButton              *btnOwnTag;
@property (nonatomic, strong) UILabel               *lblOwnTag;
@property (nonatomic, weak) id <ESItemTagViewDelegate>       delegate;
- (void)clicked:(UIButton *)sender;
- (void)btnBookmarkClicked:(UIButton *)sender;
- (void)btnOwnClicked:(UIButton *)sender;
- (id)init:(CGRect)frame;

@end
