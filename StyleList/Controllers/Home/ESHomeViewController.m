//
//  ESHomeViewController.m


#import "ESHomeViewController.h"
#import "ESSettingsActionSheetDelegate.h"
#import "ESSettingsButtonItem.h"
#import "ESFindFriendsViewController.h"
#import "MBProgressHUD.h"
#import "UIViewController+ScrollingNavbar.h"
#import <QuartzCore/CALayer.h>
#import "MMDrawerBarButtonItem.h"
#import "SideViewController.h"
#import "MFSideMenu.h"
#import "ESAccountViewController.h"
#import "AppDelegate.h"
#import "ESSettingsViewController.h"
#import "ESSearchHashtagTableViewController.h"
#import "ESEditProfileViewController.h"
#import "SCLAlertView.h"
#import "ESPopularViewController.h"
#import "ESBestViewController.h"
#import "ESMediaViewController.h"
#import "ESRecentViewController.h"
#import "TOWebViewController.h"
#import "ESImageView.h"
#import "TransactionsVC.h"
#import "HelpVC.h"

BOOL monster = NO;
BOOL admobEnabled = YES;

@interface ESHomeViewController () <GADBannerViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource >{
    UICollectionView *collectionView;
    NSMutableArray<PFObject *> *arrFollowedUsers;
    NSMutableArray<PFObject *> *arrLikedUsers;
    
