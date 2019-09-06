//
//  ESSettingsActionSheetDelegate.m


#import "ESSettingsActionSheetDelegate.h"
#import "ESFindFriendsViewController.h"
#import "ESAccountViewController.h"
#import "AppDelegate.h"

// ActionSheet button indexes
typedef enum {
	kESSettingsProfile = 0,
	kESSettingsFindFriends,
	kESSettingsLogout,
    kESSettingsNumberOfButtons
} kESSettingsActionSheetButtons;
 
@implementation ESSettingsActionSheetDelegate

@synthesize navController;

#pragma mark - Initialization

- (id)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        navController = navigationController;
    }
    return self;
}

- (id)init {
    return [self initWithNavigationController:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (!self.navController) {
        [NSException raise:NSInvalidArgumentException format:@"navController cannot be nil"];
        return;
    }
    
    switch ((kESSettingsActionSheetButtons)buttonIndex) {
        case kESSettingsProfile:
        {
            ESAccountViewController *accountViewController = [[ESAccountViewController alloc] initWithStyle:UITableViewStylePlain];
            [accountViewController setUser:[PFUser currentUser]];
            [navController pushViewController:accountViewController animated:YES];
            break;
        }
        case kESSettingsFindFriends:
        {
            ESFindFriendsViewController *findFriendsVC = [[ESFindFriendsViewController alloc] init];
            [navController pushViewController:findFriendsVC animated:YES];
            break;
        }
        case kESSettingsLogout:
            // Log out user and present the login view controller
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
            break;
        default:
            break;
    }
}

@end
