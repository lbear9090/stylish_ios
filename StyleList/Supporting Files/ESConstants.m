//
//  ESConstants.m


#import "ESConstants.h"

NSString *const kESUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Netzwierk.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kESUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Netzwierk.userDefaults.cache.facebookFriends";

#pragma mark - Global settings

bool kESAdmobEnabled = NO;

#pragma mark - Launch URLs

NSString *const kESLaunchURLHostTakePicture = @"camera";


#pragma mark - NSNotification

NSString *const ESAppDelegateApplicationDidReceiveRemoteNotification           = @"com.parse.Netzwierk.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const ESUtilityUserFollowingChangedNotification                      = @"com.parse.Netzwierk.utility.userFollowingChanged";
NSString *const ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification     = @"com.parse.Netzwierk.utility.userLikedUnlikedPhotoCallbackFinished";
NSString *const ESUtilityDidFinishProcessingProfilePictureNotification         = @"com.parse.Netzwierk.utility.didFinishProcessingProfilePictureNotification";
NSString *const ESTabBarControllerDidFinishEditingPhotoNotification            = @"com.parse.Netzwierk.tabBarController.didFinishEditingPhoto";
NSString *const ESTabBarControllerDidFinishImageFileUploadNotification         = @"com.parse.Netzwierk.tabBarController.didFinishImageFileUploadNotification";
NSString *const ESPhotoDetailsViewControllerUserDeletedPhotoNotification       = @"com.parse.Netzwierk.photoDetailsViewController.userDeletedPhoto";
NSString *const ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification  = @"com.parse.Netzwierk.photoDetailsViewController.userLikedUnlikedPhotoInDetailsViewNotification";
NSString *const ESPhotoDetailsViewControllerUserCommentedOnPhotoNotification   = @"com.parse.Netzwierk.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification";
NSString *const ESPhotoDetailsViewControllerUserReportedPhotoNotification   = @"com.parse.Netzwierk.photoDetailsViewController.userReportedPhotoInDetailsViewNotification";
NSString *const ESOpenChatWithUserNotification   = @"com.parse.Netzwierk.ChatViewController.openChatWithUser";


#pragma mark - User Info Keys
NSString *const ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kESEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kESInstallationUserKey = @"user";
NSString *const kESChatFirebaseCredentialKey  =  @"https://stylelist-ca2c5.firebaseio.com";

#pragma mark - Activity Class to Notification Class
// Class key
NSString *const kESActivityClassKey = @"Notification";

// Field keys
NSString *const kESActivityTypeKey              = @"type";
NSString *const kESActivityFromUserKey          = @"fromUser";
NSString *const kESActivityToUserKey            = @"toUser";
NSString *const kESActivityContentKey           = @"content";
NSString *const kESActivityPhotoKey             = @"post";
NSString *const kESActivityPhotoObjectIdKey     = @"postId";
NSString *const kESActivityItemObjectIdKey      = @"itemObjectId";

// Type values
NSString *const kESActivityTypeLikePhoto       = @"like";
NSString *const kESActivityTypeLikeVideo       = @"like-video";
NSString *const kESActivityTypeLikePost        = @"like-post";
NSString *const kESActivityTypeFollow          = @"follow";
NSString *const kESActivityTypeCommentPhoto    = @"comment";
NSString *const kESActivityTypeCommentVideo    = @"comment-video";
NSString *const kESActivityTypeCommentPost     = @"comment-post";
NSString *const kESActivityTypeMention         = @"mention";
NSString *const kESActivityTypeMentionPost     = @"mention-post";
NSString *const kESActivityTypeJoined          = @"joined";
NSString *const kESActivityTypeItemBookmark    = @"bookmarked";
NSString *const kESActivityTypeItemOwned       = @"owned";

NSString *const kESOwnedLabelTag               = @"OwnedLabelTag";
NSString *const kESOwnedCount                  = @"OwnedCount";
NSString *const kESBookmarkState               = @"BookmakrState";
NSString *const kESOwnState                    = @"OwnState";



