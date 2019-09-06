//
//  TransactionsVC.m
//  Style List
//
//  Created by admin on 5/18/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "TransactionsVC.h"
#import "ESTransactionsTVCell.h"
#import "ProgressHUD.h"

@interface TransactionsVC () {
    NSMutableArray *transactionAry;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation TransactionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Transactions";
    transactionAry = [[NSMutableArray alloc] init];
    [self fetchTransactions];
}

- (void) fetchTransactions {
    [ProgressHUD show:@"" Interaction:NO];
    PFQuery *query1 = [PFQuery queryWithClassName:@"Transaction"];
    [query1 whereKey:@"buyer" equalTo:[PFUser currentUser]];
    [query1 includeKey:@"owner"];
    [query1 includeKey:@"buyer"];
//    [query1 orderByDescending:@"createdAt"];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [ProgressHUD dismiss];
        if (objects != nil && objects.count > 0) {
            [transactionAry addObjectsFromArray:objects];
            [self.tableview reloadData];
            [self fetchSecondQuery];
        }
    }];
    
//    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
}

- (void)fetchSecondQuery {
    PFQuery *query2 = [PFQuery queryWithClassName:@"Transaction"];
    [query2 whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query2 includeKey:@"buyer"];
    [query2 includeKey:@"owner"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects != nil && objects.count > 0) {
            [transactionAry addObjectsFromArray:objects];
            [self.tableview reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return transactionAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"transactionsCell";
    NSString * type = @"purchased";
    ESTransactionsTVCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfier forIndexPath:indexPath];    
    PFObject *obj = transactionAry[indexPath.row];
    PFUser *user = [obj objectForKey:@"buyer"];
    if (![user isEqual:[PFUser currentUser]]) { /////!//
        user = [obj objectForKey:@"owner"];
        type = @"sold";
    }
    
    NSString *name = [user objectForKey:kESUserDisplayNameKey];
    PFFile *file = [user objectForKey:kESUserProfilePicSmallKey];
    if(file != nil){
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(error== nil && data != nil){
                cell.avatarImg.image = [UIImage imageWithData:data];
            }
        }];
    }
    NSString *price = [NSString stringWithFormat:@"($%@)", [obj objectForKey:@"price"]];
    NSString *item = [obj objectForKey:@"type"];
    NSString *displayTxt = [NSString stringWithFormat:@"%@ purchased %@ from you %@", name, item, price];
    if ([type isEqualToString: @"sold"]) {
        displayTxt = [NSString stringWithFormat:@"%@ sold %@ to you %@", name, item, price];
    }
    
    NSDictionary *attribs = @{NSForegroundColorAttributeName: cell.descriptionLbl.textColor,
                              NSFontAttributeName: cell.descriptionLbl.font};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:displayTxt
                                           attributes:attribs];
    
    UIFont *boldFont = [UIFont boldSystemFontOfSize:14.0];
    NSRange txtRange1 = [displayTxt rangeOfString:name];
    [attributedText setAttributes:@{NSFontAttributeName:boldFont}
                            range:txtRange1];
    NSRange txtRange2 = [displayTxt rangeOfString:item];
    [attributedText setAttributes:@{NSFontAttributeName:boldFont}
                            range:txtRange2];
    NSRange txtRange3 = [displayTxt rangeOfString:price];
    [attributedText setAttributes:@{NSFontAttributeName:boldFont}
                            range:txtRange3];
    
//    cell.descriptionLbl.text = displayTxt;
    cell.descriptionLbl.attributedText = attributedText;
    
    NSDate *date = [obj createdAt];
    cell.dateLbl.text = [self getDateString:date];
    return cell;
}

- (NSString *)getDateString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"dd MMMM YYYY"];
    return [dateFormatter stringFromDate:date];
}

@end
