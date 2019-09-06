//
//  ESMessageSellerActivity.m
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESMessageSellerActivity.h"

@implementation ESMessageSellerActivity

- (NSString *)activityType
{
    return @"Custom Type";
}

- (NSString *)activityTitle
{
    return @"Message seller";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"msgseller.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // basically in your case: return YES if activity items are urls
    NSLog(@"message seller activity--1");
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"message seller activity--2");
    PFObject *photo = [activityItems objectAtIndex:1];
    PFUser *seller = [photo objectForKey:kESPhotoUserKey];
    [self.delegate msgSellerButtonClicked:self seller:seller];
    //open safari with urls (activityItems)
}

+(UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare; // says that your icon will belong in application group, not in the lower part;
}

@end