#pragma mark - User Class
// Field keys
NSString *const kESUserDisplayNameKey                          = @"displayName";
NSString *const kESUserDisplayNameLowerKey                     = @"displayName_lower";
NSString *const kESUserClassNameKey                            = @"_User";
NSString *const kESUserMentionNameKey                          = @"usernameFix";
NSString *const kESUserInfoKey                                 = @"UserInfo";
NSString *const kESUserLocationKey                             = @"Location";
NSString *const kESUserWebsiteKey                              = @"Website";
NSString *const kESUserObjectIdKey                             = @"objectId";
NSString *const kESUserFacebookIDKey                           = @"facebookId";
NSString *const kESUserPhotoIDKey                              = @"photoId";
NSString *const kESUserProfilePicSmallKey                      = @"profilePictureSmall";
NSString *const kESUserProfilePicMediumKey                     = @"profilePictureMedium";
NSString *const kESUserEmailKey                                = @"email";
NSString *const kESUserGenderKey                               = @"Gender";
NSString *const kESUserBirthdayKey                             = @"Birthday";
NSString *const kESUserCountryKey                              = @"Country";
NSString *const kESUserPaypalKey                               = @"PaypalAddress";   
NSString *const kESUserHeaderPicSmallKey                       = @"headerPictureSmall";
NSString *const kESUserHeaderPicMediumKey                      = @"headerPictureMedium";
NSString *const kESUserFacebookFriendsKey                      = @"facebookFriends";
NSString *const kESUserAlreadyAutoFollowedFacebookFriendsKey   = @"userAlreadyAutoFollowedFacebookFriends";
NSString *const kESUserWantsPrivateAccountKey                  = @"privateAccount";
NSString *const kESUserStyleKey                                = @"Style";
NSString *const kESUserStyleGenderKey                          = @"StyleGender";

#pragma mark - Chat Class

NSString *const kESChatClassNameKey                            = @"Messenger";
NSString *const kESChatUserKey                                 = @"user";
NSString *const kESChatRoomIdKey                               = @"roomId";
NSString *const kESChatDescriptionKey                          = @"description";
NSString *const kESChatLastUserKey                             = @"lastUser";
NSString *const kESChatLastMessageKey                          = @"lastMessage";
NSString *const kESChatUnseenMessagesKey                       = @"unseenCounter";
NSString *const kESChatUpdateRoomKey                           = @"updateRoom";
NSString *const kESChatBlockedUserKey                          = @"blockedUser";
NSString *const kESChatMessageReadKey                          = @"messageRead";
NSString *const kESChatInviteUserMessage                       = @"Check out :)";


#pragma mark - Style class

NSString *const kESStyleClassName                          = @"StyleMan";

NSString *const kESStyleName                               = @"StyleName";
NSString *const kESStyleImage                              = @"StyleImage";
NSString *const kESStyleDescription                        = @"StyleDescription";

#pragma mark - StyleManDeatil class
NSString *const kESStyleManDetailClassName                 = @"StyleManDetail";
NSString *const kESStyleNameDetail;

#pragma mark - Style Woman class
NSString *const kESStyleWomanClassName                     = @"StyleWoman";
NSString *const kESStyleWomanName                          = @"StyleName";
NSString *const kESStyleWomanImage                         = @"StyleImage";
NSString *const kESStyleWomanDescription                   = @"StyleDescription";

#pragma mark - StyleWomanDeatil class
NSString *const kESStyleWomanDetailClassName               = @"StyleWomanDetail";

#pragma mark - Blocked class

NSString *const kESBlockedClassName                           = @"Blocked";
NSString *const kESBlockedUser                                = @"user";
NSString *const kESBlockedUser1                               = @"user1";
NSString *const kESBlockedUser2                               = @"user2";
NSString *const kESBlockedUserID2                             = @"userId2";


//#pragma mark - Photo Class
#pragma mark - Post Class
// Class key
NSString *const kESPhotoClassKey = @"Post";

// Field keys
NSString *const kESPhotoPictureKey         = @"image";
NSString *const kESPhotoThumbnailKey       = @"thumbnail";
NSString *const kESPhotoUserKey            = @"user";
NSString *const kESPhotoLocationKey        = @"location";
NSString *const kESPhotoOpenGraphIDKey     = @"fbOpenGraphID";
NSString *const kESPhotoPopularPointsKey   = @"popularPoints";
NSString *const kESPhotoIsSponsored        = @"isSponsored";
NSString *const kESPhotoShowTags           = @"showTags";
NSString *const kESPhotoStyleTags          = @"Styles"; // StyleTag
NSString *const kESPhotoHashTags           = @"HashTag";
NSString *const kESPhotoHashTag            = @"HashTags";

NSString *const kESPhotoHashTagName        = @"HashTagName";
NSString *const kESPhotoHashTagDescription = @"HashTagDescription";
NSString *const kESCondition               = @"Condition";
NSString *const kESConditionDetail         = @"ConditionDetail";
NSString *const kESLocationCountryInfo        = @"LocationCountryInfo";
NSString *const kESLocationCityInfo        = @"LocationCityInfo";
NSString *const kESPhotoItemPrice          = @"ItemPrice";
NSString *const kESPhotoHashTagImgOne      = @"HashTagImgOne";
NSString *const kESPhotoHashTagImgTwo      = @"HashTagImgTwo";
NSString *const kESPhotoHashTagImgThree    = @"HashTagImgThree";
NSString *const kESPhotoHashTagImgFour     = @"HashTagImgFour";
NSString *const kESPhotoHashTagImgFive     = @"HashTagImgFive";
NSString *const kESPhotoSaleType           = @"SaleType";

