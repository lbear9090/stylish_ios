//
//  ESCache.h


#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ESCache : NSObject
/**
 *  shared cache category hastag.
 */
@property (strong, nonatomic) NSString *strBags;
@property (strong, nonatomic) NSString *strAccessories;
@property (strong, nonatomic) NSString *strBlazer;
@property (strong, nonatomic) NSString *strJacket;
@property (strong, nonatomic) NSString *strSkirt;
@property (strong, nonatomic) NSString *strPants;
@property (strong, nonatomic) NSString *strShirt;
@property (strong, nonatomic) NSString *strShoes;
@property (strong, nonatomic) NSString *strDress;
@property (strong, nonatomic) NSString *strSuit;
@property (strong, nonatomic) NSMutableArray *arrayFilterInfo;
/*------------------------------*/

/**
 *  shared cache StyleMan.
 */

@property (strong, nonatomic) NSMutableArray *mStyleInfoArray;
@property (strong, nonatomic) NSMutableArray *mStyleDetailInfoArray;
@property (strong, nonatomic) NSMutableArray *mSelectedStyleDetailInfoArray;

@property (strong, nonatomic) NSString       *selectedStyleName;
@property  NSInteger      styleSelectedTag;


/*------------------------------*/
/**
 *  shared MyStyleButton or not ChoosePhotoButton , TakePhotoButton Tag.
 */
@property (strong , nonatomic) NSString *selectedBtnTag;

/*------------------------------*/

/**
 *  shared Recent, Trending, Featured .
 */
@property (strong , nonatomic) NSString *selectedTap;
/**
 *  shared For Inspiration, For Sale, For Hire Tap .
 */
@property (strong , nonatomic) NSString *selectedSaleTypeTap;
/*------------------------------*/
/**
*  selected user gender, user name and logined user name.
*/
@property (strong, nonatomic) NSString *selectedUserGender;
@property (strong, nonatomic) NSString *selectedUserId;
@property (strong, nonatomic) NSString *loginedUserId;
@property (strong, nonatomic) NSString *selectedUserStyleTagName;
@property (strong, nonatomic) NSArray *selectedUserStyleTagNames;

/*------------------------------*/
/**
 *  photo editor photoEditedDoneTag, photoEditedTag .
 */
@property (strong, nonatomic) NSString *photoEditedDoneTag;
@property (strong, nonatomic) NSString *photoEditedTag;
/*------------------------------*/
/**
 * selected original image from photo gallery .
 */
@property (strong, nonatomic) UIImage *selectedGalleryOriginalImage;
@property (strong, nonatomic) NSString *selectedGalleryImageStringTag;
/*------------------------------*/
@property (strong, nonatomic) NSMutableArray<PFObject *> *tempObjects;
@property (strong, nonatomic) NSMutableArray<PFObject *> *saleTypeObjects;
@property (strong, nonatomic) NSMutableArray<PFObject *> *followedUserPostObjects;
@property (strong, nonatomic) NSMutableArray<PFObject *> *likedUserPostObjects;
/**
 * selected edited with drawing image from photo gallery and current user of comment, hashtag.
 */
@property (strong, nonatomic) NSString *currentUserComment;
@property (strong, nonatomic) NSString *selectSaleHireType;
@property (strong, nonatomic) NSString *selectItemTitle;
@property (strong, nonatomic) UIImage  *postingPhotoImg;
/**
 * selected bezier path with drawing image .
 */

@property (strong, nonatomic) UIBezierPath *drawingInPath;
@property (strong, nonatomic) UIImage *selectedGalleryDrawingImage;
@property (assign) BOOL       selectedCropBtn;
/**
 * selected publish and tag with posting image .
 */
@property (strong, nonatomic) NSString *selectPublishAndTag;
@property (strong, nonatomic) UIImage *selectedBeforeEditOriginalImg;
/**
 * selected ration position variables.
 */
@property (nonatomic, assign) NSInteger notificationCount;
@property (strong, nonatomic) NSString *ratioXPosition;
@property (strong, nonatomic) NSString *ratioYPosition;
@property (strong, nonatomic) NSString *ratioRectHeight;
@property (strong, nonatomic) NSString *ratioRectWidth;
@property (strong, nonatomic) NSString *ratioItemViewXPosition;
@property (strong, nonatomic) NSString *ratioItemViewYPosition;
@property (strong, nonatomic) NSString *photoPostObjectId;
@property (strong, nonatomic) PFObject *photoPostObject;
@property (strong, nonatomic) NSMutableArray *selectedItemObjects;
@property (strong, nonatomic) NSMutableArray *arrOwnLabel;
@property (strong, nonatomic) PFUser   *selectedItemObjectUser;

