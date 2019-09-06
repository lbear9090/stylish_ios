//
//  ESLocationViewController.m
//  Style List
//
//  Created by 123 on 4/2/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESLocationViewController.h"

@interface ESLocationViewController (){
    NSArray *arrLocationName;
}

@end

@implementation ESLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    NSString *csvFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"country" ofType:@"csv"] encoding:NSUTF8StringEncoding error:nil];
    arrLocationName = [[csvFile componentsSeparatedByString:@"\n"] mutableCopy];
}

- (IBAction)btnCancelClicked:(id)sender {
    
    [self dismissESLocationVC];
}

#pragma tableview delegate method.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrLocationName.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier] ;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[arrLocationName objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:17.0f];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESCache *shared = [ESCache sharedCache];
    shared.selectedLocationInfoName = [arrLocationName objectAtIndex:indexPath.row];
    [self dismissESLocationVC];
}

- (void)dismissESLocationVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
