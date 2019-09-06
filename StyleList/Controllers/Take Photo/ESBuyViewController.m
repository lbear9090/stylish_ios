//
//  ESBuyViewController.m
//  Style List
//
//  Created by 123 on 3/10/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESBuyViewController.h"
#import "ESImageView.h"
#import "MBProgressHUD.h"
#import "ESPayViewController.h"

@interface ESBuyViewController ()<UIScrollViewDelegate>{
    NSMutableArray *arrPhotoData;
    BOOL isOwn;
    BOOL isBookmark;
    NSInteger  itemObjectOwnedCount;
    
    NSString *totalCost;
    __weak IBOutlet UISwitch *switchShipping;
    __weak IBOutlet UISwitch *switchMIPerson;
    __weak IBOutlet UILabel *lblMIPerson;
}

@end

@implementation ESBuyViewController

@synthesize payPalConfig;
@synthesize selectObject, userProfileImageFile, hashTagImageFileOne, hashTagImageFileTwo, hashTagImageFileThree, hashTagImageFileFour, hashTagImageFileFive;
@synthesize lblUserName, lblUserSmallName, lblPostedTime, lblHashTagName, lblHashTag,lblHashTagDescription,lblHireCondition, lblMeetInPerson, lblItemPrice,strItemPrice, lblShippingPrice, lblDepositPrice,lblTotalPrice, lblSaleType;
@synthesize txtLocationCityInfo;
@synthesize imgProfile, imgShippingCheck;
@synthesize scrollView, pageControl;
@synthesize btnHand, btnBookmark, btnBuy;
@synthesize lblDeliveryOption,viewDeposit, lblDeposit, viewShipping,lblShipping, viewTotal, lblTotal, viewDeliveryOption;
@synthesize strItemObjectId, strSelectPhotoPostId, postingToUser, postingFromUser, arrayOwnedItemObject, arrayBookmarkedItemObject;
@synthesize viewTitleBar, lblTagName, lblOwnTag, lblCostTag, selectedItemTag, postOriginalImage;

