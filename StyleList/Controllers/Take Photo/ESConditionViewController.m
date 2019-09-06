//
//  ESConditionViewController.m
//  Style List
//
//  Created by 123 on 5/8/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESConditionViewController.h"
#import "ESConditionOptionCell.h"

@interface ESConditionViewController (){
    NSArray *arrCondition;
    NSArray *arrDetailCondition;
    NSInteger selectConditionBtnTag;
}

@end

@implementation ESConditionViewController
@synthesize tblCondition;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    ESCache *shared = [ESCache sharedCache];
    shared.conditionOption = @"";
    selectConditionBtnTag = -1;
    arrCondition       = [NSArray arrayWithObjects: @"New with tags",
                                                    @"New",
                                                    @"Very good",
                                                    @"Good",
                                                    @"Satisfactory",nil];
    arrDetailCondition = [NSArray arrayWithObjects: @"Never worn, tags attached",
                                                    @"Not worn, but not tags",
                                                    @"Worn but still looks great",
                                                    @"Found tiny flaws, which I noted in my listing and made visible in my pictures",
                                                    @"It has some flaws, all noted in the description and visible in pics",nil];
//    arrDetailCondition = [NSArray arrayWithObjects: @"Never worn",
//                          @"Not worns",
//                          @"Worn but",
//                          @"Found tiny",
//                          @"It has ",nil];
}
#pragma mark - Delegate Method.
- (void)customCell:(ESConditionOptionCell *)cell btnTag:(NSInteger)selectBtnTag{
    NSLog(@"select button tag -- %ld", (long)selectBtnTag);
    ESCache *shared = [ESCache sharedCache];
    shared.conditionOption = [arrCondition objectAtIndex:selectBtnTag];
    selectConditionBtnTag = selectBtnTag;
    [tblCondition reloadData];
}

#pragma mark - UITableViewDelegate Method.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrCondition count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESConditionOptionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"conditionCell"];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ESConditionOptionCell" bundle:nil] forCellReuseIdentifier:@"conditionCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"conditionCell"];
       
    }
    cell.delegate = self;
    cell.btnCircle.tag = indexPath.row;
    cell.lblCondition.text = [arrCondition objectAtIndex:indexPath.row];
    cell.lblDetailCondition.text = [arrDetailCondition objectAtIndex:indexPath.row];
    
    if (selectConditionBtnTag == -1) {
        [cell.btnCircle setImage:[UIImage imageNamed:@"btn_circle_dis.png"] forState:UIControlStateNormal];
    }else{
        if (selectConditionBtnTag == indexPath.row) {
            [cell.btnCircle setImage:[UIImage imageNamed:@"btn_circle_ena.png"] forState:UIControlStateNormal];
        }else{
            [cell.btnCircle setImage:[UIImage imageNamed:@"btn_circle_dis.png"] forState:UIControlStateNormal];
        }
    }
    return cell;
    
}

#pragma mark - back option.
- (IBAction)backClicked:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    if ([shared.conditionOption isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please select condition option." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self dismissESConditionVC];
    }
    
}

- (void)dismissESConditionVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
