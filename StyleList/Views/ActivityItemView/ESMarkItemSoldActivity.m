//
//  ESMarkItemSoldActivity.m
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESMarkItemSoldActivity.h"

@implementation ESMarkItemSoldActivity

- (NSString *)activityType
{
    return @"Custom Type";
}

- (NSString *)activityTitle
{
    return @"Mark item as sold";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"mark_item.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // basically in your case: return YES if activity items are urls
    NSLog(@"mark item sold activity--1");
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //open safari with urls (activityItems)
    NSLog(@"mark item sold activity--2");
    [self.delegate markItemSoldButtonClicked:self];
}

+(UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare; // says that your icon will belong in application group, not in the lower part;
}

@end
