//
//  ESPageViewController.h


#import <UIKit/UIKit.h>

@interface ESPageViewController : UIViewController
/**
 *  Index of the PageController.
 */
@property NSUInteger pageIndex;
/**
 *  Name of the image we display on the viewcontroller.
 */
@property NSString *imgFile;
/**
 *  The label we display above the image.
 */
@property (strong, nonatomic) IBOutlet UILabel *lblScreenLabel;
/**
 *  The text in the label above the image.
 */
@property NSString *txtTitle;
/**
 *  The image on the viewcontroller.
 */
@property (strong, nonatomic) IBOutlet UIImageView *ivScreenImage;
@end
