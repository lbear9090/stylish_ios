//
//  ESPhotoCell.m
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

#import "ESPhotoCell.h"
#import "ESUtility.h"
@interface ESPhotoCell(){
    CGRect rectImg;
    CGRect binoRect;
    CGRect mediaRect;
}
@end

@implementation ESPhotoCell
@synthesize mediaItemButton, singleTap, doubleTap, binocularsBtn, tagLabel, tagTitleBar, costtagLabel;
@synthesize btnBookmark, lblOwnTag, imgOwnTag, btnHashTag;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
 
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor whiteColor];
        rectImg = CGRectMake( 10.0f, 10.0f, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20);

        self.imageView.frame = rectImg;
        self.imageView.backgroundColor = HEXCOLOR(0xFFFFFFFF);
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imageView setClipsToBounds:YES];
        self.imageView.layer.cornerRadius = 10;
        
        self.mediaItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mediaItemButton.frame = rectImg;
        self.mediaItemButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mediaItemButton];
        
        self.binocularsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.binocularsBtn setFrame:CGRectMake(rectImg.size.width - 50, rectImg.origin.y + 10 , 50, 25)];
//        [binocularsBtn setImage:[UIImage imageNamed:@"binoculars.png"] forState:UIControlStateNormal];
        
        self.tagTitleBar = [[UIView alloc] init];
        self.tagLabel = [[UILabel alloc] init];
        [self.tagLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]];
        [self.tagLabel setTextColor:[UIColor blackColor]];
        
        btnBookmark = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBookmark setImage:[UIImage imageNamed:@"bookmark_gold.png"] forState:UIControlStateNormal];
        [btnBookmark setBackgroundColor:[UIColor clearColor]];
        
        btnHashTag = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnHashTag setBackgroundColor:[UIColor clearColor]];
        
        imgOwnTag = [[UIImageView alloc]init];
        imgOwnTag.image = [UIImage imageNamed:@"hand.png"];
        
        lblOwnTag = [[UILabel alloc]init];
        [lblOwnTag setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:11.0f]];
        [lblOwnTag setTextColor:[UIColor blackColor]];
        
        self.costtagLabel = [[UILabel alloc] init];
        [self.costtagLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:18]];
        [self.costtagLabel setTextColor:COLOR_GOLD];
        
        
        [self.tagTitleBar addSubview:lblOwnTag];
        [self.tagTitleBar addSubview:imgOwnTag];
        [self.tagTitleBar addSubview:self.tagLabel];
        [self.tagTitleBar addSubview:self.costtagLabel];

        
        self.tagTitleBar.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.7];
        self.tagTitleBar.hidden = YES;
        [self.imageView addSubview:self.tagTitleBar];
        
        [self.contentView bringSubviewToFront:self.imageView];
        [self.contentView addSubview:btnHashTag];
        [self.contentView addSubview:btnBookmark];
        [self.contentView addSubview:self.binocularsBtn];
        
        btnHashTag.hidden  = YES;
        btnBookmark.hidden = YES;
        
        singleTap = [[UITapGestureRecognizer alloc] init];
        singleTap.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer:singleTap];
        
        doubleTap = [[UITapGestureRecognizer alloc] init];
        doubleTap.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }

    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = rectImg;
    self.mediaItemButton.frame = rectImg;
    
}

@end
