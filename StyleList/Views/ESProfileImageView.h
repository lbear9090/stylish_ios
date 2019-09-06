//
//  ESProfileImageView.h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class PFImageView;
@interface ESProfileImageView : UIView
/**
 *  The button of the profile picture
 */
@property (nonatomic, strong) UIButton *profileButton;
/**
 *  View of the profile picture of the user
 */
@property (nonatomic, strong) PFImageView *profileImageView;

/**
 *  Setting a photo to the profile picture view
 *
 *  @param file PFFile of the profile picture photo
 */
- (void)setFile:(PFFile *)file;

@end
