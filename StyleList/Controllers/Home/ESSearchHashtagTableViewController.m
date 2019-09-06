//
//  ESSearchHashtagTableViewController.m

#import "ESHashtagTimelineViewController.h"
#import "ESSearchHashtagTableViewController.h"
#import <Parse/Parse.h>
#import "SCLAlertView.h"
#import "ESCache.h"
#import "ESConstants.h"


@interface ESSearchHashtagTableViewController()
{
    NSMutableArray *hashes;
    NSArray *titleAry;
    IBOutlet UILabel *lblCurrentTime;
    __weak IBOutlet UITextView *searchTxtView;
    __weak IBOutlet UILabel *resultLbl;
    __weak IBOutlet UIView *topView;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar1;
@property (strong, nonatomic) IBOutlet UIView *viewTop;
@property (strong, nonatomic) IBOutlet UIButton *btnCloseSearch;

@property (strong, nonatomic) IBOutlet UITextView *txtViewTagAll;
- (IBAction)btnCloseSearchClicked:(UIButton *)button;

@end

@implementation ESSearchHashtagTableViewController

@synthesize viewHeader, searchBar1, viewTop;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    titleAry = @[@"Bags", @"Accessories", @"Blazer", @"Jacket", @"Skirt", @"Pants", @"Shirt", @"Shoes", @"Dress", @"Suit", @"New with tags", @"New", @"Very good", @"Good", @"Satisfactory", @"Australia", @"New Zealand", @"UK", @"France", @"Spain", @"Germany", @"Italy", @"USA", @"Canada", @"Sale", @"Hire", @"Inspiration"];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{
                                                                                                 NSFontAttributeName: [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:20.0f],
                                                                                                 }];

    
    self.title = NSLocalizedString(@"Search hashtags", nil);
    UIImage *img = [[UIImage imageNamed:@"back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:img
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [searchBar1 setSearchFieldBackgroundImage:[UIImage imageNamed:@"bg_searchbar.png"] forState:UIControlStateNormal];
    [searchBar1.layer setCornerRadius:10.0f];
    searchBar1.clipsToBounds = YES;
    UITextField *textField = [searchBar1 valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
    self.navigationItem.titleView = topView;

    self.tableView.tableHeaderView = viewTop;
//    [self getCurrentTime]; //.//
    [self initCategoryBtnEdgeColor];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;

    hashes = [[NSMutableArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    ESCache *shared = [ESCache sharedCache];
    [shared.arrayFilterInfo removeAllObjects];
//    searchBar1.text = @" Searching All";
    resultLbl.text = @" Searching All";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self searchBarCancelled];
}

#pragma mark - get Current Time.not used
- (void)getCurrentTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm'"];
    lblCurrentTime.text= [dateFormatter stringFromDate:date];
}

#pragma mark - init category button category edge color
- (void)initCategoryBtnEdgeColor
{
    for (int i = 0; i < titleAry.count; i++) {
        UIButton *button = (UIButton *)[viewTop viewWithTag:i + 1];
        [self makeRoundButton:button];
    }
}

- (void)makeRoundButton:(UIButton *)button {
//    button.layer.borderColor = [[UIColor blackColor] CGColor];
//    button.layer.borderWidth = 2.0f;
    button.layer.cornerRadius = 3.0f;
    button.clipsToBounds = YES;
}

- (IBAction)btnTagsClicked:(UIButton *)button {
    if ([button.backgroundColor isEqual:COLOR_WHITE]) {
       [button setBackgroundColor:COLOR_GOLD];
        [self saveFilterOptionInformationsToArray:titleAry[button.tag - 1]];
    } else {
        [button setBackgroundColor:COLOR_WHITE];
        [self deleteFilterOptionInformationsFromArray:titleAry[button.tag - 1]];
    }
}

#pragma mark - save Filter Option Informations To Array
- (void)saveFilterOptionInformationsToArray:(NSString *)selectedFilterInfo{
    ESCache *shared = [ESCache sharedCache];
    [shared.arrayFilterInfo addObject:selectedFilterInfo];
    [self writeFilterInfoToSearchBar:shared.arrayFilterInfo];
}

#pragma mark - delete Filter Option Informations To Array
- (void)deleteFilterOptionInformationsFromArray:(NSString *)unSelectedFilterInfo{
    ESCache *shared = [ESCache sharedCache];
    for (int i = 0; i < shared.arrayFilterInfo.count; i++) {
        NSString *strTemp = [shared.arrayFilterInfo objectAtIndex:i];
        if ([strTemp isEqualToString:unSelectedFilterInfo]) {
            [shared.arrayFilterInfo removeObjectAtIndex:i];
        }
    }
    [self writeFilterInfoToSearchBar:shared.arrayFilterInfo];
}

#pragma mark - write Filter Option Informations To SearchBar Text
- (void)writeFilterInfoToSearchBar:(NSMutableArray *)inforArray{
    NSString *strTemp = @"";
    if (inforArray.count >0) {
        for (int i = 0; i < inforArray.count; i++) {
            NSString *str = [inforArray objectAtIndex:i];
            strTemp = [strTemp stringByAppendingString:[NSString stringWithFormat:@"%@,",str]];
        }
//        searchBar1.text = strTemp;
        resultLbl.text = strTemp;
    }else{
//        searchBar1.text = @" Searching All";
        resultLbl.text = @" Searching All";
    }
    
}

- (void)initBtnClearColor{
    for (int i = 0; i < titleAry.count; i++) {
        UIButton *button = (UIButton *)[viewTop viewWithTag:i + 1];
        button.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)btnCloseSearchClicked:(UIButton *)button
{
    [self initBtnClearColor];
    [self initCategoryHasTag];
}

#pragma mark - init category hastag
- (void)initCategoryHasTag
{
    ESCache *shared = [ESCache sharedCache];
    [shared.arrayFilterInfo removeAllObjects];
    searchBar1.text = @" Searching All";
}

#pragma mark - User actions

- (void)actionCleanup
{
    [hashes removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [hashes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    PFObject *hash = hashes[indexPath.row];
    NSString *hashtagString = [[NSString alloc]initWithFormat:@"#%@", [hash objectForKey:@"hashtag"]];
    cell.textLabel.text = hashtagString;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *_hashtag = hashes[indexPath.row];
    NSString *hashtag = [_hashtag objectForKey:@"hashtag"];
    
    ESHashtagTimelineViewController *hashtagSearch = [[ESHashtagTimelineViewController alloc] initWithStyle:UITableViewStyleGrouped andHashtag:hashtag];
    //hashtagSearch.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:hashtagSearch animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] >= 2)
    {
        NSString *search_lower = [[searchText lowercaseString] stringByReplacingOccurrencesOfString:@"#" withString:@""];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Hashtags"];
        [query whereKey:@"hashtag" containsString:search_lower];
        [query orderByAscending:@"updatedAt"];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 [hashes removeAllObjects];
                 [hashes addObjectsFromArray:objects];
                 [self.tableView reloadData];
             }
             else {
                 SCLAlertView *alert =[[SCLAlertView alloc]init];
                 [alert showError:self.parentViewController title:NSLocalizedString(@"Hold On...",nil) subTitle:NSLocalizedString(@"There seems to be a network error.", nil) closeButtonTitle:@"OK" duration:0.0f];
             }
         }];
    }
    else
    {
        [hashes removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
//    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self searchBarCancelled];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelled
{
    searchBar1.text = @"";
    [searchBar1 resignFirstResponder];
}
- (void)done:(id)sender {
    if ([resultLbl.text containsString:@"Sale"] || [resultLbl.text containsString:@"Hire"] || [resultLbl.text containsString:@"Inspiration"]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if([resultLbl.text isEqualToString:@" Searching All"]){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You havn't selected any 'Searching for' filters. Please select whether you're searching for 'Sale', 'Hire' or 'Inspiration' item." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
}

@end
