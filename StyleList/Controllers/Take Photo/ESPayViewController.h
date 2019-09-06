//
//  ESPayViewController.h
//  Style List
//
//  Created by 123 on 5/28/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESPayViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, strong) PFObject              *itemObject;
@property (nonatomic, strong) PFUser                *itemPostUser;
@property (weak, nonatomic) IBOutlet UILabel        *lblStyleTagName;
@property (weak, nonatomic) IBOutlet UILabel        *lblCost;
@property (weak, nonatomic) IBOutlet UITextField    *txtPaypalEmail;
@property (weak, nonatomic) IBOutlet UITextField    *txtPaypalPwd;
@property (weak, nonatomic) IBOutlet UIButton       *btnLogInPay;

- (id)initPaymentWithItemObject:(PFObject *)object postingUser:(PFUser *)postUser;

@end