- (id)initWithPhoto:(PFObject*)object objectId:(NSString *)itemObjectId postPhotoId:(NSString *)selectPhotoPostId toUser:(PFUser *)selectedPostingUser regOwnedItemObject:(NSMutableArray *)regOwnedItemObjectArray regBookmarkedItemObject:(NSMutableArray *)regBookmarkedItemObjectArray tag:(NSInteger)selectedItemObjectTag originImg:(UIImage *)postingOriginImage{
    
    self = [super initWithNibName:@"ESBuyViewController" bundle:nil];
    
    if (self) {
        ESCache *shared             = [ESCache sharedCache];
        arrayOwnedItemObject        = [[NSMutableArray alloc]init];
        arrayBookmarkedItemObject   = [[NSMutableArray alloc]init];
        postOriginalImage           = [[UIImage alloc]init];
        postOriginalImage           = postingOriginImage;
        itemObjectOwnedCount        = 0;
        selectedItemTag             = selectedItemObjectTag;
        
        self.selectObject           = object;
        strItemObjectId             = itemObjectId;
        strSelectPhotoPostId        = selectPhotoPostId;
        postingToUser               = selectedPostingUser;
        
        NSMutableDictionary *dictInfo = [shared.arrOwnLabel objectAtIndex:selectedItemTag];
        
        NSString *bookmarkState = [dictInfo objectForKey:kESBookmarkState];
        NSString *ownCount      = [dictInfo objectForKey:kESOwnedCount];
        NSString *ownState      = [dictInfo objectForKey:kESOwnState];
        
        itemObjectOwnedCount    = [ownCount integerValue];
        if ([bookmarkState isEqualToString:@"Yes"]) {
            isBookmark = YES;
        }else if([bookmarkState isEqualToString:@"No"]){
            isBookmark = NO;
        }else{
            isBookmark = NO;
        }
        if ([ownState isEqualToString:@"Yes"]) {
            isOwn = YES;
        }else if ([ownState isEqualToString:@"No"]){
            isOwn = NO;
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [self showPaypalConfig];
    
    if (isOwn == YES) {
        [btnHand setImage:[UIImage imageNamed:@"btnHand_ena.png"] forState:UIControlStateNormal];
    }else if (isOwn == NO){
        [btnHand setImage:[UIImage imageNamed:@"btnHand_dis.png"] forState:UIControlStateNormal];
    }
    if (isBookmark == YES) {
        [btnBookmark setImage:[UIImage imageNamed:@"btnBookmark_ena.png"] forState:UIControlStateNormal];
    }else if (isBookmark == NO){
        [btnBookmark setImage:[UIImage imageNamed:@"btnBookmark_dis.png"] forState:UIControlStateNormal];
    }
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    ESCache *shared    = [ESCache sharedCache];
    arrPhotoData       = [[NSMutableArray alloc]init];
    NSDictionary *dict = [[NSDictionary alloc]init];
    dict               = selectObject;
    
    viewTitleBar.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.70f];
    [viewTitleBar.layer setCornerRadius:5.0f];
    viewTitleBar.layer.masksToBounds = YES;
    
    userProfileImageFile        = [shared.selectedItemObjectUser objectForKey:kESUserProfilePicSmallKey];
    [imgProfile setFile:userProfileImageFile];
    
    hashTagImageFileOne         = [dict objectForKey:kESPhotoHashTagImgOne];
    hashTagImageFileTwo         = [dict objectForKey:kESPhotoHashTagImgTwo];
    hashTagImageFileThree       = [dict objectForKey:kESPhotoHashTagImgThree];
    hashTagImageFileFour        = [dict objectForKey:kESPhotoHashTagImgFour];
    hashTagImageFileFive        = [dict objectForKey:kESPhotoHashTagImgFive];
    
    [self getImageFileDataArray:hashTagImageFileOne];
    [self getImageFileDataArray:hashTagImageFileTwo];
    [self getImageFileDataArray:hashTagImageFileThree];
    [self getImageFileDataArray:hashTagImageFileFour];
    [self getImageFileDataArray:hashTagImageFileFive];
    
    NSLog(@"file data array count ---  %lu", (unsigned long)arrPhotoData.count);
    
    [self setupScrollImages];
    
    scrollView.pagingEnabled = YES;
    scrollView.delegate      = self;
    [scrollView.layer setCornerRadius:5.0f];
    
//    [scrollView.layer setBorderColor:[UIColor colorWithRed:210.0f/255.0f green:167.0f/255.0f blue:132.0f/255.0f alpha:1.0f].CGColor];
//    [scrollView.layer setBorderWidth:2.0f];
    [scrollView.layer setMasksToBounds:YES];
    
    
    pageControl.numberOfPages = [arrPhotoData count];
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    
    self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    self.timeIntervalFormatter.usesAbbreviatedCalendarUnits = YES;
    [self elapsedTime];
    
    NSString *strSaleType       = [dict objectForKey:kESPhotoSaleType];
//    lblSaleType.text            = strSaleType;
 
    NSString *strUser           = [shared.selectedItemObjectUser objectForKey:kESUserDisplayNameKey];
    NSString *strSamllName      = [shared.selectedItemObjectUser objectForKey:kESUserDisplayNameLowerKey];
    NSString *strHashTagName    = [dict objectForKey:@"HashTagName"];
    NSString *strHashTag        = [dict objectForKey:kESPostItemHashTags];
//    NSString *strMeetInPerson   = [dict objectForKey:kESPostItemDeliveryMeet];
//    NSString *strDeliveryShipping = [dict objectForKey:kESPostItemDeliveryShipping];
    
    
    strItemPrice                = [dict objectForKey:kESPostItemPrice];
    
    double itemPrice            = [strItemPrice floatValue];
    NSString *strDepositPrice   = [dict objectForKey:kESPostItemDepositPrice];
    double depositPrice         = [strDepositPrice floatValue];
     
    NSString *strHashTagDescription = [dict objectForKey:kESPhotoHashTagDescription];
    NSString *strHireCondition      = [dict objectForKey:kESPostItemConditionDetail];
    NSString *strLocationCountryInfo   = [dict objectForKey:kESLocationCountryInfo];
    NSString *strLocationCityInfo   = [dict objectForKey:kESLocationCityInfo];
    
    if (strItemPrice == nil) {
        strItemPrice = @"";
        lblItemPrice.text           = [NSString stringWithFormat:@"%@",strItemPrice];
    }
    if (strDepositPrice == nil) {
        strDepositPrice = @"";
        lblDepositPrice.text        = [NSString stringWithFormat:@"%@",strDepositPrice];
    }
    
    lblSaleType.text                = strHashTagName;
    lblOwnTag.text                  = [NSString stringWithFormat:@"%ld people own this", (long)itemObjectOwnedCount];
    lblTagName.text                 = strHashTagName;
    lblUserName.text                = strUser;
    lblUserSmallName.text           = [NSString stringWithFormat:@"@%@",strSamllName];
    lblHashTagName.text             = strHashTagName;
    lblHashTag.text                 = [NSString stringWithFormat:@"#%@",strHashTag];
    lblHashTagDescription.text      = strHashTagDescription;
    
    if ([strSaleType isEqualToString:@"For Inspiration"]) {
        
        lblHireCondition.hidden     = YES;
        lblDeliveryOption.hidden    = YES;
        viewDeliveryOption.hidden   = YES;
        viewTitleBar.hidden         = YES;
        btnBuy.hidden               = YES;
        
    }else if ([strSaleType isEqualToString:@"For Sale"]){
        
        lblHireCondition.hidden     = YES;
        
        txtLocationCityInfo.text = strLocationCountryInfo;
        lblMIPerson.text = [NSString stringWithFormat:@"Meet In Person - %@(%@)", strLocationCityInfo,strLocationCountryInfo];
        
        /*lblItemPrice.text        = [NSString stringWithFormat:@"$%@",strItemPrice];
        lblTotal.hidden          = YES;
        lblTotalPrice.hidden     = YES;
        lblDeposit.text          = @"Shipping";
        lblShipping.text         = @"Total";
        lblDepositPrice.text     = [NSString stringWithFormat:@"$5.00"];
        NSInteger totalPrice     = itemPrice + 5.00;
        
        NSString *strTotalPrice  = [NSString stringWithFormat:@"$%ld",(long)totalPrice];
        lblShippingPrice.text    = strTotalPrice;
        totalCost = [NSString stringWithFormat:@"%ld", (long)totalPrice];
        lblCostTag.text = [NSString stringWithFormat:@"BUY $%@",strItemPrice];
        [btnBuy setTitle:@"Buy" forState:UIControlStateNormal];*/
        
        lblItemPrice.text        = [NSString stringWithFormat:@"$%@",strItemPrice];
        [self setDeliveryOption: dict];
        [self setPrice:YES];
        
        //lblShippingPrice.text    = [NSString stringWithFormat:@"$5.00"];
        
        //NSInteger totalPrice     = itemPrice + 5.00;
        //NSString *strTotalPrice  = [NSString stringWithFormat:@"$%ld",(long)totalPrice];
        //lblTotalPrice.text       = strTotalPrice;
        
        //lblCostTag.text = [NSString stringWithFormat:@"BUY $%@",strItemPrice];
        [btnBuy setTitle:@"Buy" forState:UIControlStateNormal];
        
        lblDeposit.hidden = YES;
        lblDepositPrice.hidden = YES;
    }else if ([strSaleType isEqualToString:@"For Hire"]){
        lblHireCondition.hidden     = YES;
        lblHireCondition.text       = strHireCondition;
        
        txtLocationCityInfo.text = strLocationCountryInfo;
        lblMIPerson.text = [NSString stringWithFormat:@"Meet In Person - %@(%@)", strLocationCityInfo,strLocationCountryInfo];
        lblItemPrice.text        = [NSString stringWithFormat:@"$%@",strItemPrice];
        lblDepositPrice.text     = strDepositPrice;
        
        [self setDeliveryOption: dict];
        [self setPrice:YES];
        
        //lblShippingPrice.text    = [NSString stringWithFormat:@"$5.00"];
        
        //NSInteger totalPrice     = itemPrice + depositPrice + 5.00;
        //NSString *strTotalPrice  = [NSString stringWithFormat:@"$%ld",(long)totalPrice];
        //lblTotalPrice.text       = strTotalPrice;
        //lblCostTag.text = [NSString stringWithFormat:@"HIRE $%@",strItemPrice];
        
        [btnBuy setTitle:@"Hire" forState:UIControlStateNormal];
        
    }
    
    // Preconnect to PayPal early
    [self setPayPalEnvironment:self.environment];
    
}

-(void)setPrice:(BOOL)isLoading{
    BOOL isMIP = switchMIPerson.isOn;
    BOOL isShipping = switchShipping.isOn;
    NSDictionary *dict = (NSDictionary *)selectObject;
    NSString *strItemPrice                = [dict objectForKey:kESPostItemPrice];
    double itemPrice            = [strItemPrice floatValue];
    NSString *strDepositPrice   = [dict objectForKey:kESPostItemDepositPrice];
    double depositPrice         = [strDepositPrice floatValue];
    float shipPrice = 0;
    NSString *strSaleType       = [dict objectForKey:kESPhotoSaleType];
    
    if([strSaleType isEqualToString:@"For Sale"])
        depositPrice = 0;
    
    if(isMIP){
        shipPrice = 0;
    }else if(isShipping)
    {
        NSString *sInt = [dict objectForKey:kESPostItemInternationalCost];
        NSString *sDom = [dict objectForKey:kESPostItemDomesticCost];
        NSString *sCountry = [dict objectForKey:kESPostItemLocationCountryInfo];
        
        PFUser *user = [PFUser currentUser];
        NSString *sUserCountry = [user objectForKey:kESUserCountryKey];
        
        BOOL isSameCountry = [sCountry isEqualToString:sUserCountry];
        
        if(isSameCountry && (sDom != nil && ![sDom isEqualToString:@""])){
            shipPrice = [sDom floatValue];
        }else if(!isSameCountry && (sInt != nil && ![sInt isEqualToString:@""])){
            shipPrice = [sInt floatValue];
        }else{
            shipPrice = -1;
        }
    }
    
    if(shipPrice < 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, Shipping method isn't eligible to you." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        //Error
        if(isLoading){
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }else{
            switchMIPerson.on = YES;
            switchShipping.on = NO;
            shipPrice = 0;
        }
    }
    lblShippingPrice.text = [NSString stringWithFormat:@"%.2f", shipPrice];
    float totalPrice     = itemPrice + depositPrice + shipPrice;
    NSString *strTotalPrice  = [NSString stringWithFormat:@"$%.2f",totalPrice];
    lblTotalPrice.text       = strTotalPrice;
}

-(void)setDeliveryOption:(NSDictionary *)dict{
    NSString *strMeetInPerson   = [dict objectForKey:kESPostItemDeliveryMeet];
    NSString *strDeliveryShipping = [dict objectForKey:kESPostItemDeliveryShipping];
    
    BOOL isMIP = [strMeetInPerson isEqualToString:@"Yes"];
    BOOL isShipping = [strDeliveryShipping isEqualToString:@"Yes"];
    
    if(isMIP && isShipping){
        [switchMIPerson setEnabled:YES];
        [switchShipping setEnabled:YES];
    }else{
        [switchMIPerson setEnabled:NO];
        [switchShipping setEnabled:NO];
    }
    
    [switchMIPerson setOn:isMIP];
    [switchShipping setOn:isShipping];
    
    if(isMIP && isShipping){
        [switchShipping setOn:NO];
    }
    
    /*lblMeetInPerson.text = sMIPerson;
    if([sShipping isEqualToString:@"Yes"]){
     
        [switchShipping setOn:YES];
    }else if ([sShipping isEqualToString:@"No"]){
        imgShippingCheck.hidden = YES;
        [switchShipping setOn:NO];
    }*/
}

- (IBAction)onSwitchMIP:(UISwitch *)sender {
    if(switchMIPerson.isOn && switchShipping.isOn){
        [switchShipping setOn:NO];
    }else if(!switchMIPerson.isOn && !switchShipping.isOn){
        [switchShipping setOn:YES];
    }
    [self setPrice:NO];
}
- (IBAction)onSwitchShipping:(UISwitch *)sender {
    if(switchMIPerson.isOn && switchShipping.isOn){
        [switchMIPerson setOn:NO];
    }else if(!switchMIPerson.isOn && !switchShipping.isOn){
        [switchMIPerson setOn:YES];
    }
    
    [self setPrice:NO];
}

- (void)elapsedTime{
    NSTimeInterval timeInterval = [[selectObject createdAt] timeIntervalSinceNow];
    NSString *strTimeStamp = [NSString stringWithFormat:@"%@", [self.timeIntervalFormatter stringForTimeInterval:timeInterval]];
    [lblPostedTime setText:strTimeStamp];
}

- (void)setupScrollImages{
    if (arrPhotoData.count>0) {
        for (int i = 0; i < arrPhotoData.count; i++) {
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth(scrollView.frame)*i, 0.0f, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            NSURL *url = [NSURL URLWithString:[arrPhotoData objectAtIndex:i]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            imgView.image = [[UIImage alloc] initWithData:data];
            [scrollView addSubview:imgView];
        }
    }else{
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame))];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = postOriginalImage;
//        [imgView setImage:[UIImage imageNamed:@"PlaceholderPhoto.png"]];
        [scrollView addSubview:imgView];
    }
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * arrPhotoData.count, scrollView.frame.size.height);
}

