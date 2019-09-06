//
//  ESPayViewController.m
//  Style List
//
//  Created by 123 on 5/28/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESPayViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ESPayViewController (){
    BOOL isPaypalLogined;
}

@end

@implementation ESPayViewController

@synthesize itemObject, itemPostUser;
@synthesize btnLogInPay;
@synthesize txtPaypalPwd, txtPaypalEmail;
@synthesize lblStyleTagName, lblCost;

- (id)initPaymentWithItemObject:(PFObject *)object postingUser:(PFUser *)postUser{
    
    self = [super initWithNibName:@"ESPayViewController" bundle:nil];
    
    if (self) {
        itemObject = object;
        itemPostUser = postUser;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    PFUser *user = [PFUser currentUser];
    NSString *paypalAddress = [user objectForKey:kESUserPaypalKey];
    isPaypalLogined = NO;
    NSString *styleTag = [itemObject objectForKey:@"HashTagName"];
    lblStyleTagName.text = styleTag;
    NSString *cost = [itemObject objectForKey:kESPostItemPrice];
    lblCost.text = [NSString stringWithFormat:@"$%@", cost];
    NSString *paypalEmail = [itemPostUser objectForKey:kESUserPaypalKey];
    NSLog(@"Paypal-%@", paypalEmail);
    //if (paypalEmail !=nil || ![paypalEmail isEqualToString:@""] ) {
    if (paypalAddress !=nil || ![paypalAddress isEqualToString:@""] ) {
        //txtPaypalEmail.text = paypalEmail;
        txtPaypalEmail.text = paypalAddress;
    }
}

- (IBAction)btnLoginPayClicked:(id)sender {
    [self getAccessToken];
    /*if (isPaypalLogined == NO) {
        NSString *paypalEmail = txtPaypalEmail.text;
        NSString *paypalPwd   = txtPaypalPwd.text;
        if (paypalEmail != nil && paypalPwd !=nil) {
            [self loginToPaypalMarketPlace:paypalEmail paypalPwd:paypalPwd];
        }
        
    }else{
        [self payItemCostToPaypalMarketPlace];
    }*/
}

-(void)orderProcess:(NSString *) token{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"EXAMPLE_MP" forHTTPHeaderField:@"PayPal-Partner-Attribution-Id"];
    NSDictionary *params = @{@"purchase_units":@[
                                 @{
                                     @"reference_id": [[NSUUID UUID] UUIDString],
                                     @"description": @"Default Level 1 Order",
                                     @"items": @[
                                               @{
                                                   @"name": @"Salad",
                                                   @"sku": [NSString stringWithFormat:@"SKU-%@", [[NSUUID UUID] UUIDString]],
                                                   @"price": @"5.00",
                                                   @"currency": @"USD",
                                                   @"quantity": @1,
                                                   @"category": @"PHYSICAL"
                                               },
                                               ],
                                     @"payee": @{
                                         @"email": @"lbear9090@hotmail.com",
                                         @"payee_display_metadata": @{
                                             @"brand_name": @"Test Store",
                                             @"phone": @{
                                                 @"country_code": @"1",
                                                 @"number": @"6025550128"
                                             }
                                         }
                                     },
                                     @"shipping_address": @{
                                         @"recipient_name": @"Rylee Lueilwitz",
                                         @"line1": @"965 Hilma Rapid",
                                         @"line2": @"Apartment Number 91392",
                                         @"city": @"Gilbert",
                                         @"country_code": @"US",
                                         @"postal_code": @"85298",
                                         @"state": @"AZ",
                                         @"phone": @"0018882211161"
                                     },
                                     @"shipping_method": @"United Postal Service",
                                     @"payment_linked_group": @1,
                                     @"custom": @"MyCustomVar",
                                     @"invoice_number": [NSString stringWithFormat:@"INV-%@", [[NSUUID UUID] UUIDString]],
                                     @"payment_descriptor": @"Payment Nate Shop",
                                     @"amount": @{
                                         @"currency": @"USD",
                                         @"details": @{
                                             @"subtotal": @"5.00",
                                             @"shipping": @"0",
                                             @"tax": @"0"
                                         },
                                         @"total": @"5.00"
                                     },
                                     @"partner_fee_details": @{
                                         @"amount": @{
                                             @"currency": @"USD",
                                             @"value": @"5.00"
                                         },
                                         @"receiver": @{
                                             @"email": @"facilitator@example.com",
                                             @"merchant_id": @"6HHS8L6HG2APC",
                                             @"payee_display_metadata": @{
                                                 @"email": @"facilitator@example.com",
                                                 @"display_phone": @{
                                                     @"country_code": @"001",
                                                     @"number": @"8882211161"
                                                 },
                                                 @"brand_name": @"APEX"
                                             }
                                         }
                                     }
                                 }
                             ],
                             @"application_context": @{
                                 @"brand_name": @"Test Store",
                                 @"locale": @"en-US",
                                 @"landing_page": @"Login",
                                 @"shipping_preferences": @"NO_SHIPPING",
                                 @"user_action": @"continue"
                             },
                             @"metadata": @{
                                 @"postback_data": @[
                                                   @{
                                                       @"name": @"metaOneName",
                                                       @"value": @"metaOneValue"
                                                   }
                                                   ],
                                 @"supplementary_data": @[
                                                        @{
                                                            @"name": @"supplementaryOneName",
                                                            @"value": @"supplementaryOneValue"
                                                        }
                                                        ]
                             },
                             @"redirect_urls": @{
                                 @"return_url": @"https://example.com/return",
                                 @"cancel_url": @"https://example.com/cancel"
                             }
                             };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager POST:@"https://api.sandbox.paypal.com/v1/checkout/orders" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        [MBProgressHUD  hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [MBProgressHUD  hideHUDForView:self.view animated:YES];
    }];
}
-(void)getAccessToken{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:PAYPAL_CLIENT_ID password:PAYPAL_SECRET];
    NSString *grant_type = @"client_credentials";
    NSDictionary *params = @{@"grant_type":grant_type};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager POST:PAYPAL_LOGIN_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSString *token = [responseObject objectForKey:@"access_token"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:token forKey:PAYPAL_TOKEN];
        [userDefault synchronize];
        self->isPaypalLogined = YES;
        [self orderProcess:token];
        [MBProgressHUD  hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self->isPaypalLogined = NO;
        [MBProgressHUD  hideHUDForView:self.view animated:YES];
    }];
}
#pragma mark - login to paypal market place
- (void)loginToPaypalMarketPlace:(NSString *)email paypalPwd:(NSString *)pwd{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *grant_type = @"client_credentials";
    NSDictionary *params = @{@"email": email,
                             @"password": pwd,
                             @"grant_type":grant_type};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager POST:PAYPAL_LOGIN_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self->isPaypalLogined = YES;
//        [btnLogInPay setTitle:@"Pay" forState:UIControlStateNormal];
        NSString *token = [responseObject objectForKey:@"access_token"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:token forKey:PAYPAL_TOKEN];
        [userDefault synchronize];
        [MBProgressHUD  hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //[btnLogInPay setTitle:@"Pay" forState:UIControlStateNormal];
        self->isPaypalLogined = NO;
        [MBProgressHUD  hideHUDForView:self.view animated:YES];
    }];
}
#pragma mark - pay item cost to paypal market place
- (void)payItemCostToPaypalMarketPlace{
    NSLog(@"payment ---");
}

- (IBAction)btnCancelClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextField Delegate Method.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [txtPaypalEmail resignFirstResponder];
    [txtPaypalPwd resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
