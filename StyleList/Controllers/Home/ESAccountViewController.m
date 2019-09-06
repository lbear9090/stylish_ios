//
//  ESAccountViewController.m

#define HeaderHeight 265.0f
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#import "ESAccountViewController.h"
#import "ESPhotoCell.h"
#import "TTTTimeIntervalFormatter.h"
#import "ESLoadMoreCell.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+ResizeAdditions.h"
#import "ESEditPhotoViewController.h"
#import "SCLAlertView.h"
#import "ESEditProfileViewController.h"
#import "ESMessengerView.h"
#import "MMDrawerBarButtonItem.h"
#import "MFSideMenu.h"
#import "AppDelegate.h"
#import "KILabel.h"
#import "TOWebViewController.h"
#import "ESFollowersViewController.h"
#import "ESEditStyleViewController.h"
#import "ESImageView.h"
#import "ESFollowerVC.h"

CGFloat const offset_HeaderStop = 40.0;
CGFloat const offset_B_LabelHeader = 0.0;
CGFloat const distance_W_LabelHeader = 35.0;
BOOL blocked = FALSE;

@implementation ESAccountViewController
@synthesize headerView, user, profilePictureImageView, backgroundImageView, reportUser, userDisplayNameLabel, infoLabel, userMentionLabel, profilePictureBackgroundView, siteLabel, whiteBackground, grayLine, texturedBackgroundView, photoCountLabel, followerCountLabel, followingCountLabel, editProfileBtn, editStyleBtn, cityLabel, segmentedControl, followerBtn, followingBtn, photosBtn, privateMessageBtn, allBtn, forSaleBtn, forHireBtn, btnBackgroundView, btnFilter, btnList, filterView;

#pragma mark - UIViewController
-(void)tapBtn {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:^{}];
    
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"yourStyleUpdated" object:nil];
}

- (void)styleupatedAfterAction:(NSNotification *)notification {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleupatedAfterAction:) name:@"yourStyleUpdated" object:nil];
    
    [self loadObjects];
    //===========objectId of selected user===============//
    ESCache *shared = [ESCache sharedCache];
    NSString *strUserId = [NSString stringWithFormat:@"%@",[self.user valueForKey:@"objectId"]];
    shared.selectedUserId = strUserId;
    //===========Gender of selected user================//
    NSString *strGender = [NSString stringWithFormat:@"%@",[self.user objectForKey:@"Gender"]];
    shared.selectedUserGender = strGender;
    
    //============ For Inspiration objects=======//
    [self clearColorButton];
    [allBtn setBackgroundColor:COLOR_GOLD];
    [self addPhotoObjects:FORINSPIRATION];
    
    //===========================================//
        
    NSString *selectedFlag = [[NSUserDefaults standardUserDefaults] stringForKey:@"SelectFlag"];
    if ([selectedFlag isEqualToString:@""]){
        
    }else if ([selectedFlag isEqualToString: @"SelectedMyStyle"]){
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"SelectFlag"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ESEditStyleViewController *styleViewController = [sb instantiateViewControllerWithIdentifier:@"EditStyleVC"];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:styleViewController];
        [self presentViewController:navController animated:YES completion:nil];
    
    }
    
    //======================================================//
    self.tableView.scrollEnabled = YES;
    filterView.hidden = YES;
    
    blocked = false;
    
    self.tableView.tag = 2;
    self.navigationController.navigationBarHidden = NO;
    [self updateBarButtonItems:1];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.container.panMode = MFSideMenuPanModeDefault;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:21.0f]}];
     self.navigationItem.title = @"Profile";
    id barButtonAppearance = [UIBarButtonItem appearance];
    NSDictionary *barButtonTextAttributes = @{
                                              UITextAttributeFont: [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15.0f],
                                              UITextAttributeTextShadowColor: [UIColor blackColor],
                                              UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]
                                              };
    
    [barButtonAppearance setTitleTextAttributes:barButtonTextAttributes
                                       forState:UIControlStateNormal];
    
    PFQuery *query1 = [PFQuery queryWithClassName:kESBlockedClassName];
    [query1 whereKey:kESBlockedUser2 equalTo:[PFUser currentUser]];
    [query1 whereKey:kESBlockedUser1 equalTo:user];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                followerBtn.enabled = NO;
                followingBtn.enabled = NO;
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Dang!"
                                             message:@"Seems like either one of you has blocked the other."
                                             preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* btn = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }];
                [alert addAction:btn];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:kESBlockedClassName];
    [query2 whereKey:kESBlockedUser1 equalTo:[PFUser currentUser]];
    [query2 whereKey:kESBlockedUser2 equalTo:user];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error == nil) {
            if (objects.count > 0) {
                blocked = TRUE;
            }
        }
    }];

    if (!isList) {
        self.tableView.scrollEnabled = NO;
        filterView.hidden = NO;
        [self loadFilterView];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //========= init objectId, Gender of selected user====//
//    ESCache *shared = [ESCache sharedCache];
//    shared.selectedUserId = @"";
//    shared.selectedUserGender = @"";
    //====================================================//
}
- (void)viewDidAppear:(BOOL)animated {
//    [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
//    isList = true;
    
    PFFile *imageFile = [self.user objectForKey:kESUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) { }
        }];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isList = true;
    //self.navigationController.navigationBar.translucent = YES;
    if (kESAdmobEnabled == YES) {
        self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    self.tableView.scrollsToTop = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (!self.user) {
        [NSException raise:NSInvalidArgumentException format:@"user cannot be nil"];
    }
    UIImage *logoImg = [[UIImage imageNamed:@"logo50.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTargetImage:self action:@selector(tapBtn) image:logoImg];
    [leftDrawerButton setTintColor:COLOR_GOLD];
    if (self.tabBarController.selectedIndex == 1 && [[PFUser currentUser].objectId isEqualToString:self.user.objectId]) {
        [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    }

    self.navigationItem.title = @"Profile";
    
    int i = 400;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, i)];
    [self.headerView setBackgroundColor:[UIColor clearColor]]; // should be clear, this will be the container for our avatar, photo count, follower count, following count, and so on
    
    [self setupHeader];
    
    filterView.hidden = YES;
    
}
- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    //self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}
- (void) disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [self disableScrollsToTopPropertyOnAllSubviewsOf:subview];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yPos = -scrollView.contentOffset.y;
    if (yPos > 0) {
        CGRect imgRect = self.imageView.frame;
        imgRect.origin.y = scrollView.contentOffset.y;
        
        imgRect.size.height = HeaderHeight+yPos;
        self.imageView.frame = imgRect;
    }
}