- (void)getImageFileDataArray:(PFFile *)file{
    
    if (file == nil) {
        NSLog(@"Error image file");
    }else{
        
        NSString *url =file.url;
        [arrPhotoData addObject:url];
        NSLog(@"arrPhotoData count ---  %lu", (unsigned long)arrPhotoData.count);
        
    }
}

#pragma mark - pagecontrol method
-(void)pageTurn:(UIPageControl *) page
{
    NSInteger pageTag = page.currentPage;
    switch (pageTag) {
        case 0:
            
            break;
            
        default:
            break;
    }
}

- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnBuyClicked:(id)sender {
    ESPayViewController *vc = [[ESPayViewController alloc]initPaymentWithItemObject:self.selectObject postingUser:postingToUser];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    // Remove our last completed payment, just for demo purposes.
    /*self.resultText = nil;
    // Optional: include multiple items
    NSString *hashTagItem = lblHashTag.text;
    
    PayPalItem *item1 = [PayPalItem itemWithName:hashTagItem
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:strItemPrice]
                                    withCurrency:@"GBP"
                                         withSku:@"Hip-00037"];
  
    NSArray *items = @[item1];
    NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];
    
    
    // Optional: include payment details
    NSDecimalNumber *shipping = [[NSDecimalNumber alloc] initWithString:@"5.00"];
    NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0.00"];
    PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subtotal withShipping:shipping withTax:tax];
    NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];
    
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = total;
    payment.currencyCode = @"GBP";
    payment.shortDescription = lblHashTagName.text;
    payment.items = items;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil
    
    if (!payment.processable) {
        // This particular payment will always be processable. If, for
        // example, the amount was negative or the shortDescription was
        // empty, this payment wouldn't be processable, and you'd want
        // to handle that here.
    }
    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalConfig delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];*/
}

