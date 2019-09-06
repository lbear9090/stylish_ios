//
//  ESReportItemActivity.m
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESReportItemActivity.h"

@implementation ESReportItemActivity

- (NSString *)activityType
{
    return @"Custom Type";
}

- (NSString *)activityTitle
{
    return @"Report item";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"report_item.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // basically in your case: return YES if activity items are urls
    NSLog(@"report item activity--1");
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"report item activity--2");
    [self.delegate reportItemButtonClicked:self];
    //open safari with urls (activityItems)
}

+(UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare; // says that your icon will belong in application group, not in the lower part;
}


@end
