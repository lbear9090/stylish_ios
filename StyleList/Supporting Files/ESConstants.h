//
//  ESConstants.h


typedef enum {
    ESHomeTabBarItemIndex = 0,
    ESAccountTabBarItemIndex,
    ESEmptyTabBarItemIndex,
    ESChatTabBarItemIndex,
    ESActivityTabBarItemIndex,
} ESTabBarControllerViewControllerIndex;

#define kESNetzwierkEmployeeAccounts [NSArray arrayWithObjects:@"825596744144470", nil]

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

#define IS_IPHONE6 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define		MESSAGE_OUT_COLOUR						HEXCOLOR(0x007AFFFF)
#define		MESSAGE_OUT_COLOUR						[UIColor blackColor]
#define     MESSAGE_IN_COLOUR                        HEXCOLOR(0xE6E5EAFF)

#define		VIDEO_LENGTH                                5
#define     POPULARITY_POINTS_MIN                       30

//#define     COLOR_THEME                             [UIColor colorWithHue:204.0f/360.0f saturation:76.0f/100.0f brightness:86.0f/100.0f alpha:1]
#define     COLOR_THEME                             [UIColor blackColor]
//#define     COLOR_THEME_LOGIN                       [UIColor colorWithRed:0.3412 green:0.6902 blue:0.9294 alpha:1];
#define     COLOR_THEME_LOGIN                       [UIColor blackColor]
#define     COLOR_GOLD                              HEXCOLOR(0xD2A784FF)
#define     COLOR_WHITE                           [UIColor whiteColor]

#define     COLOR_NAVBACK                           [UIColor whiteColor]
#define     COLOR_NAVTITLE                          [UIColor blackColor]
//HEXCOLOR(0xEAB706FF)

//===========  Rest API Url for paypal marketplace =========//
#define     PAYPAL_LOGIN_URL                               @"https://api.sandbox.paypal.com/v1/oauth2/token"
#define     PAYPAL_PAYMENT_URL                             @""
#define     PAYPAL_TOKEN                                   @"token"
//==========================================================//
#define     PAYPAL_CLIENT_ID @"AXl9471gHK4jap0ey4Qd99b0w90vKU9MTCYGpyhOQGrmf0BlqrzZoyTytmbNT8pZ9rcGGDoSGlZ7VtYK"
#define     PAYPAL_SECRET @"EMs6Xf4n-jFSokxtbaTDhvwqf5EEs8LrjLUK5W496qFBpLOgpWhUoWj2wg6heaRSZeNZ2b_rnpQqP5ja"
#define     COLOR_GREY                              HEXCOLOR(0xEAEAEAFF)

#define     TERMS_URL                               @"http://yourdomain.com/terms"
#define     WEBSITE_URL                             @"https://www.google.com"
#define     APP_URL                                 @"http://app_url"
#define     MALE                                    @"male"
#define     FEMALE                                  @"female"

#define     CSV                                     @"csv"
#define     MAN_NAME_CSV_FILE                       @"man_name"
#define     WOMEN_NAME_CSV_FILE                     @"women_name"
#define     MAN_DETAIL_NAME_CSV_FILE                @"man_detail_name"
#define     WOMEN_DETAIL_NAME_CSV_FILE              @"women_detail_name"

#define     STRINGS                                 @"strings"
#define     WOMEN_CATEGORY_HELP                     @"WCategoryHelp"
#define     MAN_CATEGORY_HELP                       @"CategoryHelp"

#pragma mark - For Sale,For Hire,For Inspiration Tag Value
#define     FORINSPIRATION                          @"For Inspiration"
#define     FORHIRE                                 @"For Hire"
#define     FORSALE                                 @"For Sale"
#define     FORINSPIRATION_TAG                      60
#define     FORHIRE_TAG                             70
#define     FORSALE_TAG                             80

#pragma mark - Recent, Trending, Featured Tag Value
#define        RECENT_TAG                           10
#define        TRENDING_TAG                         20
#define        FEATURED_TAG                         30
#define        LIST_TAG                             40
#define        FILTER_TAG                           50
#define        RECENT                               @"Recent"
#define        TRENDING                             @"Trending"
#define        FEATURED                             @"Featured"

#pragma mark - Filter Information Tag Value
#define       BAGS_TAG                              @"bags"
#define       ACCESSORIES_TAG                       @"accessories"
#define       BLAZER_TAG                            @"blazer"
#define       JACKET_TAG                            @"jacket"
#define       SKIRT_TAG                             @"skirt"
#define       PANTS_TAG                             @"pants"
#define       SHIRT_TAG                             @"shirt"
#define       SHOES_TAG                             @"shoes"
#define       DRESS_TAG                             @"dress"
#define       SUIT_TAG                              @"suit"
#define       NEWWITHTAGS_TAG                       @"New with tags"
#define       NEW_TAG                               @"New"
#define       VERYGOOD_TAG                          @"Very good"
#define       GOOD_TAG                              @"Good"
#define       SATISFACTORY_TAG                      @"Satisfactory"
#define       AUSTRALIA_TAG                         @"Australia"
#define       NEWZEALAND_TAG                        @"New Zealand"
#define       UK_TAG                                @"UK"
#define       FRANCE_TAG                            @"France"
#define       SPAIN_TAG                             @"Spain"
#define       GERMANY_TAG                           @"Germany"
#define       ITALY_TAG                             @"Italy"
#define       USA_TAG                               @"USA"
#define       CANADA_TAG                            @"Canada"


