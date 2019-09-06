//
//  ESHireViewController.h
//  Style List
//
//  Created by 123 on 3/1/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "MPNumericTextField.h"

@interface ESHireViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton       *btnAddPhoto_1;
@property (weak, nonatomic) IBOutlet UIButton       *btnAddPhoto_2;
@property (weak, nonatomic) IBOutlet UIButton       *btnAddPhoto_3;
@property (weak, nonatomic) IBOutlet UIButton       *btnAddPhoto_4;
@property (weak, nonatomic) IBOutlet UIButton       *btnAddPhoto_5;
@property (weak, nonatomic) IBOutlet UIImageView    *imgAddPhoto_1;
@property (weak, nonatomic) IBOutlet UIImageView    *imgAddPhoto_2;
@property (weak, nonatomic) IBOutlet UIImageView    *imgAddPhoto_3;
@property (weak, nonatomic) IBOutlet UIImageView    *imgAddPhoto_4;
@property (weak, nonatomic) IBOutlet UIImageView    *imgAddPhoto_5;

@property (weak, nonatomic) IBOutlet UILabel        *lblHireConditionTitle;
@property (weak, nonatomic) IBOutlet UILabel        *lblCategoryName;
@property (weak, nonatomic) IBOutlet UILabel        *lblDelivery;
@property (weak, nonatomic) IBOutlet UILabel        *lblSaleType;
@property (weak, nonatomic) IBOutlet UILabel        *lblLocationCity;
@property (weak, nonatomic) IBOutlet UILabel        *lblDepositPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblCondition;

@property (weak, nonatomic) IBOutlet UITextField        *txtHashTagName;
@property (weak, nonatomic) IBOutlet MPNumericTextField *txtDepositPrice;
@property (weak, nonatomic) IBOutlet MPNumericTextField *txtItemPrice;

@property (weak, nonatomic) IBOutlet SZTextView         *txtViewDescription;

@property (weak, nonatomic) IBOutlet UIView         *viewLocation;
@property (weak, nonatomic) IBOutlet UIView         *viewDelivery;
@property (weak, nonatomic) IBOutlet UIView         *viewPrice;
@property (weak, nonatomic) IBOutlet UIView         *viewHireCondition;
@property (weak, nonatomic) IBOutlet UIView         *viewInfo;
@property (weak, nonatomic) IBOutlet UIView         *viewDescription;
@property (weak, nonatomic) IBOutlet UIView         *viewItemPrice;

@property (weak, nonatomic) IBOutlet UIButton       *btnCategoryName;
@property (weak, nonatomic) IBOutlet UIButton       *btnHelpPaidLink;





/**
 *  PFFile of the photo, will be uploaded to Parse.
 */
@property (nonatomic, strong) PFFile *photoNewPostFile;
/**
 *  PFFile of the photo thumbnail, will be uploaded to Parse.
 */
@property (nonatomic, strong) PFFile *thumbnailNewPostFile;
/**
 *  PFFile of the photo hashtagImage, will be uploaded to Parse.
 */
@property (nonatomic, strong) PFFile *hashTagImgOneFile;
@property (nonatomic, strong) PFFile *hashTagImgTwoFile;
@property (nonatomic, strong) PFFile *hashTagImgThreeFile;
@property (nonatomic, strong) PFFile *hashTagImgFourFile;
@property (nonatomic, strong) PFFile *hashTagImgFiveFile;
/**
 *  ID of the file upload backgroundtask.
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
/**
 *  ID of the post backgroundtask.
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;



@end
