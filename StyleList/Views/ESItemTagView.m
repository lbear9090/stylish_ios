//
//  ESItemTagView.m
//  Style List
//
//  Created by 123 on 3/17/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESItemTagView.h"

@implementation ESItemTagView
@synthesize tagLabel, costtagLabel, btnBookmark,btnHashTag,btnOwnTag, lblOwnTag;
@synthesize delegate;

- (id)init:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [self init];
    if(self){
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.80f];
        [self.layer setCornerRadius:5.0f];
        self.layer.masksToBounds = YES;
        tagLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 15.0f)];
        tagLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:13.0f];
        tagLabel.text = @"";
        [tagLabel setTextAlignment:UITextAlignmentCenter];
        
        costtagLabel = [[UILabel alloc]initWithFrame:CGRectMake(80.0f, 0.0f, 60.0f, 15.0f)];
        costtagLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:10.0f];
        [costtagLabel setTextColor:COLOR_GOLD];
        costtagLabel.text = @"";
        [costtagLabel setTextAlignment:UITextAlignmentCenter];
        
        btnBookmark = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
//        [btnBookmark setImage:[UIImage imageNamed:@"bookmark_gold.png"] forState:UIControlStateNormal];
        [btnBookmark setBackgroundColor:[UIColor clearColor]];
        [btnBookmark addTarget:self action:@selector(btnBookmarkClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        btnHashTag = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 140.0f, 30.0f)];
        [btnHashTag setBackgroundColor:[UIColor clearColor]];
        [btnHashTag addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        btnOwnTag = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        [btnOwnTag setBackgroundColor:[UIColor clearColor]];
//        [btnOwnTag setImage:[UIImage imageNamed:@"hand.png"] forState:UIControlStateNormal];
        [btnOwnTag addTarget:self action:@selector(btnOwnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        lblOwnTag = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 15.0f, 140.0f,15.0f)];
        lblOwnTag.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:10.0f];
        lblOwnTag.text = @"";
        [lblOwnTag setTextAlignment:UITextAlignmentCenter];
        
        [self addSubview:tagLabel];
        [self addSubview:costtagLabel];
        [self addSubview:btnBookmark];
        [self addSubview:lblOwnTag];
        [self addSubview:btnOwnTag];
        [self addSubview:btnHashTag];
    }
    
    return self;
}

- (void)clicked:(UIButton *)sender {
    [self.delegate hashTagButtonClicked:self hashTagBtnTag:sender];
}

- (void)btnBookmarkClicked:(UIButton *)sender{
    [self.delegate bookmarkButtonClicked:self bookmarkBtnTag:sender];
}

- (void)btnOwnClicked:(UIButton *)sender{
    [self.delegate ownButtonClicked:self ownBtnTag:sender];
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


@end