- (void)attemptOpenURL:(NSURL *)url
{
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];

}

# pragma mark - Header setup

- (void) setupHeader {
    
    self.imageView = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [self.imageView setFile:[self.user objectForKey:kESUserHeaderPicMediumKey]];
    [self.imageView loadInBackground:^(UIImage *image, NSError *error) {
    }];
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, HeaderHeight);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.headerView addSubview:self.imageView];
     int i = 0;
    if (![self.user objectForKey:@"UserInfo"] || [[self.user objectForKey:@"UserInfo"] isEqualToString:@""]) {
        i = 190;
    }
    else i = 240;
    int i3 = 0;
    if (![self.user objectForKey:@"UserInfo"] || [[self.user objectForKey:@"UserInfo"] isEqualToString:@""]) {
        i3 = 350;
    }
    else i3 = 400;
    [UIView animateWithDuration:100
                          delay:0
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.headerView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, i3);
                         whiteBackground.frame = CGRectMake(0, 160, [UIScreen mainScreen].bounds.size.width, i);
                     } completion:^(BOOL finished){NSLog(@"animation finished");}
     ];

    whiteBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 160, [UIScreen mainScreen].bounds.size.width, i)];
    [whiteBackground setBackgroundColor:[UIColor whiteColor]];
    [self.headerView addSubview:whiteBackground];
    
    grayLine = [[UILabel alloc]initWithFrame:CGRectMake(0, self.headerView.frame.size.height -10, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [grayLine setBackgroundColor:[UIColor lightGrayColor]];
    [self.headerView addSubview:grayLine];
    
    profilePictureBackgroundView = [[UIButton alloc] initWithFrame:CGRectMake(16, 106, 108, 108)];
    [profilePictureBackgroundView setBackgroundColor:[UIColor whiteColor]];
    profilePictureBackgroundView.alpha = 1.0f;
    CALayer *layer = [profilePictureBackgroundView layer];
    layer.cornerRadius = 54;
    layer.masksToBounds = YES;
    [self.headerView addSubview:profilePictureBackgroundView];

    profilePictureImageView = [[PFImageView alloc] initWithFrame:CGRectMake(20, 110.0f, 100.0f, 100.0f)];

    [profilePictureImageView setContentMode:UIViewContentModeScaleAspectFill];
    layer = [profilePictureImageView layer];
    layer.cornerRadius = 50.0f;
    layer.masksToBounds = YES;
    profilePictureImageView.alpha = 1.0f;

    UIImageView *profilePictureStrokeImageView = [[UIImageView alloc] initWithFrame:CGRectMake( 88.0f, 24.0f, 143.0f, 143.0f)];
    profilePictureStrokeImageView.alpha = 1.0f;
    [self.headerView addSubview:profilePictureStrokeImageView];
    
    if ([[self.user objectForKey:@"Gender"] isEqualToString:@"female"] || [[self.user objectForKey:@"Gender"] isEqualToString:@"weiblech"]) {
        [profilePictureImageView setImage:[UIImage imageNamed:@"AvatarPlaceholderProfileFemale"]];

    }
    else [profilePictureImageView setImage:[UIImage imageNamed:@"AvatarPlaceholderProfile"]];
    
    PFFile *imageFile = [self.user objectForKey:kESUserProfilePicMediumKey];
    if (imageFile) {
        [profilePictureImageView setFile:imageFile];
        [profilePictureImageView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.2f animations:^{
                    profilePictureBackgroundView.alpha = 1.0f;
                    profilePictureStrokeImageView.alpha = 1.0f;
                    profilePictureImageView.alpha = 1.0f;
                }];
                
                backgroundImageView = [[UIImageView alloc] initWithImage:[image applyLightEffect]];
                backgroundImageView.frame = self.tableView.backgroundView.bounds;
                backgroundImageView.alpha = 0.0f;
                [self.tableView.backgroundView addSubview:backgroundImageView];
                
                [UIView animateWithDuration:0.2f animations:^{
                    backgroundImageView.alpha = 1.0f;
                }];
            }
        }];
    }
    
    userDisplayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 220, self.headerView.bounds.size.width, 22.0f)];
    [userDisplayNameLabel setTextAlignment:NSTextAlignmentLeft];
    [userDisplayNameLabel setBackgroundColor:[UIColor clearColor]];
    [userDisplayNameLabel setTextColor:[UIColor blackColor]];
    [userDisplayNameLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:17.0f]];
    if ([self.user objectForKey:kESUserDisplayNameKey]) {
        [userDisplayNameLabel setText:[self.user objectForKey:kESUserDisplayNameKey]];
    }
    else {
        [userDisplayNameLabel setText:[self.user objectForKey:@"username"]];
    }
    [userDisplayNameLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:17.0f]];
    [self.headerView addSubview:userDisplayNameLabel];

    userMentionLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15, 230, [UIScreen mainScreen].bounds.size.width - 15, 40)];
    [userMentionLabel setTextAlignment:NSTextAlignmentLeft];
    [userMentionLabel setBackgroundColor:[UIColor clearColor]];
    [userMentionLabel setTextColor:COLOR_GOLD];
    [userMentionLabel setText:[[NSString stringWithFormat:@"@%@",[self.user objectForKey:@"usernameFix"]]lowercaseString]];
    [userMentionLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:13.0f]];
    [self.headerView addSubview:userMentionLabel];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15, 268, [UIScreen mainScreen].bounds.size.width - 25, 80)];
    if (IS_IPHONE5) {
        infoLabel.frame = CGRectMake(15, 268, [UIScreen mainScreen].bounds.size.width - 25, 100);
    }
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    infoLabel.alpha = 1.0f;
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
    [infoLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14.0f]];
    infoLabel.numberOfLines = 4;
    infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    PFUser *_user = [PFUser currentUser];
    if (![self.user objectForKey:@"UserInfo"] && self.user == _user) {
        infoLabel.text = NSLocalizedString(@"Tell everyone how awesome you are.", nil);
    }
    else if (![self.user objectForKey:@"UserInfo"] && self.user != _user) {
        infoLabel.text = NSLocalizedString(@"", nil);
    }
    else {
        infoLabel.text = [NSString stringWithFormat:@"%@",[self.user objectForKey:@"UserInfo"]];
    }
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize expectedLabelSize = [infoLabel.text sizeWithFont:infoLabel.font constrainedToSize:maximumLabelSize lineBreakMode:infoLabel.lineBreakMode];
    //adjust the label the the new height.
    CGRect newFrame = infoLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    infoLabel.frame = newFrame;
    [self.headerView addSubview:infoLabel];
    
    int i2 = 0;
    if (![self.user objectForKey:@"UserInfo"] || [[self.user objectForKey:@"UserInfo"] isEqualToString:@""]) {
        i2 =  infoLabel.frame.origin.y + 5;
    }
    else i2 =  infoLabel.frame.origin.y + infoLabel.frame.size.height + 5;
    cityLabel = [[UILabel alloc] initWithFrame:CGRectMake( 15,i2, [UIScreen mainScreen].bounds.size.width - 300, 20)];
    [cityLabel setTextAlignment:NSTextAlignmentLeft];
    [cityLabel setBackgroundColor:[UIColor clearColor]];
    [cityLabel setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
    [cityLabel setText:[self.user objectForKey:@"Location"]];
    [cityLabel setFont:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14.0f]];
    CGSize _maximumLabelSize = CGSizeMake(296, FLT_MAX);
    CGSize _expectedLabelSize = [cityLabel.text sizeWithFont:cityLabel.font constrainedToSize:_maximumLabelSize lineBreakMode:cityLabel.lineBreakMode];
    CGRect _newFrame = cityLabel.frame;
    _newFrame.size.width = _expectedLabelSize.width;
    cityLabel.frame = _newFrame;
    [self.headerView addSubview:cityLabel];
    
    
    siteLabel = [[KILabel alloc]initWithFrame:CGRectMake(cityLabel.frame.size.width + cityLabel.frame.origin.x + 15, i2, [UIScreen mainScreen].bounds.size.width - (cityLabel.frame.size.width + cityLabel.frame.origin.x + 15), 20)];
    if ([self.user objectForKey:@"Website"]) {
        siteLabel.text = [self.user objectForKey:@"Website"];
    }
    [siteLabel setTextAlignment:NSTextAlignmentLeft];
    siteLabel.alpha = 1.0f;
    siteLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:16.0f];
    [siteLabel setBackgroundColor:[UIColor clearColor]];
    [self.headerView addSubview:siteLabel];

    //Now we're preparing for the segmented control, to display photos, followers and following ...
    __block int photos;
    __block int follower;
    __block int following;
    
    PFQuery *queryPhotoCount = [PFQuery queryWithClassName:kESPhotoClassKey];
    [queryPhotoCount whereKey:kESPhotoUserKey equalTo:self.user];
    [queryPhotoCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryPhotoCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [photoCountLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%d post%@", nil), number, number==1?@"":NSLocalizedString(@"s", nil)]];
            [[ESCache sharedCache] setPhotoCount:[NSNumber numberWithInt:number] user:self.user];
            [photosBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d post%@", nil), number, number==1?@"":NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
            photos = number;
        }
    }];

    PFQuery *queryFollowerCount = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryFollowerCount whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [queryFollowerCount whereKey:kESActivityToUserKey equalTo:self.user];
    [queryFollowerCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowerCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followerBtn setTitle:[NSString stringWithFormat:@"%d follower%@", number, number==1?@"":NSLocalizedString(@"s", nil)] forState:UIControlStateNormal];
             follower = number;
        }
    }];

    PFQuery *queryFollowingCount = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryFollowingCount whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [queryFollowingCount whereKey:kESActivityFromUserKey equalTo:self.user];
    [queryFollowingCount setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [queryFollowingCount countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            [followingBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d following", nil), number] forState:UIControlStateNormal];
            following = number;
        }
    }];
    editProfileBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, 170, 100, 30)];
    
    [self.headerView addSubview:editProfileBtn];

    editStyleBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 110, 220, 100, 30)];
    
    [editStyleBtn addTarget:self action:@selector(editStyleBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [editStyleBtn setTitle:@"My Styles" forState:UIControlStateNormal];
    [editStyleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [editStyleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    editStyleBtn.titleLabel.textColor = [UIColor grayColor];
    editStyleBtn.tintColor = [UIColor grayColor];
    editStyleBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14];
    editStyleBtn.layer.borderWidth = 1;
    editStyleBtn.layer.borderColor = [UIColor grayColor].CGColor;
    editStyleBtn.layer.cornerRadius = 4;
    editStyleBtn.layer.masksToBounds = YES;
    //[editStyleBtn setHidden:YES];
    [self.headerView addSubview:editStyleBtn];
    
    btnList = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 260, 35, 35)];
    [btnList setBackgroundImage:[UIImage imageNamed:@"btnList_ena.png"] forState:UIControlStateNormal];
    [btnList setBackgroundColor:[UIColor clearColor]];
    btnList.tag = LIST_TAG;
    [btnList addTarget:self action:@selector(buttonListFilterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    btnFilter = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 260, 35, 35)];;
    [btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
    [btnFilter setBackgroundColor:[UIColor clearColor]];
    btnFilter.tag = FILTER_TAG;
    [btnFilter addTarget:self action:@selector(buttonListFilterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.headerView addSubview:btnList]; //.//
    [self.headerView addSubview:btnFilter];
    
    //=============== init add topview =======================//
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat barHeight       = self.navigationController.navigationBar.frame.size.height + statusBarHeight;
    filterView = [[UIView alloc]initWithFrame:CGRectMake(0, barHeight+self.headerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - 70.0f)];
    filterView.backgroundColor = [UIColor redColor];
    
    forSaleBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 47.5, self.headerView.frame.size.height   - 50, 95, 25)];
    forHireBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 105, self.headerView.frame.size.height   - 50, 95, 25)];
    allBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, self.headerView.frame.size.height   - 50, 95, 25)];

    [forSaleBtn setTitle:NSLocalizedString(@"For Sale", nil) forState:UIControlStateNormal];
    [allBtn setTitle:NSLocalizedString(@"For Inspiration", nil) forState:UIControlStateNormal];
    [forHireBtn setTitle:NSLocalizedString(@"For Hire", nil) forState:UIControlStateNormal];
    
    forSaleBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:13];
    allBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:13];
    forHireBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:13];
    
    forSaleBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
    allBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
    forHireBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];
    
    [forSaleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [forHireBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [allBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    forSaleBtn.tag = FORSALE_TAG;
    forHireBtn.tag = FORHIRE_TAG;
    allBtn.tag     = FORINSPIRATION_TAG;
    
    [forSaleBtn addTarget:self action:@selector(onSaleType:) forControlEvents:UIControlEventTouchUpInside];
    [forHireBtn addTarget:self action:@selector(onSaleType:) forControlEvents:UIControlEventTouchUpInside];
    [allBtn addTarget:self action:@selector(onSaleType:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.headerView addSubview:forSaleBtn];
    [self.headerView addSubview:forHireBtn];
    [self.headerView addSubview:allBtn];
    
    btnBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(profilePictureImageView.frame.origin.x + profilePictureImageView.frame.size.width/2,  profilePictureImageView.frame.origin.y + profilePictureImageView.frame.size.height / 2 - 25, self.imageView.frame.size.width - (profilePictureImageView.frame.origin.x + profilePictureImageView.frame.size.width/2), 25)];
    
    btnBackgroundView.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.7];
    
    photosBtn = [[UIButton alloc]initWithFrame:CGRectMake(profilePictureImageView.frame.size.width/2, 0, (btnBackgroundView.frame.size.width - profilePictureImageView.frame.size.width/2 - profilePictureImageView.frame.origin.x)/3, 25)];
    followerBtn = [[UIButton alloc]initWithFrame:CGRectMake(profilePictureImageView.frame.size.width/2 + (btnBackgroundView.frame.size.width - profilePictureImageView.frame.size.width/2 - profilePictureImageView.frame.origin.x)/3, 0, btnBackgroundView.frame.size.width/3, 25)];
    followingBtn = [[UIButton alloc]initWithFrame:CGRectMake(profilePictureImageView.frame.size.width/2 + 2 * (btnBackgroundView.frame.size.width - profilePictureImageView.frame.size.width/2- profilePictureImageView.frame.origin.x)/3, 0, btnBackgroundView.frame.size.width/3, 25)];

    
    [followerBtn setTitle:NSLocalizedString(@"0 following", nil) forState:UIControlStateNormal];
    [photosBtn setTitle:NSLocalizedString(@"0 posts", nil) forState:UIControlStateNormal];
    [followingBtn setTitle:NSLocalizedString(@"0 followers", nil) forState:UIControlStateNormal];
    
    
    [followerBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [photosBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [followingBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    followingBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:12];
    followerBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:12];
    photosBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:12];
    
    [followingBtn addTarget:self action:@selector(showFollowings) forControlEvents:UIControlEventTouchDown];
    [followerBtn addTarget:self action:@selector(showFollowers) forControlEvents:UIControlEventTouchDown];
    
    photosBtn.layer.cornerRadius = 3;
    followerBtn.layer.cornerRadius = 3;
    followingBtn.layer.cornerRadius = 3;
    
    photosBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.0];
    followerBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.0];
    followingBtn.backgroundColor = [UIColor colorWithWhite:0.94 alpha:0.0];
    
    
    [self.btnBackgroundView addSubview:followingBtn];
    [self.btnBackgroundView addSubview:followerBtn];
    [self.btnBackgroundView addSubview:photosBtn];
    
    [self.headerView addSubview: btnBackgroundView];
    [self.headerView addSubview:profilePictureImageView];
    
    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingActivityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
        
        // check if the currentUser is following this user
        PFQuery *queryIsFollowing = [PFQuery queryWithClassName:kESActivityClassKey];
        [queryIsFollowing whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
        [queryIsFollowing whereKey:kESActivityToUserKey equalTo:self.user];
        [queryIsFollowing whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
        [queryIsFollowing setCachePolicy:kPFCachePolicyCacheThenNetwork];
        [queryIsFollowing countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error && [error code] != kPFErrorCacheMiss) {
                self.navigationItem.rightBarButtonItem = nil;
            } else {
                if (number == 0) {
                    [self configureFollowButton];
                } else {
                    [self configureUnfollowButton];
                }
            }
        }];
    }
    else {
        [self configureSettingsButton];
    }
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;

    if (![[self.user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        reportUser = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 140 , 175, 20, 20)];
        [reportUser setImage:[UIImage imageNamed:@"ButtonImageSettings"] forState:UIControlStateNormal];
        [reportUser setImage:[UIImage imageNamed:@"ButtonImageSettingsSelected"] forState:UIControlStateHighlighted];
        [reportUser addTarget:self action:@selector(ReportTap) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:reportUser];
        [reportUser setHidden:YES];
        
        privateMessageBtn = [[UIButton alloc]initWithFrame:CGRectMake(profilePictureImageView.frame.origin.x + profilePictureImageView.frame.size.width, profilePictureImageView.frame.origin.y + profilePictureImageView.frame.size.height, 32, 32)];
//        [privateMessageBtn setImage:[UIImage imageNamed:@"paperPlane"] forState:UIControlStateNormal];
//        [privateMessageBtn setImage:[UIImage imageNamed:@"paperPlaneSelected"] forState:UIControlStateHighlighted];
        [privateMessageBtn setBackgroundImage:[UIImage imageNamed:@"IconChat.png"] forState:UIControlStateNormal];
        [privateMessageBtn addTarget:self action:@selector(privateMessageBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:privateMessageBtn];
    }

    __unsafe_unretained typeof(self) weakSelf = self;
    self.siteLabel.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        [weakSelf attemptOpenURL:[NSURL URLWithString:string]];
        NSLog(@"URL:%@",string);
    };

}

# pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 22) {
        if (buttonIndex == 1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What do you want the user to be reported for?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Sexual content", nil), NSLocalizedString(@"Offensive content", nil), NSLocalizedString(@"Spam", nil), NSLocalizedString(@"Other", nil), nil];
            //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = 23;
            [actionSheet showInView:self.headerView];
        }
        else if (buttonIndex == 0) {
            
            [ESUtility blockUser:user];
            SCLAlertView *alert = [[SCLAlertView alloc] init];

            [alert showNotice:self.tabBarController title:NSLocalizedString(@"Notice", nil)
                     subTitle:NSLocalizedString(@"User has been successfully blocked.", nil)
             closeButtonTitle:@"OK" duration:0.0f];
            
            blocked = true;
        }
    }
    else if (actionSheet.tag == 44) {
        if (buttonIndex == 1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What do you want the user to be reported for?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Sexual content", nil), NSLocalizedString(@"Offensive content", nil), NSLocalizedString(@"Spam", nil), NSLocalizedString(@"Other", nil), nil];
            //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            actionSheet.tag = 23;
            [actionSheet showInView:self.headerView];
        }
        else if (buttonIndex == 0) {
            
            [ESUtility unblockUser:user];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert showNotice:self.tabBarController title:NSLocalizedString(@"Notice", nil)
                     subTitle:NSLocalizedString(@"User has been successfully unblocked.", nil)
             closeButtonTitle:@"OK" duration:0.0f];
            
            blocked = false;
        }
    }
    else if (actionSheet.tag == 23) {
        if (buttonIndex == 0) {
            [self reportUser:0];
        }
        else if (buttonIndex == 1) {
            [self reportUser:1];
        }
        else if (buttonIndex == 2) {
            [self reportUser:2];
        }
        else if (buttonIndex == 3) {
            [self reportUser:3];
        }
    }
       
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    self.tableView.tableHeaderView = headerView;
}

