//
//  ESSettingsViewController.h


#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>


@interface ESSettingsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, MFMailComposeViewControllerDelegate>
/**
 *  Actual tableview that is displayed in the viewcontroller.
 */
@property (nonatomic, strong) UITableView *_tableView;
/**
 *  UISwitch indicating wether a user wants to have his photos geolocated or not.
 */
@property (nonatomic, retain) UISwitch *switchview;
/**
 *  UISwitch indicating wether a user wants to get push notifications or not.
 */
@property (nonatomic, retain) UISwitch *switchviewPush;
/**
 *  UISwitch indicating wether a user wants to send read notifications or not.
 */
@property (nonatomic, retain) UISwitch *switchviewRead;
/**
 *  UISwitch indicating wether a user wants to have a private account or not.
 */
@property (nonatomic, retain) UISwitch *switchviewPrivate;
/**
 *  Dismissing the viewcontroller.
 */
- (void)done:(id)sender;
/**
 *  Geolocation switch has been toggled, disable or enable geolocation depending on the status of the switch.
 */
- (void) switchToggled;
/**
 *  The spaceinvader has been tapped.
 */
- (void)spaceInvaderTap;
@end
