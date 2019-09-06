//
//  ESBuyViewController.h
//  Style List
//
//  Created by 123 on 3/10/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESImageView.h"
#import "TTTTimeIntervalFormatter.h"
#import "PayPalMobile.h"
#define kPayPalEnvironment PayPalEnvironmentSandbox

@interface ESBuyViewController : UIViewController<PayPalPaymentDelegate, UIPopoverControllerDelegate>

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property(nonatomic, strong, readwrite) IBOutlet UIView     *successView;
@property(nonatomic, strong, readwrite) NSString            *environment;
@property(nonatomic, strong, readwrite) NSString            *resultText;

@property (nonatomic, strong) PFObject              *selectObject;
@property (nonatomic, strong) PFFile                *userProfileImageFile;
@property (nonatomic, strong) PFFile                *hashTagImageFileOne;
@property (nonatomic, strong) PFFile                *hashTagImageFileTwo;
@property (nonatomic, strong) PFFile                *hashTagImageFileThree;
@property (nonatomic, strong) PFFile                *hashTagImageFileFour;
@property (nonatomic, strong) PFFile                *hashTagImageFileFive;
/**
 *  Helping us to create the timeStampLabel
 */
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UILabel        *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel        *lblUserSmallName;
@property (weak, nonatomic) IBOutlet UILabel        *lblPostedTime;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UILabel        *lblHashTagName;
@property (weak, nonatomic) IBOutlet UILabel        *lblHashTag;
@property (weak, nonatomic) IBOutlet UILabel        *lblHashTagDescription;
@property (weak, nonatomic) IBOutlet UILabel        *lblHireCondition;
@property (weak, nonatomic) IBOutlet UILabel        *lblMeetInPerson;
@property (weak, nonatomic) IBOutlet UITextView     *txtLocationCityInfo;
@property (weak, nonatomic) IBOutlet UILabel        *lblItemPrice;
@property (strong, nonatomic)   NSString            *strItemPrice;
@property (weak, nonatomic) IBOutlet UILabel        *lblDepositPrice;
@property (weak, nonatomic) IBOutlet UILabel        *lblShippingPrice;
@property (weak, nonatomic) IBOutlet UILabel        *lblTotalPrice;
@property (weak, nonatomic) IBOutlet UILabel        *lblSaleType;

@property (weak, nonatomic) IBOutlet UIView         *viewDeposit;
@property (weak, nonatomic) IBOutlet UILabel        *lblDeposit;
@property (weak, nonatomic) IBOutlet UIView         *viewShipping;
@property (weak, nonatomic) IBOutlet UILabel        *lblShipping;
@property (weak, nonatomic) IBOutlet UIView         *viewTotal;
@property (weak, nonatomic) IBOutlet UILabel        *lblTotal;
@property (weak, nonatomic) IBOutlet UIView         *viewDeliveryOption;


@property (weak, nonatomic) IBOutlet ESImageView    *imgProfile;
@property (weak, nonatomic) IBOutlet UIImageView    *imgShippingCheck;
@property (weak, nonatomic) IBOutlet UIButton       *btnHand;
@property (weak, nonatomic) IBOutlet UIButton       *btnBookmark;
@property (weak, nonatomic) IBOutlet UIButton       *btnBuy;
@property (weak, nonatomic) IBOutlet UILabel        *lblDeliveryOption;


@property (strong, nonatomic) NSString              *strItemObjectId;
@property (strong, nonatomic) NSString              *strSelectPhotoPostId;
@property (strong, nonatomic) PFUser                *postingToUser;
@property (strong, nonatomic) PFUser                *postingFromUser;
@property (strong, nonatomic) NSMutableArray        *arrayOwnedItemObject;
@property (strong, nonatomic) NSMutableArray        *arrayBookmarkedItemObject;
            
@property (weak, nonatomic) IBOutlet UIView *viewTitleBar;
@property (weak, nonatomic) IBOutlet UILabel *lblTagName;
@property (weak, nonatomic) IBOutlet UILabel *lblCostTag;
@property (weak, nonatomic) IBOutlet UILabel *lblOwnTag;
@property (nonatomic, assign)  NSInteger     selectedItemTag;
@property (strong, nonatomic) UIImage        *postOriginalImage;




- (id)initWithPhoto:(PFObject*)object objectId:(NSString *)itemObjectId postPhotoId:(NSString *)selectPhotoPostId toUser:(PFUser *)selectedPostingUser regOwnedItemObject:(NSMutableArray *)regOwnedItemObjectArray regBookmarkedItemObject:(NSMutableArray *)regBookmarkedItemObjectArray  tag:(NSInteger)selectedItemObjectTag originImg:(UIImage *)postingOriginImage;

@end