/**
 * selected category , location name variables.
 */
@property (strong, nonatomic) NSString *selectedCategoryName;
@property (strong, nonatomic) NSString *selectedLocationInfoName;
@property (strong, nonatomic) NSString *deliveryShippingState;
@property (strong, nonatomic) NSString *deliveryMeetState;
@property (strong, nonatomic) NSString *conditionOption;
@property (strong, nonatomic) NSString *domesticCost;
@property (strong, nonatomic) NSString *internationalCost;

/**
 *  shared cache id
 */
+ (id _Nullable )sharedCache;
/**
 *  Clear the cache
 */
- (void)clear;
/**
 *  Setting attributes for a specific photo
 *
 *  @param photo              PFObject of the photo
 *  @param likers             array of likers
 *  @param commenters         array of commenters
 *  @param likedByCurrentUser is the photo liked by the current user?
 */
- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser;
/**
 *  Get the attributes for a specific photo.
 *
 *  @param photo PFObject of the photo
 *
 *  @return dictionary of the attributes
 */
- (NSDictionary *)attributesForPhoto:(PFObject *)photo;
/**
 *  Get the like count for a photo.
 *
 *  @param photo PFObject of the photo
 *
 *  @return number of likes
 */
- (NSNumber *)likeCountForPhoto:(PFObject *)photo;
/**
 *  Get the comment count for a photo.
 *
 *  @param photo PFObject of the photo
 *
 *  @return number of comments
 */
- (NSNumber *)commentCountForPhoto:(PFObject *)photo;
/**
 *  Get the users that have liked a photo
 *
 *  @param photo PFObject of the photo
 *
 *  @return array of users that liked the photo
 */
- (NSArray *)likersForPhoto:(PFObject *)photo;
/**
 *  Get the users that have commented on a photo
 *
 *  @param photo PFObject of the photo
 *
 *  @return array of users that commented on the photo
 */
- (NSArray *)commentersForPhoto:(PFObject *)photo;
/**
 *  Set the like state for a certain photo and the current user.
 *
 *  @param photo PFObject of the photo
 *  @param liked boolean of the like state
 */
- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked;
/**
 *  Decide if the photo is liked by the current user or not.
 *
 *  @param photo PFObject of the photo
 *
 *  @return boolean of the like state
 */
- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo;
/**
 *  Increment the like count for a photo.
 *
 *  @param photo PFObject of the photo
 */
- (void)incrementLikerCountForPhoto:(PFObject *)photo;
/**
 *  Decrement the like count for a photo.
 *
 *  @param photo PFObject of the photo
 */
- (void)decrementLikerCountForPhoto:(PFObject *)photo;
/**
 *  Increment the comment count for a photo.
 *
 *  @param photo PFObject of the photo
 */
- (void)incrementCommentCountForPhoto:(PFObject *)photo;
/**
 *  Decrement the comment count for a photo.
 *
 *  @param photo PFObject of the photo
 */
- (void)decrementCommentCountForPhoto:(PFObject *)photo;
/**
 *  Get the attributes for a certain user.
 *
 *  @param user PFUser of the user we want the attributes from
 *
 *  @return dictionary of the attributes
 */
- (NSDictionary *)attributesForUser:(PFUser *)user;
/**
 *  Count the number of photos a certain user has uploaded.
 *
 *  @param user PFUser of the respective user
 *
 *  @return number of uploaded photos
 */
- (NSNumber *)photoCountForUser:(PFUser *)user;
/**
 *  Check the followstatus for a certain user
 *
 *  @param user PFUser of the respective user
 *
 *  @return boolean of the follow status
 */
- (BOOL)followStatusForUser:(PFUser *)user;
/**
 *  Set the photo count for a user
 *
 *  @param count number of uploaded photos
 *  @param user  PFUser of the user
 */
- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
/**
 *  Set the follow status for a certain user
 *
 *  @param following boolean of the follow status we should set
 *  @param user      PFUser of the user
 */
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;
/**
 *  Set the Facebook friends for a user.
 *
 *  @param friends array of Facebook friends
 */
- (void)setFacebookFriends:(NSArray *)friends;
/**
 *  Get the Facebook friends.
 *
 *  @return array of Facebook friends
 */
- (NSArray *)facebookFriends;
- (void)setShowTags:(PFObject *)photo flag:(NSString *) flag;
@end
