//
//  ESPhotoTimelineAccountViewController.m


#import "ESPhotoTimelineAccountViewController.h"
#import "ESPhotoCell.h"
#import "ESAccountViewController.h"
#import "ESPhotoDetailsViewController.h"
#import "ESUtility.h"
#import "ESLoadMoreCell.h"
#import "AppDelegate.h"
#import "UIViewController+ScrollingNavbar.h"
#import "ESVideoTableViewCell.h"
#import "ESVideoDetailViewController.h"
#import "ESTextPostCell.h"
#import "ESRetweetCell.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

float previousAmount2;
NSInteger selectedSegment;


@interface ESPhotoTimelineAccountViewController ()

@property(nonatomic, strong) GADBannerView *bannerView;


@end

@implementation ESPhotoTimelineAccountViewController
@synthesize reusableSectionHeaderViews;
@synthesize reusableSectionFooterViews;
@synthesize shouldReloadOnAppear;
@synthesize outstandingSectionHeaderQueries, outstandingCountQueries, outstandingFollowQueries;
@synthesize outstandingSectionFooterQueries;
@synthesize activityIndicator, tapOnce, tapTwice;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ESPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.outstandingSectionHeaderQueries = [NSMutableDictionary dictionary];
        self.outstandingSectionFooterQueries = [NSMutableDictionary dictionary];
        
        // The className to query on
        self.parseClassName = kESPhotoClassKey;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 40;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
        self.reusableSectionFooterViews = [NSMutableSet setWithCapacity:3];
        self.loadingViewEnabled = YES;
        self.shouldReloadOnAppear = NO;
        
    }
    return self;
}

-(void)loadView {
    [super loadView];
    
}
#pragma mark - UIViewController

- (void)viewDidLoad {
//    ESCache *shared = [ESCache sharedCache];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:YES];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(loadObjects) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.tableView.backgroundColor = [UIColor clearColor];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.90 alpha:1];
    self.tableView.backgroundView = [[UIView alloc]initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = backgroundColor;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:ESTabBarControllerDidFinishEditingPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowingChanged:) name:ESUtilityUserFollowingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeletePhoto:) name:ESPhotoDetailsViewControllerUserDeletedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLikeOrUnlikePhoto:) name:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidCommentOnPhoto:) name:ESPhotoDetailsViewControllerUserCommentedOnPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidPublishPhoto:) name:@"videoUploadEnds" object:nil];

    
    self.navigationController.navigationBar.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    
    tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(didTapOnPhotoAction:)];
    tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(userDidLikeOrUnlikePhoto:)];
    
    tapOnce.numberOfTapsRequired = 1;
    tapTwice.numberOfTapsRequired = 2;
    //stops tapOnce from overriding tapTwice
    [tapOnce requireGestureRecognizerToFail:tapTwice];
    
}
- (void)viewWillAppear:(BOOL)animated {
    selectedSegment = 0;

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}

/*- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}*/


#pragma mark - UIViewController
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1) {
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat size = frame.size.height - 21;
        CGFloat framePercentageHidden = ((20 - frame.origin.y) / (frame.size.height - 1));
        CGFloat scrollOffset = scrollView.contentOffset.y;
        CGFloat scrollDiff = scrollOffset - previousAmount2;
        CGFloat scrollHeight = scrollView.frame.size.height;
        CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            frame.origin.y = 20;
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            frame.origin.y = -size;
        } else {
            frame.origin.y = MIN(20, MAX(-size, frame.origin.y - scrollDiff));
        }
        previousAmount2 = scrollOffset;
        
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:(1 - framePercentageHidden)];
        
        
    }
    else if (scrollView.tag == 2) {
        self.navigationController.navigationBar.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}
- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
    }
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
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    ESCache *shared = [ESCache sharedCache];
    if (selectedSegment == 0) {
        if ([shared.selectedSaleTypeTap isEqualToString:FORINSPIRATION]) {
//            [self addPhotoObjects:FORINSPIRATION];
//            [self addPhotoObjects];
           
        }
        if ([shared.selectedTap isEqualToString:FORSALE]) {
//            [self addPhotoObjects:FORSALE];
//            [self addPhotoObjects];
            
        }
        if ([shared.selectedTap isEqualToString:FORHIRE]) {
//            [self addPhotoObjects:FORHIRE];
//            [self addPhotoObjects];
           
        }
//--        NSInteger sections = self.objects.count;
        NSInteger sections = shared.saleTypeObjects.count;
        if (self.paginationEnabled && sections != 0)
            sections++;
        return sections+NUMBER_OF_STATIC_SECTIONS;
    }
    else return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ESCache *shared = [ESCache sharedCache];
    if (selectedSegment == 0) {
        if (section < NUMBER_OF_STATIC_SECTIONS) {
            return 4;
        }
        return 1;
    }
    //--else return self.objects.count+1;
    else return shared.saleTypeObjects.count+1;
    
}



#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ESCache *shared = [ESCache sharedCache];
    if (selectedSegment == 0) {
// --       if (section-NUMBER_OF_STATIC_SECTIONS == self.objects.count) {
//            // Load More section
//            return nil;
// --       }
        if (section-NUMBER_OF_STATIC_SECTIONS == shared.saleTypeObjects.count) {
            // Load More section
            return nil;
        }
        if (section < NUMBER_OF_STATIC_SECTIONS) {
            return nil;
        }
        
        ESPhotoHeaderView *headerView = [self dequeueReusableSectionHeaderView];
        
        if (!headerView) {
            headerView = [[ESPhotoHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f) buttons:ESPhotoHeaderButtonsDefault];
            headerView.delegate = self;
            [self.reusableSectionHeaderViews addObject:headerView];
        }
        
//--        PFObject *photo = [self.objects objectAtIndex:section-NUMBER_OF_STATIC_SECTIONS];
        PFObject *photo = [shared.saleTypeObjects objectAtIndex:section-NUMBER_OF_STATIC_SECTIONS];
        [headerView setPhoto:photo];
        
        return headerView;
    }
    else return nil;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//--    if (section-NUMBER_OF_STATIC_SECTIONS == self.objects.count) {