#pragma mark - PostItem Class
// Class key
NSString *const kESPostItemClassKey             = @"ItemPost";
// Field keys

NSString *const kESPostPhotoObjectId            = @"PostId";
NSString *const kESPostItemStyleTags            = @"StyleTag";
NSString *const kESPostItemHashTags             = @"HashTag";
NSString *const kESPostItemHashTagName          = @"HashTagName";
NSString *const kESPostItemHashTagDescription   = @"HashTagDescription";
NSString *const kESPostItemConditionDetail      = @"ConditionDetail";
NSString *const kESPostItemLocationCountryInfo     = @"LocationCountryInfo";
NSString *const kESPostItemLocationCityInfo     = @"LocationCityInfo";
NSString *const kESPostItemDeliveryShipping     = @"DeliveryShipping";
NSString *const kESPostItemDeliveryMeet         = @"DeliveryMeet";
NSString *const kESPostItemPrice                = @"ItemPrice";
NSString *const kESPostItemDomesticCost         = @"DomesticCost";
NSString *const kESPostItemInternationalCost    = @"InternationalCost";
NSString *const kESPostItemDepositPrice         = @"DepositPrice";
NSString *const kESPostItemHashTagImgOne        = @"HashTagImgOne";
NSString *const kESPostItemHashTagImgTwo        = @"HashTagImgTwo";
NSString *const kESPostItemHashTagImgThree      = @"HashTagImgThree";
NSString *const kESPostItemHashTagImgFour       = @"HashTagImgFour";
NSString *const kESPostItemHashTagImgFive       = @"HashTagImgFive";
NSString *const kESPostItemSaleType             = @"SaleType";
NSString *const kESPostItemFilteredImage        = @"FilteredImage";
NSString *const kESPostItemXPosition            = @"XPosition";
NSString *const kESPostItemYPosition            = @"YPosition";
NSString *const kESPostItemRatioWidth           = @"RectWidth";
NSString *const kESPostItemRatioHeight          = @"RectHeight";
NSString *const kESPostItemEdgeRatioXPosition   = @"ItemViewEdgeXPosition";
NSString *const kESPostItemEdgeRatioYPosition   = @"ItemViewEdgeYPosition";

NSString *const kESPostItemCenterXPosition      = @"CenterX";
NSString *const kESPostItemCenterYPosition      = @"CenterY";



#pragma mark - Cached Photo Attributes
// keys
NSString *const kESPhotoAttributesIsLikedByCurrentUserKey = @"isLikedByCurrentUser";
NSString *const kESPhotoAttributesLikeCountKey            = @"likeCount";
NSString *const kESPhotoAttributesRetweetCountKey         = @"retweetCount";
NSString *const kESPhotoAttributesLikersKey               = @"likers";
NSString *const kESPhotoAttributesCommentCountKey         = @"commentCount";
NSString *const kESPhotoAttributesCommentersKey           = @"commenters";
NSString *const kESVideoOrPhotoTypeKey                    = @"type";
NSString *const kESPostTextTypeKey                        = @"text";
NSString *const kESPostTextKey                            = @"text";
NSString *const kESPostRetweetTypeKey                     = @"retweet";
NSString *const kESVideoTypeKey                           = @"video";
NSString *const kESVideoFileKey                           = @"file";
NSString *const kESVideoFileThumbnailKey         = @"videoThumbnail";
NSString *const kESVideoFileThumbnailRoundedKey           = @"videoThumbnailRound";
NSString *const kESPostRetweetedUserKey           = @"retweetedUser";


#pragma mark - Cached User Attributes
// keys
NSString *const kESUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kESUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kESPushPayloadPayloadTypeKey          = @"p";
NSString *const kESPushPayloadPayloadTypeActivityKey  = @"a";

NSString *const kESPushPayloadActivityTypeKey     = @"t";
NSString *const kESPushPayloadActivityLikeKey     = @"l";
NSString *const kESPushPayloadActivityCommentKey  = @"c";
NSString *const kESPushPayloadActivityFollowKey   = @"f";

NSString *const kESPushPayloadFromUserObjectIdKey = @"fu";
NSString *const kESPushPayloadToUserObjectIdKey   = @"tu";
NSString *const kESPushPayloadPhotoObjectIdKey    = @"pid";