- (PFQuery *)queryForTable {
    if (!self.user) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:kESPhotoUserKey equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query includeKey:kESPhotoUserKey];
    [query includeKey:kESPostRetweetedUserKey];

    return query;
}

# pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LoadMoreCellIdentifier = @"LoadMoreCell";
    
    ESLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if (!cell) {
        cell = [[ESLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier];
        cell.selectionStyle =UITableViewCellSelectionStyleGray;
        //cell.separatorImageTop.image = [UIImage imageNamed:@"SeparatorTimelineDark"];
        cell.hideSeparatorBottom = YES;
        cell.mainView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}


#pragma mark - ()

- (void)followButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureUnfollowButton];
    
    [ESUtility followUserEventually:self.user block:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self configureFollowButton];
        }
    }];
}

- (void)unfollowButtonAction:(id)sender {
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self configureFollowButton];
    
    [ESUtility unfollowUserEventually:self.user];
}
- (void)configureSettingsButton {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"lb"]) {
        editProfileBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 150, 170, 135, 30);

    }
    [editProfileBtn addTarget:self action:@selector(editProfileBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn setTitle:NSLocalizedString(@"Edit Profile",nil) forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    editProfileBtn.titleLabel.textColor = [UIColor grayColor];
    editProfileBtn.tintColor = [UIColor grayColor];
    editProfileBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14];
    editProfileBtn.layer.borderWidth = 1;
    editProfileBtn.layer.borderColor = [UIColor grayColor].CGColor;
    editProfileBtn.layer.cornerRadius = 4;
    editProfileBtn.layer.masksToBounds = YES;
    
    //[editStyleBtn setHidden:NO];
}