//        // Load More section
//        return nil;
//--    }
    ESCache *shared = [ESCache sharedCache];
    if (section-NUMBER_OF_STATIC_SECTIONS == shared.saleTypeObjects.count) {
        // Load More section
        return nil;
    }
    if (section < NUMBER_OF_STATIC_SECTIONS) {
        return nil;
    }
    ESPhotoFooterView *headerView = [self dequeueReusableSectionFooterView];
    
    if (!headerView) {
        headerView = [[ESPhotoFooterView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 64.0f) buttons:ESPhotoFooterButtonsDefault];
        headerView.delegate = self;
        [self.reusableSectionFooterViews addObject:headerView];
    }
    
//--    PFObject *photo = [self.objects objectAtIndex:section-NUMBER_OF_STATIC_SECTIONS];
    PFObject *photo = [shared.saleTypeObjects objectAtIndex:section-NUMBER_OF_STATIC_SECTIONS];
    [headerView setPhoto:photo];
    headerView.tag = section-NUMBER_OF_STATIC_SECTIONS;
    [headerView.likeButton setTag:section-NUMBER_OF_STATIC_SECTIONS];
    
    NSDictionary *attributesForPhoto = [[ESCache sharedCache] attributesForPhoto:photo];
    
    if (attributesForPhoto) {
        [headerView setLikeStatus:[[ESCache sharedCache] isPhotoLikedByCurrentUser:photo]];
        [headerView.likeImage setTitle:[[[ESCache sharedCache] likeCountForPhoto:photo] description] forState:UIControlStateNormal];
        [headerView.commentImage setTitle:[[[ESCache sharedCache] commentCountForPhoto:photo] description] forState:UIControlStateNormal];
        if ([[[[ESCache sharedCache] likeCountForPhoto:photo] description] isEqualToString:@"1"]) {
            [headerView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
        }
        else {
            [headerView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
        }
        if ([[[[ESCache sharedCache] commentCountForPhoto:photo] description] isEqualToString:@"1"]) {
            [headerView.labelComment setTitle:NSLocalizedString(@"comment", nil) forState:UIControlStateNormal];
        }
        else {
            [headerView.labelComment setTitle:NSLocalizedString(@"comments", nil) forState:UIControlStateNormal];
        }
        
        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
            [UIView animateWithDuration:0.500f animations:^{
                headerView.likeButton.alpha = 1.0f;
            }];
        }
    } else {
        headerView.likeButton.alpha = 0.0f;
        @synchronized(self) {
            // check if we can update the cache
            NSNumber *outstandingSectionFooterQueryStatus = [self.outstandingSectionFooterQueries objectForKey:@(section-NUMBER_OF_STATIC_SECTIONS)];
            if (!outstandingSectionFooterQueryStatus) {
                PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
                if ([photo objectForKey:kESVideoFileKey]) {
                    query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
                }
                if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"])
                {
                    query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
                }
                [query setLimit:1000];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    @synchronized(self) {
                        [self.outstandingSectionHeaderQueries removeObjectForKey:@(section-NUMBER_OF_STATIC_SECTIONS)];
                        
                        if (error) {
                            return;
                        }
                        
                        NSMutableArray *likers = [NSMutableArray array];
                        NSMutableArray *commenters = [NSMutableArray array];
                        
                        BOOL isLikedByCurrentUser = NO;
                        
                        for (PFObject *activity in objects) {
                            if (([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost])&& [activity objectForKey:kESActivityFromUserKey]) {
                                [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                            } else if (([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPhoto]||[[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentVideo] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPost]) && [activity objectForKey:kESActivityFromUserKey]) {
                                [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                            }
                            
                            if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto] || [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo]|| [[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost]) {
                                    isLikedByCurrentUser = YES;
                                }
                            }
                        }
                        
                        
                        [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                        
                        if (headerView.tag != section) {
                            return;
                        }
                        
                        [headerView setLikeStatus:[[ESCache sharedCache] isPhotoLikedByCurrentUser:photo]];
                        [headerView.likeImage setTitle:[[[ESCache sharedCache] likeCountForPhoto:photo] description] forState:UIControlStateNormal];
                        [headerView.commentImage setTitle:[[[ESCache sharedCache] commentCountForPhoto:photo] description] forState:UIControlStateNormal];
                        if ([[[[ESCache sharedCache] likeCountForPhoto:photo] description] isEqualToString:@"1"]) {
                            [headerView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                        }
                        else {
                            [headerView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        }
                        if ([[[[ESCache sharedCache] commentCountForPhoto:photo] description] isEqualToString:@"1"]) {
                            [headerView.labelComment setTitle:NSLocalizedString(@"comment", nil) forState:UIControlStateNormal];
                        }
                        else {
                            [headerView.labelComment setTitle:NSLocalizedString(@"comments", nil) forState:UIControlStateNormal];
                        }
                        if (headerView.likeButton.alpha < 1.0f || headerView.commentButton.alpha < 1.0f) {
                            [UIView animateWithDuration:0.500f animations:^{
                                headerView.likeButton.alpha = 1.0f;
                            }];
                        }
                    }
                }];
            }
        }
    }
    
    return headerView;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (selectedSegment == 0) {
// --       if (section-NUMBER_OF_STATIC_SECTIONS == self.objects.count) {
//            return 0.0f;
// --       }
        ESCache *shared = [ESCache sharedCache];
        if (section-NUMBER_OF_STATIC_SECTIONS == shared.saleTypeObjects.count) {
            return 0.0f;
        }
        else if (section < NUMBER_OF_STATIC_SECTIONS) {
            return 0.0f;
        }
        return 44.0f;
    }
    else return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (selectedSegment == 0) {
//--        if (section-NUMBER_OF_STATIC_SECTIONS == self.objects.count) {
//            return 0.0f;
//--        }
        ESCache *shared = [ESCache sharedCache];
        if (section-NUMBER_OF_STATIC_SECTIONS == shared.saleTypeObjects.count) {
            return 0.0f;
        }
        else if (section < NUMBER_OF_STATIC_SECTIONS) {
            return 0;
        }
        return 84.0f;   //mod:16.0f
    }
    else return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedSegment == 0) {
//--        if (indexPath.section-NUMBER_OF_STATIC_SECTIONS >= self.objects.count && indexPath.section >= NUMBER_OF_STATIC_SECTIONS) {
//            // Load More Section
//            return 44.0f;
//--        }
        ESCache *shared = [ESCache sharedCache];
        if (indexPath.section-NUMBER_OF_STATIC_SECTIONS >= shared.saleTypeObjects.count && indexPath.section >= NUMBER_OF_STATIC_SECTIONS) {
            // Load More Section
            return 44.0f;
        }
//--        PFObject *object = [self.objects objectAtIndex:indexPath.section];
        PFObject *object = [shared.saleTypeObjects objectAtIndex:indexPath.section];
        if ([[object objectForKey:@"type"] isEqualToString:@"text"]) {
            CGSize labelSize = [[object objectForKey:@"text"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16]
                                                         constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 100)
                                                             lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat labelHeight = labelSize.height;
            return labelHeight+10;
        }
        if([[object objectForKey:@"type"] isEqualToString:@"retweet"]) {
            CGSize labelSize = [[object objectForKey:@"text"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16]
                                                         constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 100)
                                                             lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat labelHeight = labelSize.height;
            return labelHeight+40;
        }
        if (indexPath.section < NUMBER_OF_STATIC_SECTIONS) {
            return 50;
        }
        return [UIScreen mainScreen].bounds.size.width;
    }
    
    else return 44;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//--    if (indexPath.section == self.objects.count && self.paginationEnabled) {
//        // Load More Cell
//        [self loadNextPage];
//--    }
    ESCache *shared = [ESCache sharedCache];
    if (indexPath.section == shared.saleTypeObjects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
    else {
// --       PFObject *object = [self.objects objectAtIndex:indexPath.section];
        PFObject *object = [shared.saleTypeObjects objectAtIndex:indexPath.section];
        
        if ([object objectForKey:kESVideoOrPhotoTypeKey] && [object objectForKey:kESVideoFileKey]) {
            ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            if (cell.movie.playbackState != MPMoviePlaybackStatePlaying) {
                
                cell.mediaItemButton.hidden = YES;
                cell.imageView.hidden = YES;
                [cell.movie prepareToPlay];
                [cell.movie play];
                cell.movie.view.hidden = NO;
                
            }
        }
    }
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [followingActivitiesQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [followingActivitiesQuery whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    followingActivitiesQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *photosFromFollowedUsersQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromFollowedUsersQuery whereKey:kESPhotoUserKey matchesKey:kESActivityToUserKey inQuery:followingActivitiesQuery];
    [photosFromFollowedUsersQuery whereKeyDoesNotExist:@"type"];
    [photosFromFollowedUsersQuery whereKeyExists:kESPhotoPictureKey];
    
    PFQuery *photosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [photosFromCurrentUserQuery whereKey:kESPhotoUserKey equalTo:[PFUser currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:kESPhotoPictureKey];
    [photosFromCurrentUserQuery whereKeyDoesNotExist:@"type"];
    
    PFQuery *videosFromCurrentUserQuery = [PFQuery queryWithClassName:self.parseClassName];
    [videosFromCurrentUserQuery whereKey:kESPhotoUserKey equalTo:[PFUser currentUser]];
    [videosFromCurrentUserQuery whereKeyExists:kESVideoOrPhotoTypeKey];
    //[videosFromCurrentUserQuery whereKeyExists:kESVideoFileKey];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:photosFromFollowedUsersQuery, photosFromCurrentUserQuery, videosFromCurrentUserQuery, nil]];
    [query includeKey:kESPhotoUserKey];
    [query includeKey:kESPostRetweetedUserKey];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
//--    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
//        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
//--    }
    ESCache *shared = [ESCache sharedCache];
    if (shared.saleTypeObjects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
//--    if (indexPath.section < NUMBER_OF_STATIC_SECTIONS) {
//        return nil;
//    } else if (indexPath.section > (self.objects.count + NUMBER_OF_STATIC_SECTIONS)) {
//        return nil;
//    } else if (indexPath.section-NUMBER_OF_STATIC_SECTIONS < self.objects.count){
//        return [self.objects objectAtIndex:indexPath.section-NUMBER_OF_STATIC_SECTIONS];
//--    }
    ESCache *shared = [ESCache sharedCache];
    if (indexPath.section < NUMBER_OF_STATIC_SECTIONS) {
        return nil;
    } else if (indexPath.section > (shared.saleTypeObjects.count + NUMBER_OF_STATIC_SECTIONS)) {
        return nil;
    } else if (indexPath.section-NUMBER_OF_STATIC_SECTIONS < shared.saleTypeObjects.count){
        return [shared.saleTypeObjects objectAtIndex:indexPath.section-NUMBER_OF_STATIC_SECTIONS];
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(ESVideoTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedSegment == 0) {
        if ([cell isKindOfClass:[ESVideoTableViewCell class]]) {
            [cell.movie stop];
            cell.imageView.hidden = NO;
            cell.mediaItemButton.hidden = NO;
        }
    }
    
}
- (void) dummyTapForVideo:(id)sender {
    UIButton *clicked = (UIButton *) sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:clicked.tag];
    [self performSelector:@selector(tableView:didSelectRowAtIndexPath:) withObject:self.tableView withObject:indexPath];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    static NSString *TextIdentifier = @"TextCell";
    static NSString *VideoIdentifier = @"VideoCell";
    static NSString *RetweetIdentifier = @"RetweetCell";

    ESCache *shared = [ESCache sharedCache];
//--    if (indexPath.section == self.objects.count) {
//        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
//        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
//        return cell;
//--    }
    if (indexPath.section == shared.saleTypeObjects.count) {
        // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
    }
    else if ([[object objectForKey:@"type"] isEqualToString:@"video"]) {
        ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:VideoIdentifier];
        
        if (cell == nil) {
            cell = [[ESVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:VideoIdentifier];
            
            [cell.mediaItemButton addTarget:self action:@selector(dummyTapForVideo:) forControlEvents:UIControlEventTouchUpInside];
            [cell.binocularsBtn addTarget:self action:@selector(didTapOnBinocularAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        cell.mediaItemButton.tag = indexPath.section;
        cell.binocularsBtn.tag   = indexPath.section;
        //======= hash tag and price ========//
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//--        dict = [self.objects objectAtIndex:indexPath.section];
        dict = [shared.saleTypeObjects objectAtIndex:indexPath.section];
        NSString *strHashTag = [dict objectForKey:kESPhotoHashTags];
        NSString *strPrice = [dict objectForKey:kESPhotoItemPrice];
        cell.tagLabel.text = strHashTag;
        cell.costtagLabel.text = [NSString stringWithFormat:@"$%@",strPrice];
        //==================================//
        //        cell.tagLabel.text = @"Shoes";
        //        cell.costtagLabel.text = @"$20 buy";
        
        float tagWidth = [cell.tagLabel.text
                          boundingRectWithSize:cell.tagLabel.frame.size
                          options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{ NSFontAttributeName:cell.tagLabel.font }
                          context:nil].size.width;
        
        float costWidth = [cell.tagLabel.text
                           boundingRectWithSize:cell.tagLabel.frame.size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{ NSFontAttributeName:cell.tagLabel.font }
                           context:nil].size.width;
        
        [cell.tagTitleBar setFrame: CGRectMake(cell.imageView.frame.size.width - (tagWidth + costWidth + 80), cell.imageView.frame.size.height - 35, tagWidth + costWidth + 60, 28)];
        [cell.tagLabel setFrame:CGRectMake(20, 0, tagWidth + 20, 28)];
        [cell.costtagLabel setFrame:CGRectMake(tagWidth + 30 , 0, costWidth + 20, 28)];
        
        
        if ([[object objectForKey:kESPhotoShowTags] isEqualToString:@"yes"]) {
            [cell.binocularsBtn setImage:[UIImage imageNamed:@"selectedBinoculars.png"] forState:UIControlStateNormal];
            cell.tagTitleBar.hidden = NO;
            
        } else {
            [cell.binocularsBtn setImage:[UIImage imageNamed:@"binoculars.png"] forState:UIControlStateNormal];
            cell.tagTitleBar.hidden = YES;
        }
        
        
        
        
        cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto"];
        // cell.imageView.hidden= YES;
        if (object) {
            
            cell.imageView.file = [object objectForKey:@"videoThumbnail"];
            [cell.imageView loadInBackground];
            
            PFFile *video =[object objectForKey:@"file"];
            [video getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    NSString *string = [NSString stringWithFormat:@"cell%li.m4v", (long)cell.mediaItemButton.tag];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:string];
                    [data writeToFile:appFile atomically:YES];
                    NSURL *movieUrl = [NSURL fileURLWithPath:appFile];
                    [cell.movie setContentURL:movieUrl];
                }
            }];
            
        }
        return cell;
    }
    else if ([[object objectForKey:@"type"] isEqualToString:@"text"]) {
        ESTextPostCell *cell = (ESTextPostCell *)[tableView dequeueReusableCellWithIdentifier:TextIdentifier];
        if (cell == nil) {
            cell = [[ESTextPostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TextIdentifier];
            
            [cell.itemButton addTarget:self action:@selector(didTapOnTextPostAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.itemButton.tag = indexPath.section;
        
        // cell.imageView.hidden= YES;
        if (object) {
            CGSize labelSize = [[object objectForKey:@"text"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:16]
                                                         constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 100)
                                                             lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat labelHeight = labelSize.height;
            cell.postText.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width-20, labelHeight+10);
            cell.postText.text = [object objectForKey:@"text"];
            cell.itemButton.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width-20, labelHeight+10);
            
        }
        return cell;
    }
    else if ([[object objectForKey:@"type"] isEqualToString:@"retweet"]) {
        ESRetweetCell *cell = (ESRetweetCell *)[tableView dequeueReusableCellWithIdentifier:RetweetIdentifier];
        if (cell == nil) {
            cell = [[ESRetweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RetweetIdentifier];
            
            [cell.itemButton addTarget:self action:@selector(didTapOnRetweetPostAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        cell.itemButton.tag = indexPath.section;
        
        // cell.imageView.hidden= YES;
        if (object) {
            PFUser *op = [object objectForKey:kESPostRetweetedUserKey];
            CGSize labelSize = [[object objectForKey:kESPostTextKey] sizeWithFont:cell.postText.font
                                                                constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 100)
                                                                    lineBreakMode:NSLineBreakByWordWrapping];
            CGFloat labelHeight = labelSize.height;
            
            CGSize OPLabelSize = [[op objectForKey:kESUserDisplayNameKey] sizeWithFont:cell.OPName.font
                                                                     constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/2 - 10, 100)
                                                                         lineBreakMode:NSLineBreakByWordWrapping];
            
            CGSize OPmentionLabelSize = [[NSString stringWithFormat:@"@%@",[op objectForKey:kESUserMentionNameKey]] sizeWithFont:cell.OPmentionName.font
                                                                                                               constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/2 - 10, 100)
                                                                                                                   lineBreakMode:NSLineBreakByWordWrapping];
            
            cell.postText.frame = CGRectMake(10, 30, [UIScreen mainScreen].bounds.size.width-20, labelHeight+10);
            cell.itemButton.frame = CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width/2, labelHeight+40);
            cell.OPName.frame = CGRectMake(10, 15, OPLabelSize.width, OPLabelSize.height);
            cell.OPmentionName.frame = CGRectMake(cell.OPName.frame.origin.x+OPLabelSize.width + 5, cell.OPName.frame.origin.y, OPmentionLabelSize.width, OPmentionLabelSize.height);
            
            cell.OPmentionName.text = [NSString stringWithFormat:@"@%@",[op objectForKey:kESUserMentionNameKey]];
            cell.OPName.text = [op objectForKey:kESUserDisplayNameKey];
            cell.postText.text = [object objectForKey:kESPostTextKey];
        }
        return cell;
    }
    else {
        ESPhotoCell *cell = (ESPhotoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[ESPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell.mediaItemButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
            //            [cell.binocularsBtn addTarget:self action:@selector(didTapOnBinocularAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.mediaItemButton.tag = indexPath.section;
        /* cell.binocularsBtn.tag   = indexPath.section;
         
         //======= hash tag and price ========//
         NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
         dict = [self.objects objectAtIndex:indexPath.section];
         NSString *strHashTag = [dict objectForKey:kESPhotoHashTags];
         NSString *strPrice = [dict objectForKey:kESPhotoItemPrice];
         cell.tagLabel.text = strHashTag;
         cell.costtagLabel.text = [NSString stringWithFormat:@"$%@",strPrice];
         //==================================//
         //        cell.tagLabel.text = @"Shoes";
         //        cell.costtagLabel.text = @"$20 buy";
         
         float tagWidth = [cell.tagLabel.text
         boundingRectWithSize:cell.tagLabel.frame.size
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{ NSFontAttributeName:cell.tagLabel.font }
         context:nil].size.width;
         
         float costWidth = [cell.tagLabel.text
         boundingRectWithSize:cell.tagLabel.frame.size
         options:NSStringDrawingUsesLineFragmentOrigin
         attributes:@{ NSFontAttributeName:cell.tagLabel.font }
         context:nil].size.width;
         
         [cell.tagTitleBar setFrame: CGRectMake(cell.imageView.frame.size.width - (tagWidth + costWidth + 80), cell.imageView.frame.size.height - 35, tagWidth + costWidth + 60, 28)];
         [cell.tagLabel setFrame:CGRectMake(20, 0, tagWidth + 20, 28)];
         [cell.costtagLabel setFrame:CGRectMake(tagWidth + 30 , 0, costWidth + 20, 28)];
         
         
         if ([[object objectForKey:kESPhotoShowTags] isEqualToString:@"yes"]) {
         [cell.binocularsBtn setImage:[UIImage imageNamed:@"selectedBinoculars.png"] forState:UIControlStateNormal];
         cell.tagTitleBar.hidden = NO;
         
         } else {
         [cell.binocularsBtn setImage:[UIImage imageNamed:@"binoculars.png"] forState:UIControlStateNormal];
         cell.tagTitleBar.hidden = YES;
         }
         */
        
        cell.imageView.image = [UIImage imageNamed:@"PlaceholderPhoto"];
        
        if (object) {
            cell.imageView.file = [object objectForKey:kESPhotoPictureKey];
            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            //if ([cell.imageView.file isDataAvailable]) {
            [cell.imageView loadInBackground];
            
            //}
        }
        
        return cell;
    }
}


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
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView bringSubviewToFront:cell];
}

#pragma mark - ESPhotoTimelineAccountViewController

- (ESPhotoHeaderView *)dequeueReusableSectionHeaderView {
    for (ESPhotoHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
}

- (ESPhotoFooterView *)dequeueReusableSectionFooterView {
    for (ESPhotoFooterView *sectionFooterView in self.reusableSectionFooterViews) {
        if (!sectionFooterView.superview) {
            // we found a section header that is no longer visible
            return sectionFooterView;
        }
    }
    
    return nil;
}

#pragma mark - ESPhotoHeaderViewDelegate

- (void)photoHeaderView:(ESPhotoHeaderView *)photoHeaderView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
    
}

#pragma mark - ESPhotoFooterViewDelegate

- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapUserButton:(UIButton *)button user:(PFUser *)user {
    ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
    [accountViewController setUser:user];
    [self.navigationController pushViewController:accountViewController animated:YES];
    
}


- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapLikePhotoButton:(UIButton *)button photo:(PFObject *)photo {
    // Disable the button so users cannot send duplicate requests
    [photoFooterView shouldEnableLikeButton:NO];
    NSNumber *number = [NSNumber numberWithInt:0];
    [photoFooterView shouldReEnableLikeButton:number];
    
    BOOL liked = !button.selected;
    [photoFooterView setLikeStatus:liked];
    
    NSString *originalButtonTitle = photoFooterView.likeImage.titleLabel.text;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSNumber *likeCount = [numberFormatter numberFromString:photoFooterView.likeImage.titleLabel.text];
    if (liked) {
        likeCount = [NSNumber numberWithInt:[likeCount intValue] + 1];
        [[ESCache sharedCache] incrementLikerCountForPhoto:photo];
    } else {
        if ([likeCount intValue] > 0) {
            likeCount = [NSNumber numberWithInt:[likeCount intValue] - 1];
        }
        [[ESCache sharedCache] decrementLikerCountForPhoto:photo];
    }
    
    [[ESCache sharedCache] setPhotoIsLikedByCurrentUser:photo liked:liked];
    
    if ([[numberFormatter stringFromNumber:likeCount] isEqualToString:@"1"]) {
        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
    }
    else {
        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
    }
    [photoFooterView.likeImage setTitle:[numberFormatter stringFromNumber:likeCount] forState:UIControlStateNormal];
    
    if (liked) {
        if ([photo objectForKey:kESVideoFileKey]) { //check if it is a video actually
            [ESUtility likeVideoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        
                    }
                }
                
            }];
        }
        else if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"]) { //check if it is a text post actually
            [ESUtility likePostInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        
                    }
                }
                
            }];
        }
        else {
            [ESUtility likePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                        
                    }
                }
                
            }];
        }
    } else {
        if ([photo objectForKey:kESVideoFileKey]) { //check if it is a video actually
            [ESUtility unlikeVideoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:!succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                    }
                }
                
            }];
        } else if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"]) { //check if it is a video actually
            [ESUtility unlikePostInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:!succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                    }
                }
                
            }];
        } else {
            [ESUtility unlikePhotoInBackground:photo block:^(BOOL succeeded, NSError *error) {
                ESPhotoFooterView *actualHeaderView = (ESPhotoFooterView *)[self tableView:self.tableView viewForFooterInSection:button.tag];
                
                
                NSNumber *number = [NSNumber numberWithInt:1];
                [photoFooterView performSelector:@selector(shouldReEnableLikeButton:) withObject:number afterDelay:0.5];
                
                [actualHeaderView shouldEnableLikeButton:YES];
                [actualHeaderView setLikeStatus:!succeeded];
                
                if (!succeeded) {
                    [actualHeaderView.likeImage setTitle:originalButtonTitle forState:UIControlStateNormal];
                    if ([originalButtonTitle isEqualToString:@"1"]) {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"like", nil) forState:UIControlStateNormal];
                    }
                    else {
                        [photoFooterView.labelButton setTitle:NSLocalizedString(@"likes", nil) forState:UIControlStateNormal];
                    }
                }
                
            }];
        }
        
    }
}

