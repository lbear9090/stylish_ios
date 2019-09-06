//
//  ESDeleteItemActivity.m
//  Style List
//
//  Created by 123 on 5/24/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESDeleteItemActivity.h"

@implementation ESDeleteItemActivity

- (NSString *)activityType
{
    return @"Custom Type";
}

- (NSString *)activityTitle
{
    return @"Delete item";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"delete_item.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    // basically in your case: return YES if activity items are urls
    NSLog(@"delete item activity--1");
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    //open safari with urls (activityItems)
    NSLog(@"delete item activity--2");
    PFObject *obj = [activityItems objectAtIndex:1];
    [self.delegate deleteItemButtonClicked:self deleteObj:obj];
}

+(UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare; // says that your icon will belong in application group, not in the lower part;
}

@end