- (void)configureFollowButton {
    editProfileBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 110, 170, 100, 30);
    [editProfileBtn addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn setTitle:NSLocalizedString(@"Follow",nil) forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:COLOR_GOLD forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:COLOR_GOLD forState:UIControlStateHighlighted];
    editProfileBtn.backgroundColor = [UIColor clearColor];
    editProfileBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14];
    editProfileBtn.layer.borderWidth = 1;
    editProfileBtn.layer.borderColor = COLOR_GOLD.CGColor;
    editProfileBtn.layer.cornerRadius = 4;
    editProfileBtn.layer.masksToBounds = YES;
    [[ESCache sharedCache] setFollowStatus:NO user:self.user];
    
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    [loadingActivityIndicatorView stopAnimating];
}

- (void)configureUnfollowButton {
    editProfileBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 110, 170, 100, 30);
    [editProfileBtn addTarget:self action:@selector(unfollowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn setTitle:NSLocalizedString(@"Following",nil) forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    editProfileBtn.titleLabel.textColor = [UIColor whiteColor];
    editProfileBtn.tintColor = [UIColor whiteColor];
    editProfileBtn.backgroundColor = COLOR_GOLD;
    editProfileBtn.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:14];
    editProfileBtn.layer.borderWidth = 1;
    editProfileBtn.layer.borderColor = COLOR_GOLD.CGColor;
    editProfileBtn.layer.cornerRadius = 4;
    editProfileBtn.layer.masksToBounds = YES;
    [[ESCache sharedCache] setFollowStatus:YES user:self.user];
    
    UIActivityIndicatorView *loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    [loadingActivityIndicatorView stopAnimating];
}