#pragma mark - GTWalsheimBold Font Name.
#define        GTWALSHEIM_REGULAR_FONT              @"GT Walsheim"
#define        GTWALSHEIM_BOLD_FONT                 @"GTWalsheimBold"
//@"itms-apps://itunes.apple.com/app/id887017458"
#pragma mark - Global settings

extern bool kESAdmobEnabled;

#pragma mark - NSUserDefaults
extern NSString *const kESUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kESUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kESLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const ESAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const ESUtilityUserFollowingChangedNotification;
extern NSString *const ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const ESUtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const ESTabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const ESTabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const ESPhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const ESPhotoDetailsViewControllerUserCommentedOnPhotoNotification;
extern NSString *const ESPhotoDetailsViewControllerUserReportedPhotoNotification;
extern NSString *const ESOpenChatWithUserNotification;


#pragma mark - User Info Keys
extern NSString *const ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kESEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kESInstallationUserKey;


#pragma mark - PFObject Activity to Notification Class
// Class key
extern NSString *const kESActivityClassKey;

// Field keys
extern NSString *const kESActivityTypeKey;
extern NSString *const kESActivityFromUserKey;
extern NSString *const kESActivityToUserKey;
extern NSString *const kESActivityContentKey;
extern NSString *const kESActivityPhotoKey;
extern NSString *const kESActivityPhotoObjectIdKey;
extern NSString *const kESActivityItemObjectIdKey;

// Type values
extern NSString *const kESActivityTypeLikePhoto;
extern NSString *const kESActivityTypeLikeVideo;
extern NSString *const kESActivityTypeLikePost;
extern NSString *const kESActivityTypeFollow;
extern NSString *const kESActivityTypeCommentPhoto;
extern NSString *const kESActivityTypeCommentVideo;
extern NSString *const kESActivityTypeCommentPost;
extern NSString *const kESActivityTypeMention;
extern NSString *const kESActivityTypeMentionPost;
extern NSString *const kESActivityTypeJoined;
extern NSString *const kESActivityTypeItemBookmark;
extern NSString *const kESActivityTypeItemOwned;

extern NSString *const kESOwnedLabelTag;
extern NSString *const kESOwnedCount;
extern NSString *const kESBookmarkState;
extern NSString *const kESOwnState;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kESUserDisplayNameKey;
extern NSString *const kESUserClassNameKey;
extern NSString *const kESUserObjectIdKey;
extern NSString *const kESUserDisplayNameKey;
extern NSString *const kESUserDisplayNameLowerKey;
extern NSString *const kESUserFacebookIDKey;
extern NSString *const kESUserMentionNameKey;
extern NSString *const kESUserInfoKey;
extern NSString *const kESUserLocationKey;
extern NSString *const kESUserWebsiteKey;
extern NSString *const kESUserGenderKey;
extern NSString *const kESUserBirthdayKey;
extern NSString *const kESUserPhotoIDKey;
extern NSString *const kESUserEmailKey;
extern NSString *const kESUserCountryKey;
extern NSString *const kESUserPaypalKey;
extern NSString *const kESUserProfilePicSmallKey;
extern NSString *const kESUserProfilePicMediumKey;
extern NSString *const kESUserHeaderPicSmallKey;
extern NSString *const kESUserHeaderPicMediumKey;
extern NSString *const kESUserFacebookFriendsKey;
extern NSString *const kESUserAlreadyAutoFollowedFacebookFriendsKey;
extern NSString *const kESUserWantsPrivateAccountKey;
extern NSString *const kESUserStyleKey;
extern NSString *const kESUserStyleGenderKey;


#pragma mark - Style class
extern NSString *const kESStyleClassName;
extern NSString *const kESStyleName;
extern NSString *const kESStyleImage;
extern NSString *const kESStyleDescription;

#pragma mark - StyleManDeatil class
extern NSString *const kESStyleManDetailClassName;
extern NSString *const kESStyleNameDetail;

#pragma mark - Style Woman class
extern NSString *const kESStyleWomanClassName;
extern NSString *const kESStyleWomanName;
extern NSString *const kESStyleWomanImage;
extern NSString *const kESStyleWomanDescription;

#pragma mark - StyleWomanDeatil class
extern NSString *const kESStyleWomanDetailClassName;

#pragma mark - Blocked user Class

extern NSString *const kESBlockedClassName;
extern NSString *const kESBlockedUser;
extern NSString *const kESBlockedUser1;
extern NSString *const kESBlockedUser2;
extern NSString *const kESBlockedUserID2;