- (void)photoHeaderView:(ESPhotoHeaderView *)photoHeaderView didTapReportPhoto:(UIButton *)button photo:(PFObject *)photo {
    
}

- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapCommentOnPhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    UITableView *tableView = self.tableView; // Or however you get your table view
    NSArray *paths = [tableView indexPathsForVisibleRows];
    
    //  For getting the cells themselves
    ESCache *shared = [ESCache sharedCache];
    for (NSIndexPath *path in paths) {
//--        if (path.section >= [self.objects count] || path.section < 0) {
//            break;
//        }
        
//        PFObject *object = [self.objects objectAtIndex:path.section];
        
        if (path.section >= [shared.saleTypeObjects count] || path.section < 0) {
            break;
        }
        PFObject *object = [shared.saleTypeObjects objectAtIndex:path.section];
        
        if ([object objectForKey:@"type"] && [object objectForKey:kESVideoFileKey]) {
            ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
            [cell.movie stop];
            cell.mediaItemButton.hidden = NO;
            [cell.imageView setHidden:NO];
            
        }
    }
    
    if ([photo objectForKey:@"file"]) {
        ESVideoDetailViewController *videoDetailsVC = [[ESVideoDetailViewController alloc] initWithPhoto:photo];
        [self.navigationController pushViewController:videoDetailsVC animated:YES];
    }
    else {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo andTextPost:@"NO"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
    
}
- (void)photoFooterView:(ESPhotoFooterView *)photoFooterView didTapSharePhotoButton:(UIButton *)button  photo:(PFObject *)photo {
    UITableView *tableView = self.tableView; // Or however you get your table view
    NSArray *paths = [tableView indexPathsForVisibleRows];
    
    //  For getting the cells themselves
    ESCache *shared = [ESCache sharedCache];
    for (NSIndexPath *path in paths) {
// --       if (path.section >= [self.objects count] || path.section < 0) {
//            break;
//        }
//--        PFObject *object = [self.objects objectAtIndex:path.section];
        if (path.section >= [shared.saleTypeObjects count] || path.section < 0) {
            break;
        }
        PFObject *object = [shared.saleTypeObjects objectAtIndex:path.section];
        if ([object objectForKey:@"type"] && [object objectForKey:kESVideoFileKey]) {
            ESVideoTableViewCell *cell = (ESVideoTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
            [cell.movie stop];
            cell.mediaItemButton.hidden = NO;
            [cell.imageView setHidden:NO];
            
        }
    }
    if ([photo objectForKey:kESVideoFileKey]) {
        [[photo objectForKey:kESVideoFileThumbnailKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                
                // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
                
                [activityItems addObject:[UIImage imageWithData:data]];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
                });
            }
        }];
    }else if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"]) {
        NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
        
        /*    // Prefill caption if this is the original poster of the photo, and then only if they added a caption initially.
         if ([[[PFUser currentUser] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]] && [self.objects count] > 0) {
         PFObject *firstActivity = self.objects[0];
         if ([[[firstActivity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[photo objectForKey:kESPhotoUserKey] objectId]]) {
         NSString *commentString = [firstActivity objectForKey:kESActivityContentKey];
         [activityItems addObject:commentString];
         }
         } */
        
        [activityItems addObject:[NSURL URLWithString:[NSString stringWithFormat:APP_URL]]];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        });
        
        
    }
    else {
        [[photo objectForKey:kESPhotoPictureKey] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:3];
                
                [activityItems addObject:[UIImage imageWithData:data]];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                    activityViewController.popoverPresentationController.sourceView = self.navigationController.navigationBar;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
                });
            }
        }];
    }
    
}