-(void)reportUser:(int)i {
    PFObject *object = [PFObject objectWithClassName:@"Report"];
    [object setObject:user forKey:@"ReportedUser"];
    
    if (i == 0) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Sexual", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 1) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Offensive", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 2) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Spam", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 3) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Other", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert showNotice:self.tabBarController title:NSLocalizedString(@"Notice", nil)
                    subTitle:NSLocalizedString(@"User has been successfully reported.", nil)
            closeButtonTitle:@"OK" duration:0.0f];
        }
        else {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            [alert showError:self.tabBarController title:NSLocalizedString(@"Hold On...", nil)
                     subTitle:NSLocalizedString(@"Check your internet connection.", nil)
             closeButtonTitle:@"OK" duration:0.0f];
            
            NSLog(@"error %@",error);
        }
        
    }];
    
    
}

- (void) editProfileBtnTapped {
    [self initSelectedBtnTag];
    dispatch_async(dispatch_get_main_queue(), ^{
        ESEditProfileViewController *profileViewController = [[ESEditProfileViewController alloc] initWithNibName:nil bundle:nil andOptionForTutorial:@"NO"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
        [self presentViewController:navController animated:YES completion:nil];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSecondViewController)
                                                 name:@"SecondViewControllerDismissed"
                                               object:nil];
    
    
}

- (void) editStyleBtnAction {
    [self initSelectedBtnTag];
    dispatch_async(dispatch_get_main_queue(), ^{
       
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ESEditStyleViewController *styleViewController = [sb instantiateViewControllerWithIdentifier:@"EditStyleVC"];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:styleViewController];
        [self presentViewController:navController animated:YES completion:nil];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSecondViewController)
                                                 name:@"SecondViewControllerDismissed"
                                               object:nil];
}

