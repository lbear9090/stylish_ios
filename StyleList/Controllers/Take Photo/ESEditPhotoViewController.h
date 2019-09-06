//
//  ESEditPhotoViewController.h
//  Style List
//
//  Created by 123 on 4/11/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImage+ResizeAdditions.h"
#import "PXAlertView.h"

@interface ESEditPhotoViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CLLocationManagerDelegate>{
    /**
     *  Geocoder, containing the geolocation information of the photo.
     */
    CLGeocoder *geocoder;
    /**
     *  Placemark, based on the geolocation we have.
     */
    CLPlacemark *placeMark;
    CLLocationManager *locationManager;
    /**
     *  Location string. This string is displayed and contains the nearest city or state where the photo has been taken.
     */
    NSString *localityString;
}

/**
 *  PFFile of the photo, will be uploaded to Parse.
 */
@property (nonatomic, strong) PFFile *photoFile;
/**
 *  PFFile of the photo thumbnail, will be uploaded to Parse.
 */
@property (nonatomic, strong) PFFile *thumbnailFile;
/**
 *  ID of the file upload backgroundtask.
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
/**
 *  ID of the post backgroundtask.
 */
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@property (nonatomic, strong)        UIImage        *image;
@property (weak, nonatomic) IBOutlet UIButton       *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton       *btnPublish;
@property (weak, nonatomic) IBOutlet UIButton       *btnDown;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIView         *viewSaleType;
@property (weak, nonatomic) IBOutlet UIView         *viewComment;
@property (weak, nonatomic) IBOutlet UIView         *viewItemTagName;
@property (weak, nonatomic) IBOutlet UIView *viewCommentForPublish;

@property (weak, nonatomic) IBOutlet UIImageView    *photoImageView;
@property (weak, nonatomic) IBOutlet UITextField    *txtSaleType;
@property (weak, nonatomic) IBOutlet UITextField    *txtComment;
@property (weak, nonatomic) IBOutlet UITextField    *txtItemTagName;
@property (weak, nonatomic) IBOutlet UITextField *txtCommentForPublish;

@property (weak, nonatomic) IBOutlet UILabel        *lblItemTagName;
@property (weak, nonatomic) IBOutlet UITableView    *tblSaleType;


@end
