//
//  ESRetweetCell.m
//  StyleList
//
//  Created by Eric Schanet on 11.11.17.
//  Copyright © 2017 Eric Schanet. All rights reserved.
//

#import "ESRetweetCell.h"
#import "TOWebViewController.h"

@implementation ESRetweetCell

@synthesize itemButton;

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
        
        self.imageView.frame = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 90);
        self.imageView.backgroundColor = [UIColor whiteColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.itemButton.frame = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 90);
        self.itemButton.backgroundColor = [UIColor clearColor];
        
        self.retweetLabel = [[UILabel alloc] init];
        self.retweetLabel.text = @"RETWEETED";
        self.retweetLabel.font= [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:10];
        self.retweetLabel.textColor = [UIColor grayColor];
        self.retweetLabel.frame = CGRectMake(11, 0, [UIScreen mainScreen].bounds.size.width - 28,20);

        self.OPName = [[UILabel alloc] init];
        self.OPName.font= [UIFont fontWithName:GTWALSHEIM_BOLD_FONT size:15];
        //self.OPName.textColor = [UIColor colorWithRed:83./255. green:80./255. blue:97./255. alpha:0.8];
        self.OPName.textColor = [UIColor darkGrayColor];
        self.OPName.frame = CGRectMake(10, 15, [UIScreen mainScreen].bounds.size.width - 28,20);
        
        self.OPmentionName = [[KILabel alloc] init];
        self.OPmentionName.font= [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15];
        self.OPmentionName.textColor = [UIColor darkGrayColor];
        self.OPmentionName.frame = CGRectMake(100, 15, [UIScreen mainScreen].bounds.size.width - 28,20);

        self.postText = [[KILabel alloc]init];
        [self.postText setTextColor:[UIColor colorWithRed:55./255. green:55./255. blue:35./255. alpha:1.000]];
        [self.postText setTintColor:[UIColor colorWithRed:54.0f/255.0f green:86.0f/255.0f blue:133.0f/255.0f alpha:1.0f]];
        self.postText.frame = CGRectMake( 10.0f, 30.0f, [UIScreen mainScreen].bounds.size.width - 28, 50);
        self.postText.backgroundColor = [UIColor whiteColor];
        //self.postText.textColor = [UIColor darkGrayColor];
        self.postText.numberOfLines = 5;
        self.postText.layer.borderColor = [UIColor whiteColor].CGColor;
        self.postText.layer.borderWidth = 1.0f;
        self.postText.font= [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15];
        
        [self.contentView addSubview:self.postText];
        [self.contentView addSubview:self.retweetLabel];
        [self.contentView addSubview:self.OPmentionName];
        [self.contentView addSubview:self.OPName];
        [self.contentView addSubview:self.itemButton];
        [self.contentView bringSubviewToFront:self.imageView];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        self.postText.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            // Open URLs
            [weakSelf attemptOpenURL:[NSURL URLWithString:string]];
            NSLog(@"URL:%@",string);
        };
        
        self.postText.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            NSString *str = [string stringByReplacingOccurrencesOfString:@"#"
                                                              withString:@""];
            NSString *lowstr = [str lowercaseString];
            [weakSelf postNotificationWithString:lowstr];
        };
        
        self.postText.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            NSString *mention = [string stringByReplacingOccurrencesOfString:@"@" withString: @""];
            
            [weakSelf postNotificationWithMentionString:mention];
        };


    }
    
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 90);
    self.itemButton.frame = CGRectMake( 0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width,90);
    
}
- (void)attemptOpenURL:(NSURL *)url
{
    [self postNotificationWithWebsiteString:[url absoluteString]];
}
- (void)postNotificationWithString:(NSString *)notification //post notification method and logic
{
    /*--
     * Prefixing a notification name with a unique identifier,
     such as 'HT' for Hashtag, reduces the chances of a message name conflict.
     * Be sure to use a unique and description name for the dictionary's key.
     --*/
    
    NSString *notificationName = @"Hashtag";
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notification forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}
- (void)postNotificationWithMentionString:(NSString *)notification //post notification method and logic
{
    /*--
     * Prefixing a notification name with a unique identifier,
     such as 'HT' for Hashtag, reduces the chances of a message name conflict.
     * Be sure to use a unique and description name for the dictionary's key.
     --*/
    
    NSString *notificationName = @"Mention";
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notification forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}
- (void)postNotificationWithWebsiteString:(NSString *)notification //post notification method and logic
{
    /*--
     * Prefixing a notification name with a unique identifier,
     such as 'HT' for Hashtag, reduces the chances of a message name conflict.
     * Be sure to use a unique and description name for the dictionary's key.
     --*/
    
    NSString *notificationName = @"Website";
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notification forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}
@end


