//
//  ESVideoTableViewCell.m
//  d'Netzwierk
//
//  Created by Eric Schanet on 07.12.14.
//
//

#import "ESVideoTableViewCell.h"

@interface ESVideoTableViewCell(){
    CGRect rectImg;
}
@end

@implementation ESVideoTableViewCell
@synthesize mediaItemButton, binocularsBtn, tagLabel, tagTitleBar, costtagLabel;
@synthesize btnBookmark, lblOwnTag, imgOwnTag, btnHashTag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        rectImg = CGRectMake( 10.0f, 10.0f, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20);
        self.imageView.frame = rectImg;
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.movie = [[MPMoviePlayerController alloc] init];
        self.movie.controlStyle = MPMovieControlStyleEmbedded;
        self.movie.scalingMode = MPMovieScalingModeAspectFit;
        [self.contentView addSubview:self.movie.view];
        
        self.binocularsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.binocularsBtn setFrame:CGRectMake(rectImg.size.width - 50, rectImg.origin.y + 10 , 50, 25)];
        [self.binocularsBtn setImage:[UIImage imageNamed:@"binoculars.png"] forState:UIControlStateNormal];
        
        self.tagTitleBar = [[UIView alloc] init];
        self.tagLabel = [[UILabel alloc] init];
        [self.tagLabel setFont:[UIFont fontWithName:GTWALSHEIM_BOLD_FONT size:18]];
        [self.tagLabel setTextColor:[UIColor blackColor]];
        
        btnBookmark = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBookmark setImage:[UIImage imageNamed:@"bookmark_gold.png"] forState:UIControlStateNormal];
        [btnBookmark setBackgroundColor:[UIColor redColor]];
        
        btnHashTag = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnHashTag setBackgroundColor:[UIColor clearColor]];
        
        imgOwnTag = [[UIImageView alloc]init];
        imgOwnTag.image = [UIImage imageNamed:@"hand.png"];
        
        lblOwnTag = [[UILabel alloc]init];
        [lblOwnTag setFont:[UIFont fontWithName:GTWALSHEIM_BOLD_FONT size:11.0f]];
        [lblOwnTag setTextColor:[UIColor blackColor]];
        
        
        self.costtagLabel = [[UILabel alloc] init];
        [self.costtagLabel setFont:[UIFont fontWithName:GTWALSHEIM_BOLD_FONT size:18]];
        [self.costtagLabel setTextColor:COLOR_GOLD];
        
        [self.tagTitleBar addSubview:btnBookmark];
        [self.tagTitleBar addSubview:lblOwnTag];
        [self.tagTitleBar addSubview:imgOwnTag];
        [self.tagTitleBar addSubview:self.tagLabel];
        [self.tagTitleBar addSubview:self.costtagLabel];
        [self.tagTitleBar addSubview:btnHashTag];
        
        self.tagTitleBar.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.7];
        self.tagTitleBar.hidden = YES;
        [self.imageView addSubview:self.tagTitleBar];
        
        [self.contentView bringSubviewToFront:self.imageView];
        
        self.mediaItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.mediaItemButton.frame = rectImg;
        self.mediaItemButton.backgroundColor = [UIColor clearColor];
        [self.mediaItemButton setImage:[UIImage imageNamed:@"play_alt-512"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.mediaItemButton];
        [self.contentView addSubview:self.binocularsBtn];

    }
    
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self.movie.view.frame = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
}

@end