#pragma mark - ()

- (NSIndexPath *)indexPathForObject:(PFObject *)targetObject {
//--    for (int i = 0; i < self.objects.count; i++) {
//        PFObject *object = [self.objects objectAtIndex:i];
//        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
//            return [NSIndexPath indexPathForRow:0 inSection:i];
//        }
//--    }
    ESCache *shared = [ESCache sharedCache];
    for (int i = 0; i < shared.saleTypeObjects.count; i++) {
        PFObject *object = [shared.saleTypeObjects objectAtIndex:i];
        if ([[object objectId] isEqualToString:[targetObject objectId]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
    }
    return nil;
}

- (void)userDidLikeOrUnlikePhoto:(NSNotification *)note {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidCommentOnPhoto:(NSNotification *)note{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)userDidDeletePhoto:(NSNotification *)note {
    // refresh timeline after a delay
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        [self loadObjects];
    });
}

- (void)userDidPublishPhoto:(NSNotification *)note {
//    if (self.objects.count > 0) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
    ESCache *shared = [ESCache sharedCache];
    if (shared.saleTypeObjects.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self loadObjects];
}

- (void)userFollowingChanged:(NSNotification *)note {
    self.shouldReloadOnAppear = YES;
}


- (void)didTapOnPhotoAction:(UIButton *)sender {
    
    ESCache *shared = [ESCache sharedCache];
//    PFObject *photo = [self.objects objectAtIndex:sender.tag];
    PFObject *photo = [shared.saleTypeObjects objectAtIndex:sender.tag];
    if (photo) {
        PFUser *postingUser = [photo objectForKey:kESPhotoUserKey];
        PFFile *photoFile = [photo objectForKey:kESPhotoPictureKey];
        ESCache *shared = [ESCache sharedCache];
        [shared.selectedItemObjects removeAllObjects];
        shared.selectedItemObjectUser = [photo objectForKey:kESPhotoUserKey];
        NSString *strPostObjectId = photo.objectId;
        PFQuery *query = [PFQuery queryWithClassName:kESPostItemClassKey];
        
        [query whereKey:kESPostPhotoObjectId equalTo:strPostObjectId];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (!error) {
                [shared.selectedItemObjects addObjectsFromArray:objects];
                if (photo) {
                    //                    [self showFullPhotoItemView:photoFile postId:strItemObjectId postUser:postingUser];
                    [self getItemObjectOfTypeFromServer:postingUser postId:strPostObjectId postFile:photoFile];
                }
            }else{
                NSLog(@"error --- ");
                if (photo) {
                    //                    [self showFullPhotoItemView:photoFile postId:strItemObjectId postUser:postingUser];
                }
            }
        }];
    }
    
    /*PFObject *photo = [self.objects objectAtIndex:sender.tag];
     if (photo) {
     
     ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:photo andTextPost:@"NO"];
     [self.navigationController pushViewController:photoDetailsVC animated:YES];
     }*/
}

