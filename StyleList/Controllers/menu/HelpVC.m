//
//  HelpVC.m
//  Style List
//
//  Created by admin on 5/18/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "HelpVC.h"
#import "ESGuideVC.h"

@interface HelpVC() {
    int selectedIndex;
}

@end

@implementation HelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Help";
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
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld", indexPath.row);
    selectedIndex = (int)indexPath.row;
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"toGuideSegue" sender:self];
    } else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"toGuideSegue" sender:self];
    } else if (indexPath.row == 2) {
        [self sendMail:@"Feedback"];
    } else {
        [self sendMail:@"Report a problem"];
    }
}

- (void) sendMail:(NSString *) headTitle {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
        NSString *model = [[UIDevice currentDevice] model];
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:[NSArray arrayWithObjects: @"support@yourdomain.com",nil]];
        [mailComposer setSubject:headTitle];
        NSString *supportText = [NSString stringWithFormat:@"Device: %@\niOS Version: %@\nRequester ID: %@\n               _________________\n\n",model,iOSVersion,[[PFUser currentUser]objectId]];
        supportText = [supportText stringByAppendingString: @"Please describe your problem or question. We will answer you within 24 hours. For a flawless treatment of your query, make sure to not delete the above indicated iOS Version and Requester ID.\n               _________________"];
        [mailComposer setMessageBody:supportText isHTML:NO];
        mailComposer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have no active email account on your device - but you can still contact us under:\n\nsupport@yourdomain.com" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toGuideSegue"]) {
        ESGuideVC *myVC = [segue destinationViewController];
        if (selectedIndex == 0) {
            myVC.headString = @"Common Questions";
        } else {
            myVC.headString = @"Guide";
        }
    }
}

@end