    bool isList;
    UILabel *searchLabel;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UIButton    *btnRecent;
@property (strong, nonatomic) UIButton    *btnTrending;
@property (strong, nonatomic) UIButton    *btnFeatured;
@property (strong, nonatomic) UIView      *viewTop;
@property (strong, nonatomic) UIButton    *btnList;
@property (strong, nonatomic) UIButton    *btnFilter;
@property (strong, nonatomic) UIView      *filterView;

@end

@implementation ESHomeViewController
@synthesize firstLaunch;
@synthesize settingsActionSheetDelegate;
@synthesize blankTimelineView;

-(void)tapBtn {
  
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen completion:^{}];
    
}
-(void)viewDidAppear:(BOOL)animated {
    [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnList_dis.png"] forState:UIControlStateNormal];
    isList = true;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"AccountDeletion"]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"AccountDeletion"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //[(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];        
    }
   
}
/*-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}*/
- (void)viewDidLoad {
    [super viewDidLoad];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"CheckFBToken" object:nil userInfo:nil];
    rootView = self.tabBarController.view;
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    UIImage *logoImg = [[UIImage imageNamed:@"logo50.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTargetImage:self action:@selector(tapBtn) image:logoImg];
    
    [leftDrawerButton setTintColor:COLOR_GOLD];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
   /* UIImage *img = [[UIImage imageNamed:@"bt_filter.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(newFilter)];*/
    
    
    // create two nav bar buttons

//    UIView *filterRightTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 70, 35)]; //.//
    UIView *filterRightTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 42, 42)];
    self.btnList = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 10.0f, 30.0f, 30.0f)];
    [self.btnList setBackgroundImage:[UIImage imageNamed:@"btnList_ena.png"] forState:UIControlStateNormal];
    [self.btnList setBackgroundColor:[UIColor clearColor]];
    self.btnList.tag = LIST_TAG;
    [self.btnList addTarget:self action:@selector(buttonListFilterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
//    self.btnFilter = [[UIButton alloc]initWithFrame:CGRectMake(40.0f, 10.0f, 30.0f, 30.0f)]; //.//
    self.btnFilter = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, 2.0f, 38.0f, 38.0f)];
    [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
    [self.btnFilter setBackgroundColor:[UIColor clearColor]];
    self.btnFilter.tag = FILTER_TAG;
    [self.btnFilter addTarget:self action:@selector(buttonListFilterClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [filterRightTopView addSubview:self.btnList]; //.//
    [filterRightTopView addSubview:self.btnFilter];
    UIBarButtonItem *btnRight = [[UIBarButtonItem alloc]initWithCustomView:filterRightTopView];
    self.navigationItem.rightBarButtonItem = btnRight;
    
    isList = true; //.//
    
    self.searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = NO;
    _searchBar.delegate = self;
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"bg_searchbar.png"] forState:UIControlStateNormal];
    [_searchBar.layer setCornerRadius:10.0f];
    UITextField *textField = [_searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
    _searchBar.clipsToBounds = YES;
//    self.navigationItem.titleView = _searchBar;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    //------------------------------
    UIView *vw = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width - 130, 40)];
    vw.backgroundColor = [UIColor groupTableViewBackgroundColor];//[UIColor colorWithWhite:0.8 alpha:0.9];
    
    self.navigationItem.titleView = vw;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIcon.png"]];
    imgView.frame = CGRectMake(0, 0, 20, vw.frame.size.height);
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    [vw addSubview:imgView];
    
    searchLabel = [[UILabel alloc] init];
    searchLabel.frame = CGRectMake(22, 0, vw.frame.size.width - 22, vw.frame.size.height);
    searchLabel.backgroundColor = [UIColor clearColor];
    searchLabel.numberOfLines = 2;
    searchLabel.font = [UIFont systemFontOfSize:14];
    searchLabel.adjustsFontForContentSizeCategory = true;
    searchLabel.minimumScaleFactor = 0.5;
    searchLabel.userInteractionEnabled = true;
    searchLabel.text = @"Searching All";
    [vw addSubview:searchLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapSearchGesture:)];
    [tapGesture setDelegate:self];
    [searchLabel addGestureRecognizer:tapGesture];
    //------------------------------
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake( [UIScreen mainScreen].bounds.size.width/2 - 253/2, 96.0f, 253.0f, 165.0f);
    [button setBackgroundImage:[UIImage imageNamed:@"HomeTimelineBlank"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inviteFriendsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.blankTimelineView addSubview:button];
    [self.tableView setFrame:CGRectMake(0, 100, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    
    if (kESAdmobEnabled == YES) {
        self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(75, 0, 0, 0);
    }

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    [self.tableView.tableHeaderView setBackgroundColor:[UIColor redColor]];
    self.view.backgroundColor = [UIColor clearColor];

    //self.navigationController.navigationBar.shadowImage = [UIImage new];
    //self.navigationController.navigationBar.translucent = NO;

    /*UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, 1)];
    imgLine1.backgroundColor = COLOR_GOLD;
    [self.navigationController.navigationBar addSubview:imgLine1];*/
    
    
    //Notification listen
    NSString *notificationName = @"ESNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotificationWithString:) name:notificationName object:nil];
    
    if (![[[PFUser currentUser] objectForKey:@"firstLaunch"] isEqualToString:@"Yes"] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"] isEqualToString:@"Yes"]) {
        // On first launch, this block will execute
        [self firstLogin];
    }
  
    
}

- (void) tapSearchGesture: (id)sender
{
    [self newHashtagSearch];
}

- (void)addTopView{
    
    self.btnRecent = [[UIButton alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 40.0f)];
    [self.btnRecent setTitle:RECENT forState:UIControlStateNormal];
    self.btnRecent.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:18.0f];
    [self.btnRecent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnRecent setBackgroundColor:[UIColor clearColor]];
    self.btnRecent.tag = RECENT_TAG;
    [self.btnRecent addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnTrending = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width - self.btnRecent.frame.size.width)/2, 0.0f, 100.0f, 40.0f)];
    [self.btnTrending setTitle:TRENDING forState:UIControlStateNormal];
    self.btnTrending.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:18.0f];
    [self.btnTrending setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnTrending setBackgroundColor:[UIColor clearColor]];
    self.btnTrending.tag = TRENDING_TAG;
    [self.btnTrending addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnFeatured = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - self.btnRecent.frame.size.width,  0.0f, 100.0f, 40.0f)];
    [self.btnFeatured setTitle:FEATURED forState:UIControlStateNormal];
    self.btnFeatured.titleLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:18.0f];
    [self.btnFeatured setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnFeatured setBackgroundColor:[UIColor clearColor]];
    self.btnFeatured.tag = FEATURED_TAG;
    [self.btnFeatured addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _viewTop.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.95];
    [_viewTop addSubview:self.btnRecent];
    [_viewTop addSubview:self.btnTrending];
    [_viewTop addSubview:self.btnFeatured];
    [self.navigationController.view addSubview:_viewTop];
}