- (IBAction)btnHandClicked:(id)sender {
    if (isOwn == NO) {
       
        [self registerNewOwnedToServer:strSelectPhotoPostId toUser:postingToUser itemObjectId:strItemObjectId];
    }else if (isOwn == YES){
       
        [self deleteSelectedOwnedFromServer:strSelectPhotoPostId itemObjectId:strItemObjectId];
    }
}
- (IBAction)btnBookmarkClicked:(id)sender {
    if (isBookmark == NO) {
        [self registerNewBookmarkToServer:strSelectPhotoPostId toUser:postingToUser itemObjectId:strItemObjectId];
        
    }else if (isBookmark == YES){
        [self deleteSelectedBookmarkFromServer:strSelectPhotoPostId itemObjectId:strItemObjectId];
    }
}

#pragma register new bookmark to server.
- (void)registerNewBookmarkToServer:(NSString*)photoPostId
                             toUser:(PFUser *)toPostingUser
                       itemObjectId:(NSString *)selectedObjectId
                            {
    
    PFObject *notificationObject = [PFObject objectWithClassName:kESActivityClassKey];
    
    [notificationObject setObject:selectedObjectId forKey:kESActivityItemObjectIdKey];
    [notificationObject setObject:photoPostId forKey:kESActivityPhotoObjectIdKey];
    [notificationObject setObject:toPostingUser forKey:kESActivityToUserKey];
    [notificationObject setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
    [notificationObject setObject:kESActivityTypeItemBookmark forKey:kESActivityTypeKey];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [notificationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (succeeded) {
            [btnBookmark setImage:[UIImage imageNamed:@"btnBookmark_ena.png"] forState:UIControlStateNormal];
            isBookmark = YES;
        }else{
            NSLog(@"error -- %@" , error);
        }
    }];
}