- (void)buttonListFilterClicked:(UIButton *)sender{
    [filterView removeFromSuperview];
    if (isList) {
        [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnList_dis.png"] forState:UIControlStateNormal];
        self.tableView.scrollEnabled = NO;
        filterView.hidden = NO;
        [self loadFilterView];
        isList = false;
    } else {
        [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
        self.tableView.scrollEnabled = YES;
        filterView.hidden = YES;
        isList = true;
    }
    
//    NSInteger btnTag = sender.tag;
//    switch (btnTag) {
//        case LIST_TAG:
//            self.tableView.scrollEnabled = YES;
//            [self.btnList setBackgroundImage:[UIImage imageNamed:@"btnList_ena.png"] forState:UIControlStateNormal];
//            [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
//            filterView.hidden = YES;
//            break;
//        case FILTER_TAG:
//            self.tableView.scrollEnabled = NO;
//            [self.btnList setBackgroundImage:[UIImage imageNamed:@"btnList_dis.png"] forState:UIControlStateNormal];
//            [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_ena.png"] forState:UIControlStateNormal];
//            filterView.hidden = NO;
//            [self loadFilterView];
//            break;
//
//        default:
//            break;
//    }
}

- (void)loadFilterView{
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, filterView.frame.size.width, filterView.frame.size.height) collectionViewLayout:layout];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [filterView addSubview:collectionView];
    filterView.backgroundColor = [UIColor redColor];
    [self.navigationController.view addSubview:filterView];
}

#pragma collectionview Delegate method.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//--    return self.objects.count;
    ESCache *shared = [ESCache sharedCache];
    return shared.saleTypeObjects.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ESCache *shared = [ESCache sharedCache];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSMutableDictionary  *dict = [[NSMutableDictionary alloc]init];
//--    dict = [self.objects objectAtIndex:indexPath.row];
    dict = [shared.saleTypeObjects objectAtIndex:indexPath.row];
    PFFile *file = [dict objectForKey:kESPhotoPictureKey];
    ESImageView *imgView = [[ESImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 150.0f)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [imgView setBackgroundColor:[UIColor blackColor]];
    [imgView.layer setCornerRadius:5.0f];
    [imgView.layer setBorderColor:COLOR_GOLD.CGColor];
    [imgView.layer setBorderWidth:2.0f];
    [imgView setFile:file];
    [cell addSubview:imgView];
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0.0f, 25.0f, 80.0f*self.objects.count, 25.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    filterView.hidden = YES;
    ESCache *shared = [ESCache sharedCache];
    
//--    PFObject *photo = [self.objects objectAtIndex:indexPath.row];
    PFObject *photo = [shared.saleTypeObjects objectAtIndex:indexPath.row];
    if (photo) {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo andTextPost:@"NO"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
        
    }
}

////////////////////

- (void)initSelectedBtnTag{
    ESCache *shared = [ESCache sharedCache];
    shared.selectedBtnTag = @"";
}

- (void) didDismissSecondViewController {
    [self setupHeader];
}
- (void) ReportTap {
    if (blocked == true) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Do you want to report or unblock the user", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Unblock", nil) otherButtonTitles: NSLocalizedString(@"Report", nil), nil];
        actionSheet.tag = 44;
        [actionSheet showInView:self.headerView];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Do you want to report or block the user", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Block", nil) otherButtonTitles: NSLocalizedString(@"Report", nil), nil];
        actionSheet.tag = 22;
        [actionSheet showInView:self.headerView];
    }
}

