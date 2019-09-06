//
//  ESHireViewController.m
//  Style List
//
//  Created by 123 on 3/1/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESHireViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "PXAlertView.h"
#import "ESHelpPaidViewController.h"
#import "ESDeliveryViewController.h"
#import "MBProgressHUD.h"
#import "ESCategoryViewController.h"
#import "ESLocationViewController.h"
#import "ESConditionViewController.h"

@interface ESHireViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate>{
    NSString *localityString;
    NSInteger selectAddPhotoTag;
    NSArray *arrCategorySize;
    NSArray *arrCondition;
    NSArray *arrCategoryName;
    BOOL selectBtnCondition;
    BOOL selectBtnCategoryName;
    
    BOOL selectDeletePhoto1;
    BOOL selectDeletePhoto2;
    BOOL selectDeletePhoto3;
    BOOL selectDeletePhoto4;
    BOOL selectDeletePhoto5;
    
    NSString *saleType;
    NSString *strCountry;
    NSString *strCity;
}

@end

@implementation ESHireViewController

@synthesize scrollView;
@synthesize btnAddPhoto_1, btnAddPhoto_2, btnAddPhoto_3, btnAddPhoto_4, btnAddPhoto_5;
@synthesize imgAddPhoto_1, imgAddPhoto_2, imgAddPhoto_3, imgAddPhoto_4, imgAddPhoto_5;
@synthesize viewLocation, viewDelivery, viewPrice, viewHireCondition, viewInfo, viewDescription, viewItemPrice;
@synthesize lblCategoryName,lblHireConditionTitle,lblLocationCity,lblDelivery, lblSaleType, lblDepositPrice, lblCondition;
@synthesize txtHashTagName, txtDepositPrice, txtItemPrice;
@synthesize txtViewDescription;
@synthesize btnHelpPaidLink;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    ESCache *shared = [ESCache sharedCache];
    [self shouldUploadImage:shared.postingPhotoImg];
    self.navigationController.navigationBar.hidden = YES;
    
    [self initPlaceholderTextView];
    [self initCurrencyTextField];
    
    selectBtnCondition      = NO;
    selectBtnCategoryName   = NO;
    selectDeletePhoto1      = NO;
    selectDeletePhoto2      = NO;
    selectDeletePhoto3      = NO;
    selectDeletePhoto4      = NO;
    selectDeletePhoto5      = NO;
        
    saleType = shared.selectSaleHireType;
    
    txtHashTagName.text = shared.selectItemTitle;
    lblSaleType.text = saleType;
    if ([saleType isEqualToString:@"For Inspiration"]) {
        [self loadViewForInspiration];
    }else if ([saleType  isEqualToString:@"For Hire"]){
        [self loadviewForHire];
    }else if ([saleType isEqualToString:@"For Sale"]){
        [self loadViewForSale];
    }
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    
    ESCache *shared = [ESCache sharedCache];
    
    if ([shared.selectedCategoryName isEqualToString:@""] || shared.selectedCategoryName == nil) {
        lblCategoryName.text = @"Select";
    }else{
        lblCategoryName.text = shared.selectedCategoryName;
    }
//    if ([shared.selectedLocationInfoName isEqualToString:@""] || shared.selectedLocationInfoName == nil) {
//        lblLocationCity.text = @"Locaiton";
//    }else{
//        lblLocationCity.text = shared.selectedLocationInfoName;
//    }
    if ([shared.deliveryMeetState isEqualToString:@"Yes"]) {
        if([shared.deliveryMeetState isEqualToString:@"Yes"]){
            lblDelivery.text = @"Meet in person";
        }
        
        if([shared.deliveryShippingState isEqualToString:@"Yes"]){
            NSString *str = @"";
            if(![shared.domesticCost isEqualToString:@""]){
                str = [NSString stringWithFormat:@", DS $%@", shared.domesticCost];
            }
            if(![shared.internationalCost isEqualToString:@""]){
                str = [NSString stringWithFormat:@"%@, IS $%@",str, shared.internationalCost];
            }
            lblDelivery.text = [lblDelivery.text stringByAppendingString:str];
        }
    }else if ([shared.deliveryShippingState isEqualToString:@"Yes"]){
        NSString *str = @"";
        if(![shared.domesticCost isEqualToString:@""]){
            str = [NSString stringWithFormat:@"DS $%@", shared.domesticCost];
        }
        if(![shared.internationalCost isEqualToString:@""]){
            str = [NSString stringWithFormat:@"%@ IS $%@",str, shared.internationalCost];
        }
        lblDelivery.text = str;
        
    }/*else if ([shared.deliveryMeetState isEqualToString:@"Yes"]){
        lblDelivery.text = @"Meet in person";
        
    }*/else{
        lblDelivery.text = @"Select";
    }
    if ([shared.conditionOption isEqualToString:@""] || shared.conditionOption == nil) {
        lblCondition.text = @"Condition";
    }else{
        lblCondition.text = shared.conditionOption;
    }
    PFUser *user = [PFUser currentUser];
    strCountry = [user objectForKey:kESUserCountryKey];
    strCity = [user objectForKey:kESUserLocationKey];
    if ([strCity isEqualToString:@""] || strCity == nil) {
        lblLocationCity.text = @"Location";
    }else{
        //lblLocationCity.text = strCity;
        lblLocationCity.text = [NSString stringWithFormat:@"%@(%@)", strCity, strCountry];
    }
    
}

