//
//  ESGuideVC.m
//  Style List
//
//  Created by admin on 5/18/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESGuideVC.h"

@interface ESGuideVC () {
    
    __weak IBOutlet UITextView *txtview;
}

@end

@implementation ESGuideVC
@synthesize headString;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = headString;
    
    if ([headString isEqualToString:@"Guide"]) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