- (void)buttonListFilterClicked:(UIButton *)sender{
    [_filterView removeFromSuperview];
    if (isList) {
        [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
        _filterView.hidden = NO;
        [self loadFilterView];
        isList = false;
    } else {
        [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnList_dis.png"] forState:UIControlStateNormal];
        _filterView.hidden = YES;
        isList = true;
    }
    
    //marked by //.//
//    NSInteger btnTag = sender.tag;
//    switch (btnTag) {
//        case LIST_TAG:
//            [self.btnList setBackgroundImage:[UIImage imageNamed:@"btnList_ena.png"] forState:UIControlStateNormal];
//            [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_dis.png"] forState:UIControlStateNormal];
//            _filterView.hidden = YES;
//            break;
//        case FILTER_TAG:
//            [self.btnList setBackgroundImage:[UIImage imageNamed:@"btnList_dis.png"] forState:UIControlStateNormal];
//            [self.btnFilter setBackgroundImage:[UIImage imageNamed:@"btnFilter_ena.png"] forState:UIControlStateNormal];
//            _filterView.hidden = NO;
//            [self loadFilterView];
//            break;
//
//        default:
//            break;
//    }
}

- (void)loadFilterView{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat barHeight       = self.navigationController.navigationBar.frame.size.height + statusBarHeight;
    _filterView = [[UIView alloc]initWithFrame:CGRectMake(0, barHeight+40.0f, self.view.frame.size.width, self.view.frame.size.height - 70.0f)];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _filterView.frame.size.width, _filterView.frame.size.height) collectionViewLayout:layout];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [_filterView addSubview:collectionView];
    _filterView.backgroundColor = [UIColor redColor];
    [self.navigationController.view addSubview:_filterView];
}

#pragma collectionview Delegate method.

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objects.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    NSMutableDictionary  *dict = [[NSMutableDictionary alloc]init];
    dict = [self.objects objectAtIndex:indexPath.row];
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
    return UIEdgeInsetsMake(10.0f, 25.0f, 60.0f*self.objects.count, 25.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    _filterView.hidden = YES;
    [_filterView removeFromSuperview];
    PFObject *photo = [self.objects objectAtIndex:indexPath.row];
    
    if (photo) {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo andTextPost:@"NO"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];

    }
}

