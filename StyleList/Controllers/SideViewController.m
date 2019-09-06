//
//  SideViewController.m


#import "SideViewController.h"
#import "MMSideDrawerTableViewCell.h"
#import "MMSideDrawerSectionHeaderView.h"
#import "ESFindFriendsCell.h"
#import "ESAccountViewController.h"
#import "ESProfileImageView.h"
#import "MFSideMenu.h"
#import "ESSideTableViewCell.h"
#import "MBProgressHUD.h"


@implementation SideViewController
@synthesize _tableView,navController,hud, mbhud;
#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {

    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated {
    [self._tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 140, self.view.bounds.size.width-45, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    
    [self._tableView setDelegate:self];
    [self._tableView setDataSource:self];
    [self.view addSubview:self._tableView];
    [self._tableView setBackgroundColor:[UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0]];
    self.view.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    
    [self.view addSubview:_tableView];
    
    UIImage *logoImg = [[UIImage imageNamed:@"main-logo.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *imgLogo = [[UIImageView alloc] initWithImage:logoImg];
    [imgLogo setBackgroundColor:[UIColor clearColor]];
    [imgLogo setFrame:CGRectMake(self.view.bounds.size.width/4-37, 60, 90, 90)];
    [self.view addSubview:imgLogo];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
}


- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[[notification userInfo] objectForKey:@"eventType"] intValue];
    if (event == MFSideMenuStateEventMenuDidOpen) {
        [self._tableView reloadData];
    }
}

#pragma mark - UITableView Data source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 3;
        case 3:
            return 3;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    ESSideTableViewCell *cell = (ESSideTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[ESSideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:17];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
//            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, cell.bounds.size.width-40, cell.bounds.size.height)];
//            nameLabel.textColor = [UIColor whiteColor];
            ESProfileImageView *avatarImageView = [[ESProfileImageView alloc] init];
            avatarImageView.frame = CGRectMake( 4.0f, 0.0f, 35.0f, 35.0f);
            PFUser *user = [PFUser currentUser];
            PFFile *profilePictureSmall = [user objectForKey:kESUserProfilePicSmallKey];
            [avatarImageView setFile:profilePictureSmall];
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
            avatarImageView.layer.masksToBounds = true;
            [cell.contentView addSubview:avatarImageView];
            if ([user objectForKey:kESUserDisplayNameKey]) {
                cell.textLabel.text = [user objectForKey:kESUserDisplayNameKey];
            }
            else {
                cell.textLabel.text = [user objectForKey:@"username"];
            }
        }
    }
    
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Transactions", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_transactions"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"Bookmarks", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_bookmarks"]];
            avatarImageView.alpha =  0.4;
            [cell.contentView addSubview:avatarImageView];
        }
    }
    else if(indexPath.section == 2){
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Help", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_help"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
            
//            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
//            avatarImageView.layer.masksToBounds = true;
//            [avatarImageView setBackgroundColor:[UIColor whiteColor]];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Terms of Use", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_terms"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
            
//            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
//            avatarImageView.layer.masksToBounds = true;
//            [avatarImageView setBackgroundColor:[UIColor whiteColor]];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Contact Us", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_contact"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
            
//            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
//            avatarImageView.layer.masksToBounds = true;
//            [avatarImageView setBackgroundColor:[UIColor whiteColor]];
        }
        
    }
    
    else if(indexPath.section == 3){
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Find Friends", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_friends"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_settings"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Log Out", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"m_logout"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
            hud = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            hud.frame = CGRectMake(180, 10, 25, 25);
            [cell.contentView addSubview:hud];
        }
    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Popular", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"icon-fire"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Recent", nil);
            UIImageView *avatarImageView = [[UIImageView alloc] init];
            avatarImageView.frame = CGRectMake( 10.0f, 10.0f, 20.0f, 20.0f);
            [avatarImageView setImage:[UIImage imageNamed:@"iconclock"]];
            avatarImageView.alpha = 0.5;
            [cell.contentView addSubview:avatarImageView];
        }
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) { // profile
            [self postNotificationWithString:@"ProfileOpen"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) { // translations
            [self postNotificationWithString:@"openTransactions"];
        }
        else if (indexPath.row == 1) { // bookmarks
            [self postNotificationWithString:@"OpenRecentFeed"];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0) { //help
            [self postNotificationWithString:@"openHelp"];
        } else if (indexPath.row == 1) { // terms of use
            [self postNotificationWithString:@"termsofuse"];
        } else if (indexPath.row == 2){// contact us
            [self postNotificationWithString:@"MailUs"];
        }        
    }
    else {
        if (indexPath.row == 0) {
            [self postNotificationWithString:@"FindFriendsOpen"];
        }
        else if (indexPath.row == 1) {
            [self postNotificationWithString:@"OpenSettings"];
        }
        else if (indexPath.row == 2) {
            self.mbhud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
            self.mbhud.labelText = NSLocalizedString(@"Logging out...", nil);
            self.mbhud.labelFont = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15.0f];
            self.mbhud.dimBackground = YES;
            [self performSelector:@selector(dummyLogout) withObject:nil afterDelay:0.2];
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35.0)];
    header.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0];
    if (section == 0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 35.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = NSLocalizedString(@"PROFILE", nil);
        titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14];
        titleLabel.textColor = COLOR_GOLD;
        [header addSubview:titleLabel];
        return header;
    } else if (section == 1) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 35.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"ACTIVITY", nil)];
        [titleLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14]];
        titleLabel.textColor = COLOR_GOLD;
        [header addSubview:titleLabel];
        return header;
    } else if (section == 2) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 35.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SUPPORT", nil)];
        [titleLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14]];
        titleLabel.textColor = COLOR_GOLD;
        [header addSubview:titleLabel];
        return header;
    } else if (section == 3) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 35.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SETTINGS", nil)];
        [titleLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14]];
        titleLabel.textColor = COLOR_GOLD;
        [header addSubview:titleLabel];
        return header;
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView setSeparatorColor:[UIColor clearColor]];
    return 35.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0;
}
- (void)postNotificationWithString:(NSString *)notification //post notification method and logic
{

    NSString *notificationName = @"ESNotification";
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notification forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

- (void) dummyLogout {
    [self postNotificationWithString:@"LogHimOut"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