#pragma mark - get itemobject of type(bookmarked) from server.
- (void)getItemObjectOfTypeFromServer:(PFUser *)postingUser postId:(NSString *)photoPostId postFile:(PFFile *)photoPostFile{
    
    NSMutableArray *arrRegisteredBookmarkItemObjectType = [[NSMutableArray alloc]init];
    NSMutableArray *arrRegisteredOwnedItemObjectType    = [[NSMutableArray alloc]init];
    
    PFQuery *bookmarkQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    [bookmarkQuery whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [bookmarkQuery whereKey:kESActivityToUserKey equalTo:postingUser];
    [bookmarkQuery whereKey:kESActivityPhotoObjectIdKey equalTo:photoPostId];
    [bookmarkQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeItemBookmark];
    
    //================= get itemobject of type(owned) from server =========//
    PFQuery *ownedQuery = [PFQuery queryWithClassName:kESActivityClassKey];
    //    [ownedQuery whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [ownedQuery whereKey:kESActivityToUserKey equalTo:postingUser];
    [ownedQuery whereKey:kESActivityPhotoObjectIdKey equalTo:photoPostId];
    [ownedQuery whereKey:kESActivityTypeKey equalTo:kESActivityTypeItemOwned];
    //=====================================================================//
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [bookmarkQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error){
        
        if (!error) {
            [arrRegisteredBookmarkItemObjectType addObjectsFromArray:objects];
            NSLog(@"success --- ");
            /* [self showFullPhotoItemView:photoPostFile postId:photoPostId postUser:postingUser registeredItemObjectState:arrRegisteredItemObjectType]; */
            [ownedQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error){
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (!error){
                    
                    [arrRegisteredOwnedItemObjectType addObjectsFromArray:objects];
                    
                    [self showFullPhotoItemView:photoPostFile postId:photoPostId postUser:postingUser bookmarkedItemObjectState:arrRegisteredBookmarkItemObjectType ownedItemObjectState:arrRegisteredOwnedItemObjectType];
                }else{
                    NSLog(@"owned error --- ");
                }
                
            }];
            
        }else{
            NSLog(@"error --- ");
            
        }
    }];
}

