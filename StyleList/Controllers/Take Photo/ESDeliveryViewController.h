//
//  ESDeliveryViewController.h
//  Style List
//
//  Created by 123 on 3/4/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNumericTextField.h"

@interface ESDeliveryViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch           *shippingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch           *meetSwitch;
@property (weak, nonatomic) IBOutlet UIView             *viewDomestic;
@property (weak, nonatomic) IBOutlet UISwitch           *domesticSwitch;
@property (weak, nonatomic) IBOutlet UISwitch           *internationalSwitch;
@property (weak, nonatomic) IBOutlet MPNumericTextField *txtDomestic;
@property (weak, nonatomic) IBOutlet MPNumericTextField *txtInternational;

@end