#pragma delete selected bookmark from server.
- (void)deleteSelectedBookmarkFromServer:(NSString*)photoPostId itemObjectId:(NSString *)selectedObjectId{
    
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityItemObjectIdKey equalTo:selectedObjectId];
    [query whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kESActivityTypeKey equalTo:kESActivityTypeItemBookmark];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (object) {
            [object deleteInBackground];
            [btnBookmark setImage:[UIImage imageNamed:@"btnBookmark_dis.png"] forState:UIControlStateNormal];
            isBookmark = NO;
        } else {
            NSLog(@"error--");
        }
    }];
}

#pragma register new owned to server.
- (void)registerNewOwnedToServer:(NSString*)photoPostId
                             toUser:(PFUser *)toPostingUser
                       itemObjectId:(NSString *)selectedObjectId{
    ESCache *shared = [ESCache sharedCache];
    PFObject *notificationObject = [PFObject objectWithClassName:kESActivityClassKey];
    
    [notificationObject setObject:selectedObjectId forKey:kESActivityItemObjectIdKey];
    [notificationObject setObject:photoPostId forKey:kESActivityPhotoObjectIdKey];
    [notificationObject setObject:toPostingUser forKey:kESActivityToUserKey];
    [notificationObject setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
    [notificationObject setObject:kESActivityTypeItemOwned forKey:kESActivityTypeKey];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [notificationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (succeeded) {
            [btnHand setImage:[UIImage imageNamed:@"btnHand_ena.png"] forState:UIControlStateNormal];
            isOwn = YES;
            NSMutableDictionary *dictInfo = [shared.arrOwnLabel objectAtIndex:selectedItemTag];
            [dictInfo setObject:@"Yes" forKey:kESOwnState];
            NSString *oldOwnCount   = [dictInfo objectForKey:kESOwnedCount];
            NSInteger newOwnCount   = [oldOwnCount integerValue];
            newOwnCount             = newOwnCount + 1;
            NSString *strNewOwnCount= [NSString stringWithFormat:@"%ld", (long)newOwnCount];
            lblOwnTag.text          = [NSString stringWithFormat:@"%@ people own this", strNewOwnCount];
            [dictInfo setObject:strNewOwnCount forKey:kESOwnedCount];
            [shared.arrOwnLabel  replaceObjectAtIndex:selectedItemTag withObject:dictInfo];
        }else{
            NSLog(@"error -- %@" , error);
        }
    }];
}
#pragma delete selected owned from server.
- (void)deleteSelectedOwnedFromServer:(NSString*)photoPostId itemObjectId:(NSString *)selectedObjectId{
    ESCache *shared = [ESCache sharedCache];
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityItemObjectIdKey equalTo:selectedObjectId];
    [query whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kESActivityTypeKey equalTo:kESActivityTypeItemOwned];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (object) {
            [object deleteInBackground];
            [btnHand setImage:[UIImage imageNamed:@"btnHand_dis.png"] forState:UIControlStateNormal];
            isOwn = NO;
            NSMutableDictionary *dictInfo = [shared.arrOwnLabel objectAtIndex:selectedItemTag];
            
            NSString *oldOwnCount   = [dictInfo objectForKey:kESOwnedCount];
            NSInteger newOwnCount   = [oldOwnCount integerValue];
            newOwnCount             = newOwnCount - 1;
            NSString *strNewOwnCount= [NSString stringWithFormat:@"%ld", (long)newOwnCount];
            lblOwnTag.text          = [NSString stringWithFormat:@"%@ people own this", strNewOwnCount];
            [dictInfo setObject:strNewOwnCount forKey:kESOwnedCount];
            [shared.arrOwnLabel  replaceObjectAtIndex:selectedItemTag withObject:dictInfo];
        } else {
            NSLog(@"error--");
        }
    }];
}

