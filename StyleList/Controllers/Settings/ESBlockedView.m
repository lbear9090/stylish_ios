
#import "ESBlockedView.h"

@interface ESBlockedView()
{
    /**
     *  Mutable array containing the blocked users
     */
	NSMutableArray *blockeds;
    /**
     *  In case a blocked user is tap, we need to keep track of the selected index, so we save it in this variable
     */
	NSIndexPath *indexSelected;
}
@property (nonatomic, strong) UIView *blankTimelineView;

@end

@implementation ESBlockedView

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.navigationItem.title = @"Blocked users";
	blockeds = [[NSMutableArray alloc] init];
	[self loadBlockeds];
    
    self.blankTimelineView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake( [UIScreen mainScreen].bounds.size.width/2 -110, 60, 220.0f, 40.0f)];
    label.text = @"No blocked users";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:16];
    
    [self.blankTimelineView addSubview:label];

}

#pragma mark - Backend actions

- (void)loadBlockeds
{
	PFQuery *query = [PFQuery queryWithClassName:kESBlockedClassName];
	[query whereKey:kESBlockedUser equalTo:[PFUser currentUser]];
	[query whereKey:kESBlockedUser1 equalTo:[PFUser currentUser]];
	[query includeKey:kESBlockedUser2];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
            if ([objects count] == 0) {
                if (!self.blankTimelineView.superview) {
                    self.tableView.scrollEnabled = NO;
                    self.blankTimelineView.alpha = 0.0f;
                    self.tableView.tableHeaderView = self.blankTimelineView;
                    
                    [UIView animateWithDuration:0.200f animations:^{
                        self.blankTimelineView.alpha = 1.0f;
                    }];
                }
            } else {
                self.tableView.scrollEnabled = YES;
                [self.blankTimelineView removeFromSuperview];
                self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 0.1)];
            }
            
			[blockeds removeAllObjects];
			[blockeds addObjectsFromArray:objects];
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [blockeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	PFObject *blocked = blockeds[indexPath.row];
	PFUser *user = blocked[kESBlockedUser2];
	cell.textLabel.text = user[kESUserDisplayNameKey];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	indexSelected = indexPath;
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil otherButtonTitles:@"Unblock user", nil];
	[action showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		PFObject *blocked = blockeds[indexSelected.row];
		PFUser *user2 = blocked[kESBlockedUser2];
        [ESUtility unblockUser:user2];
		[blockeds removeObject:blocked];
		[self.tableView reloadData];
	}
}

@end
