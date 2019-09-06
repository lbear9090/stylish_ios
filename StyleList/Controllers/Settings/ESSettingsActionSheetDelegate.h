//
//  ESSettingsActionSheetDelegate.h


#import <Foundation/Foundation.h>

@interface ESSettingsActionSheetDelegate : NSObject <UIActionSheetDelegate>

/// Navigation controller of calling view controller
@property (nonatomic, strong) UINavigationController *navController;

- (id)initWithNavigationController:(UINavigationController *)navigationController;

@end