-(void)privateMessageBtnAction {
    NSDictionary* dict = @{@"user": self.user};
    [[NSNotificationCenter defaultCenter] postNotificationName:ESOpenChatWithUserNotification object:nil userInfo:dict];

    /*NSMutableArray *users = [[NSMutableArray alloc] initWithObjects:self.user, nil];
    NSString *groupId = [ESUtility createConversation:users];
    NSString *description = [[NSString alloc]init];
    if (groupId.length == 20) {
        for (PFUser *user in users)
        {
            if (![user.objectId isEqualToString:[PFUser currentUser].objectId]) {
                description = [user objectForKey:kESUserDisplayNameKey];
                break;
            }
        }
        ESMessengerView *messengerView = [[ESMessengerView alloc] initWith:groupId andName:description];
        messengerView.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:messengerView animated:YES];
        });
    }
    else {
        ESMessengerView *messengerView = [[ESMessengerView alloc] initWith:groupId andName:NSLocalizedString(@"Group", nil)];
        messengerView.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:messengerView animated:YES];
        });
    }*/
}
-(void)showFollowers {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ESFollowerVC* controller = [storyboard instantiateViewControllerWithIdentifier:@"followerVC"];
    controller.title = @"Followers";
    [self.navigationController pushViewController:controller animated:YES];
    /*
    ESFollowersViewController *followerView = [[ESFollowersViewController alloc] initWithStyle:UITableViewStyleGrouped andOption:@"Followers" andUser:self.user];
    [self.navigationController pushViewController:followerView animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]; */

}
-(void)showFollowings {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ESFollowerVC* controller = [storyboard instantiateViewControllerWithIdentifier:@"followerVC"];
    controller.title = @"Following";
    [self.navigationController pushViewController:controller animated:YES];
    /*
    ESFollowersViewController *followerView = [[ESFollowersViewController alloc] initWithStyle:UITableViewStyleGrouped andOption:@"Following" andUser:self.user];
    [self.navigationController pushViewController:followerView animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]; */

}

- (void)onSaleType:(UIButton *)sender{
    [self loadObjects];
    NSInteger btnTag = sender.tag;
    [self clearColorButton];
    NSString *strSaleType = @"";
    
    switch (btnTag) {
        case FORINSPIRATION_TAG:
            [allBtn setBackgroundColor:COLOR_GOLD];
            strSaleType = FORINSPIRATION;
            [self addForInspirationTab:strSaleType];
            break;
        case FORSALE_TAG:
            [forSaleBtn setBackgroundColor:COLOR_GOLD];
            strSaleType = FORSALE;
            [self addForSaleTab:strSaleType];
            break;
        case FORHIRE_TAG:
            [forHireBtn setBackgroundColor:COLOR_GOLD];
            strSaleType = FORHIRE;
            [self addForHireTab:strSaleType];
            break;
            
        default:
            break;
    }
    [collectionView reloadData];
}

- (void)clearColorButton{
    [forSaleBtn setBackgroundColor:[UIColor clearColor]];
    [forHireBtn setBackgroundColor:[UIColor clearColor]];
    [allBtn setBackgroundColor:[UIColor clearColor]];
}

- (void)addForInspirationTab:(NSString *)saleType{
   
    if ([saleType isEqualToString:FORINSPIRATION]) {
       
        [self addPhotoObjects:saleType];
    }else
        return;
}
- (void)addForSaleTab:(NSString *)saleType{
    
    if ([saleType isEqualToString:FORSALE]) {
        
        [self addPhotoObjects:saleType];
    }else
        return;
}
- (void)addForHireTab:(NSString *)saleType{
    
    if ([saleType isEqualToString:FORHIRE]) {
       
        [self addPhotoObjects:saleType];
    }else
        return;
}

#pragma mark - selected sale type tap.
- (void)addPhotoObjects:(NSString *)selectSaleType{
    ESCache *shared = [ESCache sharedCache];
//    shared.tempObjects = [self.objects copy];
    shared.saleTypeObjects = [[NSMutableArray alloc]init];
    NSMutableDictionary *dict    = [[NSMutableDictionary alloc]init];
    NSMutableArray *arrSaleType  = [[NSMutableArray alloc]init];
    self.tempObject              = [[NSMutableArray alloc]init];
    
    
    NSLog(@"self.objects count -- %lu", (unsigned long)self.objects.count);
    
    for (int i = 0; i<self.objects.count; i++) {
        
        dict = [self.objects objectAtIndex:i];
        arrSaleType = [dict objectForKey:kESPhotoSaleType];
        NSInteger k = 0;
        for (int j = 0; j<arrSaleType.count; j++) {
            NSString *strSaleType = [arrSaleType objectAtIndex:j];
            if([strSaleType isEqualToString:selectSaleType]){
                
                k++;
                if (k==1) {
                    [self.tempObject addObject:[self.objects objectAtIndex:i]];
                }
            }
        }
        
    }
    [shared.saleTypeObjects removeAllObjects];
    [shared.saleTypeObjects addObjectsFromArray:self.tempObject];
    [self.tableView reloadData];
    NSLog(@"temp objects count --- %lu", (unsigned long)shared.saleTypeObjects.count);
    
}

//Hot fix for the bug in the Parse SDK
- (NSIndexPath *)_indexPathForPaginationCell {
    ESCache *shared = [ESCache sharedCache];
//--    return [NSIndexPath indexPathForRow:0 inSection:[self.objects count]];
    return [NSIndexPath indexPathForRow:0 inSection:[shared.saleTypeObjects count]];
    
}
@end
