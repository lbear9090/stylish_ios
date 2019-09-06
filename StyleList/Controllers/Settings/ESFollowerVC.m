//
//  ESFollowerVC.m
//  Style List
//
//  Created by admin on 5/16/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESFollowerVC.h"
#import <Parse/Parse.h>
#import "ESFollowTVCell.h"
#import "ESAccountViewController.h"

@interface ESFollowerVC () {
    NSMutableArray *userAry;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ESFollowerVC
@synthesize title, tableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userAry = [[NSMutableArray alloc] init];
    self.navigationItem.title = title;
    
    [self findFollowers];
}

- (void) findFollowers {
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    if ([title isEqualToString:@"Followers"]) {
        [query whereKey:kESActivityToUserKey equalTo:[PFUser currentUser]];
        [query includeKey:kESActivityFromUserKey];
    } else {
        [query whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
        [query includeKey:kESActivityToUserKey];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * _Nullable error) {
        if (objects != nil && objects.count > 0) {
            [userAry addObjectsFromArray:objects];
            [self.tableview reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"followCell";
    ESFollowTVCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfier forIndexPath:indexPath];
    
    PFObject* obj = userAry[indexPath.row];
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser *user;
            user = [obj objectForKey:kESActivityFromUserKey];
            if (![title isEqualToString:@"Followers"]) {
                user = obj[kESActivityToUserKey];
            }
            
            PFFile *file = [user objectForKey:kESUserProfilePicSmallKey];
            if(file != nil){
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        cell.avatarImg.image = [UIImage imageWithData:data];
                    }
                }];
            }            
            cell.nameLbl.text = [user objectForKey:kESUserDisplayNameKey];
        }
    }];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject* obj = userAry[indexPath.row];
    PFUser *user;
    user = [obj objectForKey:kESActivityFromUserKey];
    if (![title isEqualToString:@"Followers"]) {
        user = obj[kESActivityToUserKey];
    }
    ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

@end