#pragma show full photo item view
- (void)showFullPhotoItemView:(PFFile *)photoFile postId:(NSString *)photoPostId postUser:(PFUser *)postingUser bookmarkedItemObjectState:(NSMutableArray *)regItemObjStateArray ownedItemObjectState:(NSMutableArray *)regOwnedItemObjStateArray{
    
    //========= owned item object count and id name array ============//
    NSMutableArray *arrItemObjectIdCount = [[NSMutableArray alloc]init];
    
    if (regOwnedItemObjStateArray.count > 0) {
        
        for (int i = 0; i<regOwnedItemObjStateArray.count; i++) {
            
            NSDictionary    *dict           = [regOwnedItemObjStateArray objectAtIndex:i];
            NSString        *strItemObjId   = [dict objectForKey:kESActivityItemObjectIdKey];
            PFUser          *toUser         = [dict objectForKey:kESActivityToUserKey];
            NSString        *toUserObjectId = toUser.objectId;
            PFUser          *fromUser       = [dict objectForKey:kESActivityFromUserKey];
            NSString        *fromUserObjectId = fromUser.objectId;
            
            NSMutableDictionary *dictItemObjIdAndUserId = [[NSMutableDictionary alloc]init];
            
            [dictItemObjIdAndUserId setObject:toUserObjectId forKey:kESActivityToUserKey];
            [dictItemObjIdAndUserId setObject:fromUserObjectId forKey:kESActivityFromUserKey];
            [dictItemObjIdAndUserId setObject:strItemObjId forKey:kESActivityItemObjectIdKey];
            
            
            [arrItemObjectIdCount addObject:dictItemObjIdAndUserId];
        }
        //        NSSet *uniqueElements = [NSSet setWithArray:arrItemObjectIdCount];
        //        arrItemObjectIdCount  = [[uniqueElements allObjects]mutableCopy];
    }
    
    //==============================================//
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (data) {
            self.photoImgView = [[PFImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 375.0f, 667.0f)];
            self.photoImgView.image = [UIImage imageWithData:data];
            //     Create image info
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
#if TRY_AN_ANIMATED_GIF == 1
            imageInfo.imageURL = [NSURL URLWithString:@"http://media.giphy.com/media/O3QpFiN97YjJu/giphy.gif"];
#else
            imageInfo.image = self.photoImgView.image;
#endif
            imageInfo.referenceRect = self.photoImgView.frame;
            imageInfo.referenceView = self.photoImgView.superview;
            imageInfo.referenceContentMode = self.photoImgView.contentMode;
            imageInfo.referenceCornerRadius = self.photoImgView.layer.cornerRadius;
            
            // Setup view controller
            JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                   initWithImageInfo:imageInfo
                                                   mode:JTSImageViewControllerMode_Image
                                                   backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred
                                                   postId:photoPostId postUser:postingUser
                                                   registeredItemObjectBookmarkState:regItemObjStateArray
                                                   registeredOwnedItemObjectState:regOwnedItemObjStateArray
                                                   selectedItemObjectIdArray:arrItemObjectIdCount];
            
            // Present the view controller.
            [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
        }
    }];
    
}