#pragma load selected item object of owned count from server.
- (void)loadSelectedItemObjectOfOwnedCountFromServer{
    
}
#pragma paypal sdk.
#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    self.resultText = [completedPayment description];
    [self showSuccess];
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    self.resultText = nil;
    self.successView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)showSuccess {
    self.successView.hidden = NO;
    self.successView.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:2.0];
    self.successView.alpha = 0.0f;
    [UIView commitAnimations];
}
#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    // TODO: Send completedPayment.confirmation to server
    NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFObject *obj = [PFObject objectWithClassName:@"Transaction"];
    [obj setObject:[PFUser currentUser] forKey:@"buyer"];
    [obj setObject:postingToUser forKey:@"owner"];
    [obj setObject:self.selectObject forKey:@"item"];
    [obj setObject:totalCost forKey:@"price"];
    NSString *strSaleType       = [selectObject objectForKey:kESPostItemHashTags];
    [obj setObject:strSaleType forKey:@"type"];
    [obj saveEventually];
//    [obj saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//    }];
    
}

- (void)showPaypalConfig{
    // Set up payPalConfig
    payPalConfig = [[PayPalConfiguration alloc] init];
    payPalConfig.acceptCreditCards = YES;
    payPalConfig.merchantName = @"Awesome Shirts, Inc.";
    payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.successView.hidden = YES;
    
    // use default environment, should be Production in real life
    self.environment = kPayPalEnvironment;
    
    NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
}

- (void)setPayPalEnvironment:(NSString *)environment {
    self.environment = environment;
    [PayPalMobile preconnectWithEnvironment:environment];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
