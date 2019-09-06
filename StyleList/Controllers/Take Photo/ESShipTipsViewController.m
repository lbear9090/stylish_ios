//
//  ESShipTipsViewController.m
//  Style List
//
//  Created by 123 on 3/10/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESShipTipsViewController.h"

@interface ESShipTipsViewController ()

@end

@implementation ESShipTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