- (void)didTapOnTextPostAction:(UIButton *)sender {
    ESCache *shared = [ESCache sharedCache];
//    PFObject *text = [self.objects objectAtIndex:sender.tag];
    PFObject *text = [shared.saleTypeObjects objectAtIndex:sender.tag];
    if (text) {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:text andTextPost:@"YES"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
        
        
    }
}

- (void)didTapOnBinocularAction:(UIButton *) sender {
    /*PFObject *temp = [self.objects objectAtIndex:sender.tag];
     
     if ([[temp objectForKey:kESPhotoShowTags] isEqualToString:@"yes"]) {
     [temp setObject:@"no" forKey:kESPhotoShowTags];
     } else {
     [temp setObject:@"yes" forKey:kESPhotoShowTags];
     }
     
     [self.tableView reloadData];*/
}

- (void)didTapOnRetweetPostAction:(UIButton *)sender {
    ESCache *shared = [ESCache sharedCache];
    
//    PFObject *text = [self.objects objectAtIndex:sender.tag];
    PFObject *text = [shared.saleTypeObjects objectAtIndex:sender.tag];
    if (text) {
        ESPhotoDetailsViewController *photoDetailsVC = [[ESPhotoDetailsViewController alloc] initWithPhoto:text andTextPost:@"YES-RETWEET"];
        [self.navigationController pushViewController:photoDetailsVC animated:YES];
    }
}

- (void)postNotificationWithString:(NSString *)notif //post notification method and logic
{
    NSString *notificationName = @"ESNotification";
    NSString *key = @"OrientationStringValue";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:notif forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

@end
