//
//  ESImageView.h

/**
 *  Interface of the ESImageView
 */
@interface ESImageView : UIImageView
/**
 *  Placeholder image in case no image from Parse is available
 */
@property (nonatomic, strong) UIImage *placeholderImage;
/**
 *  Setting an image to the view
 *
 *  @param file This is the PFFile of the image
 */
- (void) setFile:(PFFile *)file;

@end