#pragma mark - PFObject Chat Class
// Field keys
extern NSString *const kESChatClassNameKey; 
extern NSString *const kESChatUserKey;
extern NSString *const kESChatLastUserKey;
extern NSString *const kESChatLastMessageKey;
extern NSString *const kESChatUpdateRoomKey;
extern NSString *const kESChatBlockedUserKey;
extern NSString *const kESChatDescriptionKey;
extern NSString *const kESChatRoomIdKey;
extern NSString *const kESChatMessageReadKey;
extern NSString *const kESChatUnseenMessagesKey;
extern NSString *const kESChatFirebaseCredentialKey;
extern NSString *const kESChatInviteUserMessage;

#pragma mark - PFObject Photo to Post Class
// Class key
extern NSString *const kESPhotoClassKey;
extern NSString *const kESPhotoShowTags;

// Field keys
extern NSString *const kESPhotoPictureKey;
extern NSString *const kESPhotoIsSponsored;
extern NSString *const kESVideoOrPhotoTypeKey;
extern NSString *const kESVideoTypeKey;
extern NSString *const kESVideoFileKey;
extern NSString *const kESVideoFileThumbnailKey;
extern NSString *const kESVideoFileThumbnailRoundedKey;
extern NSString *const kESPhotoThumbnailKey;
extern NSString *const kESPhotoUserKey;
extern NSString *const kESPostTextTypeKey;
extern NSString *const kESPostRetweetTypeKey;
extern NSString *const kESPostTextKey;
extern NSString *const kESPhotoLocationKey;
extern NSString *const kESPhotoOpenGraphIDKey;
extern NSString *const kESPhotoPopularPointsKey;
extern NSString *const kESPostRetweetedUserKey;

extern NSString *const kESPhotoStyleTags;
extern NSString *const kESPhotoHashTag;
extern NSString *const kESPhotoHashTags;
extern NSString *const kESPhotoHashTagName;
extern NSString *const kESPhotoHashTagDescription;
extern NSString *const kESCondition;
extern NSString *const kESConditionDetail;
extern NSString *const kESLocationCountryInfo;
extern NSString *const kESLocationCityInfo;
extern NSString *const kESPhotoItemPrice;
extern NSString *const kESPhotoHashTagImgOne;
extern NSString *const kESPhotoHashTagImgTwo;
extern NSString *const kESPhotoHashTagImgThree;
extern NSString *const kESPhotoHashTagImgFour;
extern NSString *const kESPhotoHashTagImgFive;
extern NSString *const kESPhotoSaleType;

#pragma mark - PFObject PostItem Class
// Class key
extern NSString *const kESPostItemClassKey;
// Field keys
extern NSString *const kESPostPhotoObjectId;
extern NSString *const kESPostItemStyleTags;
extern NSString *const kESPostItemHashTags;
extern NSString *const kESPostItemHashTagName;
extern NSString *const kESPostItemHashTagDescription;
extern NSString *const kESPostItemConditionDetail;
extern NSString *const kESPostItemLocationCountryInfo;
extern NSString *const kESPostItemLocationCityInfo;
extern NSString *const kESPostItemDeliveryShipping;
extern NSString *const kESPostItemDeliveryMeet;
extern NSString *const kESPostItemDepositPrice;
extern NSString *const kESPostItemPrice;
extern NSString *const kESPostItemDomesticCost;
extern NSString *const kESPostItemInternationalCost;
extern NSString *const kESPostItemHashTagImgOne;
extern NSString *const kESPostItemHashTagImgTwo;
extern NSString *const kESPostItemHashTagImgThree;
extern NSString *const kESPostItemHashTagImgFour;
extern NSString *const kESPostItemHashTagImgFive;
extern NSString *const kESPostItemSaleType;
extern NSString *const kESPostItemFilteredImage;
extern NSString *const kESPostItemXPosition;
extern NSString *const kESPostItemYPosition;
extern NSString *const kESPostItemRatioWidth;
extern NSString *const kESPostItemRatioHeight;
extern NSString *const kESPostItemEdgeRatioXPosition;
extern NSString *const kESPostItemEdgeRatioYPosition;
extern NSString *const kESPostItemCenterXPosition;
extern NSString *const kESPostItemCenterYPosition;



#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kESPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kESPhotoAttributesLikeCountKey;
extern NSString *const kESPhotoAttributesRetweetCountKey;
extern NSString *const kESPhotoAttributesLikersKey;
extern NSString *const kESPhotoAttributesCommentCountKey;
extern NSString *const kESPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kESUserAttributesPhotoCountKey;
extern NSString *const kESUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kESPushPayloadPayloadTypeKey;
extern NSString *const kESPushPayloadPayloadTypeActivityKey;

extern NSString *const kESPushPayloadActivityTypeKey;
extern NSString *const kESPushPayloadActivityLikeKey;
extern NSString *const kESPushPayloadActivityCommentKey;
extern NSString *const kESPushPayloadActivityFollowKey;

extern NSString *const kESPushPayloadFromUserObjectIdKey;
extern NSString *const kESPushPayloadToUserObjectIdKey;
extern NSString *const kESPushPayloadPhotoObjectIdKey;
