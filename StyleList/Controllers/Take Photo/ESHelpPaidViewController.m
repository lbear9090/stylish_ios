//
//  ESHelpPaidViewController.m
//  Style List
//
//  Created by 123 on 3/6/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESHelpPaidViewController.h"

@interface ESHelpPaidViewController ()

@end

@implementation ESHelpPaidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
}
- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