- (void)buttonClicked:(UIButton*)sender
{
    ESCache *shared = [ESCache sharedCache];
    NSInteger btnTag = sender.tag;
    switch (btnTag) {
        case RECENT_TAG:
            [self.btnRecent setTitleColor:COLOR_GOLD forState:UIControlStateNormal];
            [self.btnTrending setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.btnFeatured setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            shared.selectedTap = RECENT;
            [self addRecentTab];
            break;
        case TRENDING_TAG:
            [self.btnTrending setTitleColor:COLOR_GOLD forState:UIControlStateNormal];
            [self.btnRecent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.btnFeatured setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            shared.selectedTap = TRENDING;
            [self addTrendingObjects];
            break;
        case FEATURED_TAG:
            [self.btnFeatured setTitleColor:COLOR_GOLD forState:UIControlStateNormal];
            [self.btnRecent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.btnTrending setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            shared.selectedTap = FEATURED;
            [self addFeaturedObjects];
            break;
        default:
            break;
    }
    [collectionView reloadData];
}

- (void)addRecentTab{
    ESCache *shared = [ESCache sharedCache];
    if ([shared.selectedTap isEqualToString:RECENT]) {
        [self.tableView reloadData];
        
        [self loadObjects];
    }else
        return;
}
- (void)addTrendingObjects{
    ESCache *shared = [ESCache sharedCache];
    shared.likedUserPostObjects = [[NSMutableArray alloc]init];
    if ([shared.selectedTap isEqualToString:TRENDING]) {
        [shared.likedUserPostObjects addObjectsFromArray:arrLikedUsers];
        [self.tableView reloadData];
        [self loadObjects];
    }else
        return;
}
- (void)addFeaturedObjects{
    ESCache *shared = [ESCache sharedCache];
    shared.followedUserPostObjects = [[NSMutableArray alloc]init];
    if ([shared.selectedTap isEqualToString:FEATURED]) {
        
        [shared.followedUserPostObjects addObjectsFromArray:arrFollowedUsers];
        NSLog(@"shared following array count -- %lu", (unsigned long)shared.followedUserPostObjects.count);
        [self.tableView reloadData];
    }else
        return;
}

- (void)firstLogin {
    self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        ESEditProfileViewController *profileViewController = [[ESEditProfileViewController alloc] initWithNibName:nil bundle:nil andOptionForTutorial:@"YES"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
        [self presentViewController:navController animated:YES completion:nil];
    });
    
    PFQuery *sensitiveDataQuery = [PFQuery queryWithClassName:@"SensitiveData"];
    [sensitiveDataQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject *sensitiveData = [sensitiveDataQuery getFirstObject];
    BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];

    if (isLinkedToFacebook) {
        int i1 = arc4random() % 10;
        int i2 = arc4random() % 10;
        int i3 = arc4random() % 10;
        int i4 = arc4random() % 10;
        
        NSString *pin = [NSString stringWithFormat:@"%i%i%i%i",i1,i2,i3,i4];
        
        if (sensitiveData) {
            
            [sensitiveData setObject:pin forKey:@"PIN"];
            [sensitiveData saveInBackgroundWithBlock:^(BOOL result, NSError *error){
                if (error) {
                    [sensitiveData saveEventually];
                }
            }];
        }
        else {
            PFObject *_sensitiveData = [PFObject objectWithClassName:@"SensitiveData"];
            [_sensitiveData setObject:[PFUser currentUser] forKey:@"user"];
            [_sensitiveData setObject:pin forKey:@"PIN"];
            PFACL *sensitive = [PFACL ACLWithUser:[PFUser currentUser]];
            [sensitive setReadAccess:YES forUser:[PFUser currentUser]];
            [sensitive setWriteAccess:YES forUser:[PFUser currentUser]];
            _sensitiveData.ACL = sensitive;
            [_sensitiveData saveEventually];
            
        }
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Since you have logged in with your Facebook Account, you have no classic username and password to log in. But, in certain cases, we need to verify your identity. We do this by asking you the following personal PIN \n\n\n   %i%i%i%i  \n\n\nYou can change this PIN in your settings. Do not forget it.",nil),i1,i2,i3,i4];
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        alert.shouldDismissOnTapOutside = YES;
        
        [alert alertIsDismissed:^{
            NSLog(@"SCLAlertView dismissed!");
        }];
        
        [alert showInfo:self.tabBarController title:@"Info" subTitle:message closeButtonTitle:@"OK." duration:0.0f];
    }

}
- (void)easterButtonTap {
    /*if (monster == NO) {
        UILabel *titleLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)]; //<<---- Actually will be auto-resized according to frame of navigation bar;
        [titleLabelView setBackgroundColor:[UIColor clearColor]];
        [titleLabelView setTextAlignment: NSTextAlignmentCenter];
        [titleLabelView setTextColor:[UIColor whiteColor]];
        [titleLabelView setFont:[UIFont systemFontOfSize: 27]]; //<<--- Greatest font size
        [titleLabelView setAdjustsFontSizeToFitWidth:YES]; //<<---- Allow shrink
        // [titleLabelView setAdjustsLetterSpacingToFitWidth:YES];  //<<-- Another option for iOS 6+
        titleLabelView.text = @"👾";
        self.navigationItem.titleView = titleLabelView;
        monster = YES;
    }
    else if (monster == YES) {
        UIImageView *title = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNavigationBar"]];
        self.navigationItem.titleView = title;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"spaceInvader2"]) {
            SCLAlertView *alert =[[SCLAlertView alloc]init];
            UIColor *color = [UIColor colorWithRed:65.0/255.0 green:64.0/255.0 blue:144.0/255.0 alpha:1.0];
            [alert showCustom:self.tabBarController image:[UIImage imageNamed:@"spaceInvader"] color:color title:@"Space Invader" subTitle:NSLocalizedString(@"You found one of the rare space invaders! Go and find the others to see what happens!", nil) closeButtonTitle:@"OK" duration:0.0];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"spaceInvader2"];
        }
        monster = NO;
    }*/
    
}

-(void)viewWillDisappear:(BOOL)animated {
    self.tableView.tag = 0;
    [self.viewTop removeFromSuperview];
    [_filterView removeFromSuperview];
    _filterView.hidden = YES;
}
- (void)viewDidDisappear:(BOOL)animated{
    [_filterView removeFromSuperview];
    _filterView.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self existSelectedHashTag];
    self.tableView.tag = 1;
    [self loadObjects];
  
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.container.panMode = MFSideMenuPanModeDefault;
    //=============== init add topview =======================//
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat barHeight       = self.navigationController.navigationBar.frame.size.height + statusBarHeight;
    
    _viewTop = [[UIView alloc]initWithFrame:CGRectMake(0, barHeight, self.view.frame.size.width, 40.0f)];
    
    _filterView.hidden = YES;
    [self addTopView];
 
    //=============== Recent, Trending, Featured =============//
    ESCache *shared = [ESCache sharedCache];
    shared.selectedTap = RECENT;
    if ([shared.selectedTap isEqualToString:RECENT]) {
        [self.btnRecent setTitleColor:COLOR_GOLD forState:UIControlStateNormal];
        [self.btnTrending setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.btnFeatured setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    shared.followedUserPostObjects = [[NSMutableArray alloc]init];
    [self getFollowedUserArrayFromServer];
    [self getLikedUserArrayFromServer];
}

#pragma mark - PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    if (self.objects.count == 0 && ![[self queryForTable] hasCachedResult]) {
        
        if (!self.blankTimelineView.superview) {
            self.blankTimelineView.alpha = 0.0f;
            self.tableView.tableHeaderView = self.blankTimelineView;
            
            [UIView animateWithDuration:0.200f animations:^{
                self.blankTimelineView.alpha = 1.0f;
            }];
        }
    } else {
        [self.blankTimelineView removeFromSuperview];
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
        [self.tableView.tableHeaderView setBackgroundColor:[UIColor redColor]];
        [self.tableView reloadData];
    }
    [self.refreshControl endRefreshing];
}


#pragma mark - ()

- (void)inviteFriendsButtonAction:(id)sender {
    ESFindFriendsViewController *detailViewController = [[ESFindFriendsViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}
- (void)useNotificationWithString:(NSNotification *)notification //use notification method and logic
{
    // This key must match the key in postNotificationWithString: exactly.
    
    NSString *key = @"CommunicationStringValue";
    NSDictionary *dictionary = [notification userInfo];
    NSString *stringValueToUse = [dictionary valueForKey:key];
    if([stringValueToUse isEqualToString:@"ProfileOpen"])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];
        
        
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        
    }
    else if ([stringValueToUse isEqualToString:@"LogHimOut"])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
        
    }
    else if ([stringValueToUse isEqualToString:@"FindFriendsOpen"])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        ESFindFriendsViewController *findFriendsVC = [[ESFindFriendsViewController alloc] init];
        [self.navigationController pushViewController:findFriendsVC animated:YES];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
    }
    else if ([stringValueToUse isEqualToString:@"OpenRecentFeed"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        ESRecentViewController *popularView = [[ESRecentViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:popularView animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([stringValueToUse isEqualToString:@"OpenMediaFeed"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        ESMediaViewController *mediaView = [[ESMediaViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:mediaView animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([stringValueToUse isEqualToString:@"OpenLikesFeed"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        ESBestViewController *popularView = [[ESBestViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:popularView animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([stringValueToUse isEqualToString:@"openTransactions"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TransactionsVC* controller = [storyboard instantiateViewControllerWithIdentifier:@"transactionsVC"];
        [self.navigationController pushViewController:controller animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([stringValueToUse isEqualToString:@"openHelp"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HelpVC* controller = [storyboard instantiateViewControllerWithIdentifier:@"helpVC"];
        [self.navigationController pushViewController:controller animated:YES];
//        [self.navigationController presentViewController:controller animated:YES completion:nil];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([stringValueToUse isEqualToString:@"termsofuse"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:TERMS_URL]];
        webViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if ([stringValueToUse isEqualToString:@"MailUs"]) {
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        if ([MFMailComposeViewController canSendMail]) {
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
            NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
            NSString *model = [[UIDevice currentDevice] model];
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setToRecipients:[NSArray arrayWithObjects: @"support@yourdomain.com",nil]];
            [mailComposer setSubject:[NSString stringWithFormat: @"v%@ Support",version]];
            NSString *supportText = [NSString stringWithFormat:@"Device: %@\niOS Version: %@\nRequest ID: %@\n               _________________\n\n",model,iOSVersion,[[PFUser currentUser]objectId]];
            supportText = [supportText stringByAppendingString:NSLocalizedString(@"Please describe your problem or question. We will answer you within 24 hours. For a flawless treatment of your query, make sure to not delete the above indicated iOS Version and Request ID.\n               _________________", nil)];
            [mailComposer setMessageBody:supportText isHTML:NO];
            mailComposer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:mailComposer animated:YES completion:nil];
            
        } else {
            self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
      
            [alert showError:self.tabBarController title:NSLocalizedString(@"Hold On...", nil)
                    subTitle:NSLocalizedString(@"You have no active email account on your device - but you can still contact us under:\n\nsupport@yourdomain.com",nil)
            closeButtonTitle:@"OK" duration:0.0f];
        }
        
        
    }
    else if ([stringValueToUse isEqualToString:@"OpenSettings"])
    {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            ESSettingsViewController *settingsViewController = [[ESSettingsViewController alloc] initWithNibName:nil bundle:nil];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
            [self presentViewController:navController animated:YES completion:nil];
        });

        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        
    }

    else if ([stringValueToUse isEqualToString:@"AccountDeletion"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self performSelector:@selector(logoutHelper) withObject:nil afterDelay:0.8];
    }
    else if ([stringValueToUse isEqualToString:@"OpenPopularFeed"]) {
        self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{}];
        ESPopularViewController *popularView = [[ESPopularViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:popularView animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    
    }
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
     NSLog(@"clicked--- searchbar--1");
    NSString *str = searchBar.text;
    if ([str isEqualToString:@""]) {
        [self newHashtagSearch];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"clicked--- searchbar--2");
    NSString *str = searchBar.text;
    if ([str isEqualToString:@""]) {
        [self newHashtagSearch];
    }else{
        return YES;
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"search button on keyboard");
    [self newFilter];
    [searchBar resignFirstResponder];
}


#pragma mark - exist selected category Hashtag
- (void)existSelectedHashTag
{
    ESCache *shared = [ESCache sharedCache];
    NSString *strTemp = @"";
    if (shared.arrayFilterInfo.count >0) {
        for (int i = 0; i < shared.arrayFilterInfo.count; i++) {
            NSString *str = [shared.arrayFilterInfo objectAtIndex:i];
            strTemp = [strTemp stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
        }
//        _searchBar.text = strTemp;
        searchLabel.text = strTemp;
    }else{
//        _searchBar.text = @"";
        searchLabel.text = @"Searching All";
    }
}

#pragma mark - MFMailComposeViewController

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    
}

- (void)logoutHelper {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
}

- (void)newFilter
{
//    NSString *strHasTag = _searchBar.text;
    NSString *strHasTag = searchLabel.text;
    if (![strHasTag isEqualToString:@""]) {
        [self searchFilterPostObjectFromHashTag];
    }
}
- (void)searchFilterPostObjectFromHashTag{
    
    ESCache *shared = [ESCache sharedCache];
    if (shared.arrayFilterInfo.count >0) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [self.tempObject removeAllObjects];
        
        for (int i = 0; i < self.objects.count; i++) {
            
            dict = [self.objects objectAtIndex:i];
            NSMutableArray *arrCondition = [[NSMutableArray alloc]init];
            NSMutableArray *arrLocation  = [[NSMutableArray alloc]init];
            NSMutableArray *arrHashTag   = [[NSMutableArray alloc]init];
            arrCondition    = [dict objectForKey:kESCondition];
            arrLocation     = [dict objectForKey:kESLocationCountryInfo];
            arrHashTag      = [dict objectForKey:kESPhotoHashTag];
            BOOL isEqualInfo = NO;
            for (int j = 0; j<shared.arrayFilterInfo.count; j++) {
                NSString *strFilterInfo = [shared.arrayFilterInfo objectAtIndex:j];
               
                for (int k = 0; k < arrCondition.count; k++) {
                    NSString *strConditionInfo = [arrCondition objectAtIndex:k];
                    NSString *strLocationInfo  = [arrLocation objectAtIndex:k];
                    NSString *strHashTagInfo   = [arrHashTag objectAtIndex:k];
                    if ([strFilterInfo isEqualToString:strConditionInfo] || [strFilterInfo isEqualToString:strLocationInfo] || [strFilterInfo isEqualToString:strHashTagInfo]) {
                        isEqualInfo = YES;
                    }
                }
                
            }
            
            if (isEqualInfo == YES) {
                [self.tempObject addObject:[self.objects objectAtIndex:i]];
            }
            
        }
        
        [self.objects removeAllObjects];
        [self.objects addObjectsFromArray:self.tempObject];
        [self.tableView reloadData];
        
    }else{
        
    }
    
}

- (void)newHashtagSearch {
    ESSearchHashtagTableViewController *privateview = [[ESSearchHashtagTableViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:privateview];
    [self presentViewController:navController animated:YES completion:nil];
}
- (NSIndexPath *)_indexPathForPaginationCell {
    return [NSIndexPath indexPathForRow:0 inSection:[self.objects count]];
}

#pragma - mark get followed user array from server.
-(void)getFollowedUserArrayFromServer{
    arrFollowedUsers = [[NSMutableArray alloc]init];
    
    PFQuery *followingUserQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [followingUserQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [followingUserQuery whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    
    PFQuery *followedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [followedUsersQuery whereKey:kESPhotoUserKey matchesKey:kESActivityToUserKey inQuery:followingUserQuery];
    [followedUsersQuery includeKey:kESInstallationUserKey];
    [followedUsersQuery whereKeyDoesNotExist:@"type"];
    
    NSArray *arrTemp = [followedUsersQuery findObjects];
    [arrFollowedUsers addObjectsFromArray:arrTemp];
}

#pragma - mark getLikedUserArrayFromServer
- (void)getLikedUserArrayFromServer{
    arrLikedUsers = [[NSMutableArray alloc]init];
    PFQuery *likedQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [likedQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePhoto];
    [likedQuery includeKey:kESActivityPhotoKey];
    NSArray *arrTemp = [likedQuery findObjects];
    [arrLikedUsers addObjectsFromArray:arrTemp];
}

#pragma mark - Alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex == 0) {
            PFUser *user= [PFUser currentUser];
            [user setObject:@"Yes" forKey:@"acceptedTerms"];
            [user saveInBackground];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        else {
            TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:TERMS_URL]];
            webViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webViewController animated:YES];
        }
    }
    
}

@end
