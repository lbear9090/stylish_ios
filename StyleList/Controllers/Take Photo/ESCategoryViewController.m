//
//  ESCategoryViewController.m
//  Style List
//
//  Created by 123 on 3/26/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESCategoryViewController.h"

@interface ESCategoryViewController ()
{
    NSArray *arrCategoryName;
}

@end

@implementation ESCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    arrCategoryName = [NSArray arrayWithObjects: @"shoes", @"suit", @"dress", @"shirt",@"pants",@"skirt",@"jacket",@"blazer",@"accessories",@"bags", nil];
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissESCategoryVC];
}

#pragma tableview delegate method.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrCategoryName.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier] ;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[arrCategoryName objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:17.0f];
   
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESCache *shared = [ESCache sharedCache];
    shared.selectedCategoryName = [arrCategoryName objectAtIndex:indexPath.row];
    [self dismissESCategoryVC];
}

- (void)dismissESCategoryVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