- (IBAction)btnCancelClicked:(id)sender {
    [self initPhotoEditedVariable];
    ESCache *shared = [ESCache sharedCache];
    shared.selectPublishAndTag  = @"";
    shared.selectSaleHireType   = @"";
    shared.conditionOption      = @"";
    shared.notificationCount    = 0;
    shared.domesticCost         = @"";
    shared.internationalCost    = @"";
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)initPhotoEditedVariable{
    ESCache *shared = [ESCache sharedCache];
    shared.photoEditedTag = @"";
    shared.selectedGalleryOriginalImage = nil;
}
#pragma Add category image from Gallery.

- (IBAction)btnAddPhotoFromGallery:(id)sender {
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
            
        case 21:
            selectAddPhotoTag = 21;
            if (selectDeletePhoto1 == NO) {
                [self initImagePickerFromGallery];
                selectDeletePhoto1 = YES;
            }else if (selectDeletePhoto1 == YES){
                imgAddPhoto_1.image = nil;
                [btnAddPhoto_1 setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
                selectDeletePhoto1 = NO;
            }
            break;
        case 22:
            selectAddPhotoTag = 22;
            if (selectDeletePhoto2 == NO) {
                [self initImagePickerFromGallery];
                selectDeletePhoto2 = YES;
            }else if (selectDeletePhoto2 == YES){
                imgAddPhoto_2.image = nil;
                [btnAddPhoto_2 setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
                selectDeletePhoto2 = NO;
            }
            break;
        case 23:
            selectAddPhotoTag = 23;
            if (selectDeletePhoto3 == NO) {
                [self initImagePickerFromGallery];
                selectDeletePhoto3 = YES;
            }else if (selectDeletePhoto3 == YES){
                imgAddPhoto_3.image = nil;
                [btnAddPhoto_3 setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
                selectDeletePhoto3 = NO;
            }
            break;
        case 24:
            selectAddPhotoTag = 24;
            if (selectDeletePhoto4 == NO) {
                [self initImagePickerFromGallery];
                selectDeletePhoto4 = YES;
            }else if (selectDeletePhoto4 == YES){
                imgAddPhoto_4.image = nil;
                [btnAddPhoto_4 setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
                selectDeletePhoto4 = NO;
            }
            break;
        case 25:
            selectAddPhotoTag = 25;
            if (selectDeletePhoto5 == NO) {
                [self initImagePickerFromGallery];
                selectDeletePhoto5 = YES;
            }else if (selectDeletePhoto5 == YES){
                imgAddPhoto_5.image = nil;
                [btnAddPhoto_5 setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
                selectDeletePhoto5 = NO;
            }
            break;
            
        default:
            break;
    }
}

#pragma UIImagePickerController Delegate Method.
- (void)initImagePickerFromGallery{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    switch (selectAddPhotoTag) {
        case 21:
            [imgAddPhoto_1.layer setCornerRadius:5.0f];
            imgAddPhoto_1.clipsToBounds = YES;
            [btnAddPhoto_1 setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
            imgAddPhoto_1.image = chosenImage;
            break;
        case 22:
            [imgAddPhoto_2.layer setCornerRadius:5.0f];
            imgAddPhoto_2.clipsToBounds = YES;
            [btnAddPhoto_2 setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
            imgAddPhoto_2.image = chosenImage;
            break;
        case 23:
            [imgAddPhoto_3.layer setCornerRadius:5.0f];
            imgAddPhoto_3.clipsToBounds = YES;
            [btnAddPhoto_3 setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
            imgAddPhoto_3.image = chosenImage;
            break;
        case 24:
            [imgAddPhoto_4.layer setCornerRadius:5.0f];
            imgAddPhoto_4.clipsToBounds = YES;
            [btnAddPhoto_4 setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
            imgAddPhoto_4.image = chosenImage;
            break;
        case 25:
            [imgAddPhoto_5.layer setCornerRadius:5.0f];
            imgAddPhoto_5.clipsToBounds = YES;
            [btnAddPhoto_5 setBackgroundImage:[UIImage imageNamed:@"btn_delete.png"] forState:UIControlStateNormal];
            imgAddPhoto_5.image = chosenImage;
            break;
            
        default:
            break;
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    switch (selectAddPhotoTag) {
        case 21:
            selectDeletePhoto1 = NO;
            break;
        case 22:
            selectDeletePhoto2 = NO;
            break;
        case 23:
            selectDeletePhoto3 = NO;
            break;
        case 24:
            selectDeletePhoto4 = NO;
            break;
        case 25:
            selectDeletePhoto5 = NO;
            break;
            
        default:
            break;
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - set Condition Option.

- (IBAction)btnConditionOptionClicked:(id)sender {
    ESConditionViewController *vc = [[ESConditionViewController alloc]initWithNibName:@"ESConditionViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navController animated:YES completion:nil];
    
}
#pragma set Category Name.
- (IBAction)btnCategoryNameClicked:(id)sender {
    ESCategoryViewController *vc = [[ESCategoryViewController alloc] initWithNibName:@"ESCategoryViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma set Delivery option.

- (IBAction)btnDeliveryClicked:(id)sender {
    ESDeliveryViewController *vc = [[ESDeliveryViewController alloc]initWithNibName:@"ESDeliveryViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:NO completion:nil];

}

#pragma set Location option.

- (IBAction)btnLocationCityClicked:(id)sender {
    /*ESLocationViewController *vc = [[ESLocationViewController alloc]initWithNibName:@"ESLocationViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:NO completion:nil];*/
}


#pragma go photo filter screen after upload photo , hashtag and styletag to server.
- (IBAction)btnPublishAndTag:(id)sender {
    ESCache *shared             = [ESCache sharedCache];
    shared.photoEditedTag       = @"";
    shared.selectPublishAndTag  = @"PublishAndTag";
    
    if (shared.notificationCount > 0) {
        [self uploadFilteredItemPhotoToServer:shared.photoPostObjectId];
    }else{
        [self uploadPhotoAndItemPhotoToServer];
    }
    
}

#pragma upload photo , hashtag and styletag to server.
- (IBAction)btnPublish:(id)sender {
    ESCache *shared = [ESCache sharedCache];

    if ([shared.selectPublishAndTag isEqualToString:@"PublishAndTag"]) {
        shared.selectPublishAndTag = @"PublishEnd";
        
        if ([shared.currentUserComment isEqualToString:@""] || shared.currentUserComment == nil) {
            shared.currentUserComment = @"";
            [self uploadFilteredItemPhotoToServer:shared.photoPostObjectId];
        }else{
            [self uploadPhotoPostOfNotificationInfoToSever:shared.photoPostObjectId photoObject:shared.photoPostObject];
        }
        
    }else{
        //================== create a photo object ===============//
        [self uploadPhotoAndItemPhotoToServer];
        //========================================================//
    }
    
}

#pragma upload photo and item photo all object to server.
- (void)uploadPhotoAndItemPhotoToServer{
    ESCache *shared = [ESCache sharedCache];
    PFObject *photo = [PFObject objectWithClassName:kESPhotoClassKey];
    
    NSString *strStyleTag           = shared.selectedUserStyleTagName;
    NSString *strHashTag            = lblCategoryName.text;
    NSString *strHashTagName        = txtHashTagName.text;
    NSString *strDelivery           = lblDelivery.text;
    NSString *strSaleType           = shared.selectSaleHireType;
    NSString *strDescription        = txtViewDescription.text;
    NSString *strHireCondition      = lblCondition.text;
    NSString *strLocationInfo       = lblLocationCity.text;

    NSString *strDepositPrice       = [NSString stringWithFormat:@"%@",txtDepositPrice.numericValue];
    NSString *strItemPrice          = [NSString stringWithFormat:@"%@",txtItemPrice.numericValue];
    BOOL isPostingPhotos            = NO;
   
    if ([saleType isEqualToString:@"For Inspiration"]){
        if ([strHashTagName isEqualToString:@""] ||strHashTagName == nil ||  [strHashTag isEqualToString:@""] || strHashTag == nil || [strHashTag isEqualToString:@"select"] || [strDescription isEqualToString:@""] || strDescription == nil ) {
            
            [self displayErrorMessage];
        }else{
            [photo setObject:[PFUser currentUser] forKey:kESPhotoUserKey];
            [photo setObject:shared.selectedUserStyleTagNames forKey:kESPhotoStyleTags];
            [photo setObject:strHashTag forKey:kESPhotoHashTags];
            
            if (![shared.selectPublishAndTag isEqualToString:@"PublishAndTag"] && ![shared.selectPublishAndTag isEqualToString:@"PublishEnd"]) {
                [photo addObject:strSaleType forKey:kESPhotoSaleType];
                [photo addObject:strHashTag forKey:kESPhotoHashTag];
                [photo addObject:strHireCondition forKey:kESCondition];
                //[photo addObject:strLocationInfo forKey:kESLocationCountryInfo];
                [photo addObject:strCountry forKey:kESLocationCountryInfo];
                [photo addObject:strCity forKey:kESLocationCityInfo];
            }
            
            isPostingPhotos = [self shouldUploadImage:shared.selectedBeforeEditOriginalImg];
            if (isPostingPhotos == YES) {
                [photo setObject:self.photoNewPostFile forKey:kESPhotoPictureKey];
            }
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSString *strPhotoPostId = [NSString stringWithFormat:@"%@", photo.objectId];
                    shared.photoPostObject = photo;
                    [self uploadPhotoPostOfNotificationInfoToSever:strPhotoPostId photoObject:photo];
                    
                }else{
                    [self dismissHireVC];
                }
            }];
        }
        
    }else if([saleType isEqualToString:@"For Sale"]){
        if ([strHashTagName isEqualToString:@""] ||strHashTagName == nil || [strHashTag isEqualToString:@""] || strHashTag == nil || [strHashTag isEqualToString:@"select"] || [strStyleTag isEqualToString:@""] || strStyleTag == nil ||  [strDelivery isEqualToString:@""] || strDelivery == nil || [strDelivery isEqualToString:@"select"] || [strHireCondition isEqualToString:@""] || [strHireCondition isEqualToString:@"Condition"] || strHireCondition == nil || [strDescription isEqualToString:@""] || strDescription == nil || [strLocationInfo isEqualToString:@""] || strLocationInfo == nil || [strLocationInfo isEqualToString:@"select"] || [strDelivery isEqualToString:@""] || strDelivery == nil || [strDelivery isEqualToString:@"select"] || [strDepositPrice isEqualToString:@""] || [strDepositPrice isEqualToString:@"(null)"] || strDepositPrice == nil) {
            
            [self displayErrorMessage];
        }else{
            
            [photo setObject:[PFUser currentUser] forKey:kESPhotoUserKey];
            [photo setObject:shared.selectedUserStyleTagNames forKey:kESPhotoStyleTags];
            [photo setObject:strHashTag forKey:kESPhotoHashTags];
            
            if (![shared.selectPublishAndTag isEqualToString:@"PublishAndTag"] && ![shared.selectPublishAndTag isEqualToString:@"PublishEnd"]) {
                [photo addObject:strSaleType forKey:kESPhotoSaleType];
                [photo addObject:strHashTag forKey:kESPhotoHashTag];
                [photo addObject:strHireCondition forKey:kESCondition];
                //[photo addObject:strLocationInfo forKey:kESLocationCountryInfo];
                [photo addObject:strCountry forKey:kESLocationCountryInfo];
                [photo addObject:strCity forKey:kESLocationCityInfo];
            }
            
            isPostingPhotos = [self shouldUploadImage:shared.selectedBeforeEditOriginalImg];
            if (isPostingPhotos == YES) {
                [photo setObject:self.photoNewPostFile forKey:kESPhotoPictureKey];
            }
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSString *strPhotoPostId = [NSString stringWithFormat:@"%@", photo.objectId];
                    /*if ([shared.currentUserComment isEqualToString:@""] || [shared.currentUserComment isEqualToString:@"(null)"]) {
                        
                    }else{
                        [self uploadPhotoPostOfNotificationInfoToSever:strPhotoPostId photoObject:photo];
                    }*/
                    shared.photoPostObject = photo;
                    [self uploadPhotoPostOfNotificationInfoToSever:strPhotoPostId photoObject:photo];
                    
                }else{
                    [self dismissHireVC];
                }
            }];
        }
        
    }else if([saleType isEqualToString:@"For Hire"]){
        
        if ([strHashTagName isEqualToString:@""] ||strHashTagName == nil || [strHashTag isEqualToString:@""] || strHashTag == nil || [strHashTag isEqualToString:@"select"] || [strStyleTag isEqualToString:@""] || strStyleTag == nil ||  [strDelivery isEqualToString:@""] || strDelivery == nil || [strDelivery isEqualToString:@"select"] || [strDescription isEqualToString:@""] || strDescription == nil || [strHireCondition isEqualToString:@""] ||[strHireCondition isEqualToString:@"Condition"] || strHireCondition == nil  || [strLocationInfo isEqualToString:@""] || strLocationInfo == nil || [strLocationInfo isEqualToString:@"select"] || [strDelivery isEqualToString:@""] || strDelivery == nil || [strDelivery isEqualToString:@"select"] || [strDepositPrice isEqualToString:@""] || [strDepositPrice isEqualToString:@"(null)"] || strDepositPrice == nil || [strItemPrice isEqualToString:@""] || [strItemPrice isEqualToString:@"(null)"] || strItemPrice == nil) {
            [self displayErrorMessage];
        }else{            
            [photo setObject:[PFUser currentUser] forKey:kESPhotoUserKey];
            [photo setObject:shared.selectedUserStyleTagNames forKey:kESPhotoStyleTags];
            [photo setObject:strHashTag forKey:kESPhotoHashTags];
            
            if (![shared.selectPublishAndTag isEqualToString:@"PublishAndTag"] && ![shared.selectPublishAndTag isEqualToString:@"PublishEnd"]) {
                [photo addObject:strSaleType forKey:kESPhotoSaleType];
                [photo addObject:strHashTag forKey:kESPhotoHashTag];
                [photo addObject:strHireCondition forKey:kESCondition];
                //[photo addObject:strLocationInfo forKey:kESLocationCountryInfo];
                [photo addObject:strCountry forKey:kESLocationCountryInfo];
                [photo addObject:strCity forKey:kESLocationCityInfo];
            }
            
            isPostingPhotos = [self shouldUploadImage:shared.selectedBeforeEditOriginalImg];
            if (isPostingPhotos == YES) {
                [photo setObject:self.photoNewPostFile forKey:kESPhotoPictureKey];
            }
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSString *strPhotoPostId = [NSString stringWithFormat:@"%@", photo.objectId];
                    /*if ([shared.currentUserComment isEqualToString:@""] || [shared.currentUserComment isEqualToString:@"(null)"]) {
                     
                     }else{
                     [self uploadPhotoPostOfNotificationInfoToSever:strPhotoPostId photoObject:photo];
                     }*/
                    shared.photoPostObject = photo;
                    [self uploadPhotoPostOfNotificationInfoToSever:strPhotoPostId photoObject:photo];
                    
                }else{
                    [self dismissHireVC];
                }
            }];
        }
    }
}

#pragma upload photo post of notification info to server.
- (void)uploadPhotoPostOfNotificationInfoToSever:(NSString *)photoObjectId photoObject:(PFObject *)photoObject{
    
    ESCache *shared = [ESCache sharedCache];
    shared.photoPostObjectId = photoObjectId;
    [shared.photoPostObject setObject:photoObject forKey:kESPhotoClassKey];
   
    
    PFObject *notificationObject = [PFObject objectWithClassName:kESActivityClassKey];
    
    [notificationObject setObject:[PFUser currentUser] forKey:kESActivityToUserKey];
    [notificationObject setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
    if ([shared.currentUserComment isEqualToString:@""] || shared.currentUserComment == nil) {
        shared.currentUserComment = @"";
    }else{
        [notificationObject setObject:@"comment" forKey:kESActivityTypeKey];
        [notificationObject setObject:shared.currentUserComment forKey:kESActivityContentKey];
    }
    
    [notificationObject setObject:photoObject forKey:kESActivityPhotoKey];
    [notificationObject setObject:photoObjectId forKey:kESActivityPhotoObjectIdKey];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [notificationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
           
            [self uploadFilteredItemPhotoToServer:shared.photoPostObjectId];
            
        }else{
            [self dismissHireVC];
        }
    }];
}


- (void)uploadFilteredItemPhotoToServer:(NSString *)postId{
    
    ESCache *shared = [ESCache sharedCache];
    PFObject *itemObject = [PFObject objectWithClassName:kESPostItemClassKey];
    
    NSString *strHashTag            = lblCategoryName.text;
    NSString *strHashTagName        = txtHashTagName.text;
    NSString *strSaleType           = shared.selectSaleHireType;
    NSString *strDescription        = txtViewDescription.text;
    NSString *strHireCondition      = lblCondition.text;
    NSString *strLocationInfo       = lblLocationCity.text;
    NSString *strDeliveryShipping   = shared.deliveryShippingState;
    NSString *strDeliveryMeet       = shared.deliveryMeetState;
    NSString *strDepositPrice       = [NSString stringWithFormat:@"%@",txtDepositPrice.numericValue];
    NSString *strItemPrice          = [NSString stringWithFormat:@"%@",txtItemPrice.numericValue];
    
    BOOL isPostingPhotos            = NO;
    BOOL isHashTagImgOneFile        = NO;
    BOOL isHashTagImgTwoFile        = NO;
    BOOL isHashTagImgThreeFile      = NO;
    BOOL isHashTagImgFourFile       = NO;
    BOOL isHashTagImgFiveFile       = NO;
    
    
    NSString *hashTagNameKey = @"HashTagName";
    
    if ([saleType isEqualToString:@"For Inspiration"]) {
        
        [itemObject setObject:postId forKey:kESPostPhotoObjectId];
        [itemObject setObject:strHashTagName forKey:hashTagNameKey];
        [itemObject setObject:strSaleType forKey:kESPostItemSaleType];
        [itemObject setObject:strHashTag forKey:kESPostItemHashTags];
        [itemObject setObject:strDescription forKey:kESPostItemHashTagDescription];

        
    }else if([saleType isEqualToString:@"For Sale"]){
        
        [itemObject setObject:postId forKey:kESPostPhotoObjectId];
        [itemObject setObject:strHashTagName forKey:hashTagNameKey];
        [itemObject setObject:strSaleType forKey:kESPostItemSaleType];
        [itemObject setObject:strHashTag forKey:kESPostItemHashTags];
        [itemObject setObject:strDescription forKey:kESPostItemHashTagDescription];
        //[itemObject setObject:strLocationInfo forKey:kESPostItemLocationCountryInfo];
        [itemObject setObject:strCountry forKey:kESPostItemLocationCountryInfo];
        [itemObject setObject:strCity forKey:kESPostItemLocationCityInfo];
        
        [itemObject setObject:strDeliveryShipping forKey:kESPostItemDeliveryShipping];
        [itemObject setObject:strDeliveryMeet forKey:kESPostItemDeliveryMeet];
        [itemObject setObject:strDepositPrice forKey:kESPostItemPrice];
        
        if ([shared.domesticCost isEqualToString:@""] || shared.domesticCost == nil) {
            [itemObject setObject:@"" forKey:kESPostItemDomesticCost];
        }else{
            [itemObject setObject:shared.domesticCost forKey:kESPostItemDomesticCost];
        }
        if ([shared.internationalCost isEqualToString:@""] || shared.internationalCost == nil) {
            [itemObject setObject:@"" forKey:kESPostItemInternationalCost];
        }else{
            [itemObject setObject:shared.internationalCost forKey:kESPostItemInternationalCost];
        }
        
    }else if([saleType isEqualToString:@"For Hire"]){
        
        [itemObject setObject:postId forKey:kESPostPhotoObjectId];
        [itemObject setObject:strHashTagName forKey:hashTagNameKey];
        [itemObject setObject:strSaleType forKey:kESPostItemSaleType];
        [itemObject setObject:strHashTag forKey:kESPostItemHashTags];
        [itemObject setObject:strDescription forKey:kESPostItemHashTagDescription];
        [itemObject setObject:strHireCondition forKey:kESPostItemConditionDetail];
        //[itemObject setObject:strLocationInfo forKey:kESPostItemLocationCountryInfo];
        [itemObject setObject:strCountry forKey:kESPostItemLocationCountryInfo];
        [itemObject setObject:strCity forKey:kESPostItemLocationCityInfo];
        
        [itemObject setObject:strDeliveryShipping forKey:kESPostItemDeliveryShipping];
        [itemObject setObject:strDeliveryMeet forKey:kESPostItemDeliveryMeet];
        [itemObject setObject:strDepositPrice forKey:kESPostItemDepositPrice];
        [itemObject setObject:strItemPrice forKey:kESPostItemPrice];
        
        if ([shared.domesticCost isEqualToString:@""] || shared.domesticCost == nil) {
            [itemObject setObject:@"" forKey:kESPostItemDomesticCost];
        }else{
            [itemObject setObject:shared.domesticCost forKey:kESPostItemDomesticCost];
        }
        if ([shared.internationalCost isEqualToString:@""] || shared.internationalCost == nil) {
            [itemObject setObject:@"" forKey:kESPostItemInternationalCost];
        }else{
            [itemObject setObject:shared.internationalCost forKey:kESPostItemInternationalCost];
        }
    }
    //========= photo posting update part =================//
    if ([shared.selectPublishAndTag isEqualToString:@"PublishAndTag"] || [shared.selectPublishAndTag isEqualToString:@"PublishEnd"]) {
        [shared.photoPostObject addObject:strSaleType forKey:kESPhotoSaleType];
        [shared.photoPostObject addObject:strHashTag forKey:kESPhotoHashTag];
        [shared.photoPostObject addObject:strHireCondition forKey:kESCondition];
        //[shared.photoPostObject addObject:strLocationInfo forKey:kESLocationCountryInfo];
        [shared.photoPostObject addObject:strCountry forKey:kESLocationCountryInfo];
        [shared.photoPostObject addObject:strCity forKey:kESLocationCityInfo];
        [shared.photoPostObject saveEventually];
    }
    //==============================================//
    [itemObject setObject:shared.ratioXPosition forKey:kESPostItemXPosition];
    [itemObject setObject:shared.ratioYPosition forKey:kESPostItemYPosition];
    [itemObject setObject:shared.ratioRectWidth forKey:kESPostItemRatioWidth];
    [itemObject setObject:shared.ratioRectHeight forKey:kESPostItemRatioHeight];
    [itemObject setObject:shared.ratioItemViewXPosition forKey:kESPostItemEdgeRatioXPosition];
    [itemObject setObject:shared.ratioItemViewYPosition forKey:kESPostItemEdgeRatioYPosition];
    
    isPostingPhotos = [self shouldUploadImage:shared.selectedGalleryOriginalImage];
    
    if (isPostingPhotos == YES) {
        [itemObject setObject:self.photoNewPostFile forKey:kESPostItemFilteredImage];
        isHashTagImgOneFile    = [self shouldUploadHashTagOneImage:imgAddPhoto_1.image];
        isHashTagImgTwoFile    = [self shouldUploadHashTagTwoImage:imgAddPhoto_2.image];
        isHashTagImgThreeFile  = [self shouldUploadHashTagThreeImage:imgAddPhoto_3.image];
        isHashTagImgFourFile   = [self shouldUploadHashTagFourImage:imgAddPhoto_4.image];
        isHashTagImgFiveFile   = [self shouldUploadHashTagFiveImage:imgAddPhoto_5.image];
        
        if (isHashTagImgOneFile == YES)
            [itemObject setObject:self.hashTagImgOneFile forKey:kESPostItemHashTagImgOne];
        if (isHashTagImgTwoFile == YES)
            [itemObject setObject:self.hashTagImgTwoFile forKey:kESPostItemHashTagImgTwo];
        if (isHashTagImgThreeFile == YES)
            [itemObject setObject:self.hashTagImgThreeFile forKey:kESPostItemHashTagImgThree];
        if (isHashTagImgFourFile == YES)
            [itemObject setObject:self.hashTagImgFourFile forKey:kESPostItemHashTagImgFour];
        if (isHashTagImgFiveFile == YES)
            [itemObject setObject:self.hashTagImgFiveFile forKey:kESPostItemHashTagImgFive];
        
        //=========== save the filtered item PFObject ==================================//
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [itemObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [ProgressHUD showSuccess:@"Success"];
                [self initGlobalVariables];
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                if ([shared.selectPublishAndTag isEqualToString:@"PublishAndTag"]) {

                      shared.notificationCount++;
                      shared.selectedGalleryOriginalImage = shared.selectedBeforeEditOriginalImg;
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentPhotoEditorVC" object:nil];
                    
                }else if ([shared.selectPublishAndTag isEqualToString:@"PublishEnd"]){
                      shared.selectPublishAndTag = @"";
                      shared.notificationCount = 0;
                }
                
            }else{
                NSLog(@"error ---- %@", error);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
                
            }
        }];
    }
    
}

#pragma init global variables
- (void)initGlobalVariables{
    ESCache *shared = [ESCache sharedCache];
    shared.selectedCategoryName     = @"";
    shared.selectedLocationInfoName = @"";
    shared.deliveryShippingState    = @"No";
    shared.deliveryMeetState        = @"No";
}

#pragma init dismiss Hire VC
- (void)dismissHireVC{
    ESCache *shared = [ESCache sharedCache];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [ProgressHUD showError:@"failed"];
    NSString *error = @"error";
    NSLog(@"%@", error);
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    if ([shared.selectPublishAndTag isEqualToString:@"PublishAndTag"]) {
        shared.selectPublishAndTag = @"";
        shared.selectedGalleryOriginalImage = shared.selectedBeforeEditOriginalImg;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentPhotoEditorVC" object:nil];
    }
}

#pragma resized posting  images
- (BOOL)shouldUploadImage:(UIImage *)anImage{
    
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:42.0f interpolationQuality:kCGInterpolationDefault];

    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData           = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData  = UIImagePNGRepresentation(thumbnailImage);

    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoNewPostFile      = [PFFile fileWithData:imageData];
    self.thumbnailNewPostFile  = [PFFile fileWithData:thumbnailImageData];

    return YES;
}
#pragma pragma resized posting five images
- (BOOL)shouldUploadHashTagOneImage:(UIImage *)hashTagImgOne{
     UIImage *resizedImgOne = [hashTagImgOne resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imgOneData          = UIImageJPEGRepresentation(resizedImgOne, 0.5f);
    if (!imgOneData) {
        return NO;
    }
    self.hashTagImgOneFile = [PFFile fileWithData:imgOneData];
    return YES;
}
- (BOOL)shouldUploadHashTagTwoImage:(UIImage *)hashTagImgTwo{
    UIImage *resizedImgTwo = [hashTagImgTwo resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imgTwoData          = UIImageJPEGRepresentation(resizedImgTwo, 0.5f);
    if (!imgTwoData) {
        return NO;
    }
    self.hashTagImgTwoFile = [PFFile fileWithData:imgTwoData];
    return YES;
}
- (BOOL)shouldUploadHashTagThreeImage:(UIImage *)hashTagImgThree{
    UIImage *resizedImgThree = [hashTagImgThree resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imgThreeData          = UIImageJPEGRepresentation(resizedImgThree, 0.5f);
    if (!imgThreeData) {
        return NO;
    }
    self.hashTagImgThreeFile = [PFFile fileWithData:imgThreeData];
    return YES;
}
- (BOOL)shouldUploadHashTagFourImage:(UIImage *)hashTagImgFour{
    UIImage *resizedImgFour = [hashTagImgFour resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imgFourData          = UIImageJPEGRepresentation(resizedImgFour, 0.5f);
    if (!imgFourData) {
        return NO;
    }
    self.hashTagImgFourFile = [PFFile fileWithData:imgFourData];
    return YES;
}
- (BOOL)shouldUploadHashTagFiveImage:(UIImage *)hashTagImgFive{
    UIImage *resizedImgFive = [hashTagImgFive resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imgFiveData          = UIImageJPEGRepresentation(resizedImgFive, 0.5f);
    if (!imgFiveData) {
        return NO;
    }
    self.hashTagImgFiveFile = [PFFile fileWithData:imgFiveData];
    return YES;
}
#pragma display error message.
- (void)displayErrorMessage{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:@"Please input all information."
                                                      delegate:self cancelButtonTitle:@"Ok"
                                             otherButtonTitles:@"Cancel", nil];
    [alertView show];
}

#pragma receive style tag info of user from server
- (NSString *)receiveUserStyleInfoFromServer{
    NSString *strStyle = @"";
    PFUser *currentUser = [PFUser currentUser];
    NSArray *categoryArray = [[NSArray alloc] init];
    categoryArray = [currentUser objectForKey:kESUserStyleKey];
    strStyle = [categoryArray objectAtIndex:0];
    return strStyle;
}

- (IBAction)btnLearnAbout:(id)sender {
    ESHelpPaidViewController *vc = [[ESHelpPaidViewController alloc]initWithNibName:@"ESHelpPaidViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:NO completion:nil];
    
}

#pragma load view option.
- (void)loadViewForInspiration{
    viewInfo.hidden         = NO;
    viewDescription.hidden  = NO;
    viewHireCondition.hidden= YES;
    viewLocation.hidden     = YES;
    viewDelivery.hidden     = YES;
    viewPrice.hidden        = YES;
    viewItemPrice.hidden    = YES;
    btnHelpPaidLink.hidden  = YES;
}

- (void)loadViewForSale{
    viewDescription.hidden  = NO;
    viewHireCondition.hidden= NO;
    viewInfo.hidden         = NO;
    lblDepositPrice.text    = @"Item Price";
    viewItemPrice.hidden    = YES;
}

- (void)loadviewForHire{
    viewDescription.hidden   = NO;
    lblHireConditionTitle.text = @"&HIRE CONDITIONS";
    viewHireCondition.hidden = NO;
    viewInfo.hidden          = NO;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   
    [txtHashTagName resignFirstResponder];
    [txtViewDescription resignFirstResponder];
    [txtDepositPrice resignFirstResponder];
    [txtItemPrice resignFirstResponder];
}

#pragma init placeholder textview
- (void)initPlaceholderTextView{
    txtViewDescription.placeholder = @"Please describe your item with information about the brand, condition, size, colour and style.";
    txtViewDescription.placeholderTextColor = [UIColor lightGrayColor];
    txtViewDescription.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:11.0];
}

#pragma init currency textfield
- (void)initCurrencyTextField{

    UIColor *placeholderColor = [UIColor lightGrayColor];
    txtDepositPrice.placeholderColor = placeholderColor;
    txtDepositPrice.type = MPNumericTextFieldCurrency;
    txtDepositPrice.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtDepositPrice.currencyCode = @"USD";
    txtDepositPrice.delegate = self;
    
    txtItemPrice.placeholderColor = placeholderColor;
    txtItemPrice.type = MPNumericTextFieldCurrency;
    txtItemPrice.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtItemPrice.currencyCode = @"USD";
    txtItemPrice.delegate = self;
   
}

#pragma mark - UITextFieldDelegate method.

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == txtDepositPrice) {
        NSLog(@"start 1");
//        [self upViewToTop];
    }
    if (textField == txtItemPrice) {
        NSLog(@"start 2");
//        [self upViewToTop];
    }
}

- (void)upViewToTop{

    CGRect newFrame = CGRectMake(0.0f, -160.0f, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame = newFrame;
        
        
    }completion:^(BOOL finished) {
        
    }];
}
- (void)downViewToBottom{
    CGRect newFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame = newFrame;
        
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
//    [self downViewToBottom];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [txtHashTagName resignFirstResponder];
    return YES;
}
- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [scrollView setContentOffset:CGPointMake(0.0f, scrollView.contentSize.height-kbSize.height-300) animated:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
   
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;{
  
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


