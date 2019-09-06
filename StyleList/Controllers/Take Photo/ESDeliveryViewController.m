 //
//  ESDeliveryViewController.m
//  Style List
//
//  Created by 123 on 3/4/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESDeliveryViewController.h"
#import "ESShipTipsViewController.h"

@interface ESDeliveryViewController ()<UITextFieldDelegate>{
    BOOL selectedDomesticCost;
    BOOL selectedInternationalCost;
}

@end

@implementation ESDeliveryViewController
@synthesize shippingSwitch, meetSwitch, viewDomestic, domesticSwitch, internationalSwitch, txtDomestic, txtInternational;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [self initDomesticCurrencyTextField];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    ESCache *shared = [ESCache sharedCache];
    if (shared.deliveryMeetState == nil || [shared.deliveryMeetState isEqualToString:@""] || [shared.deliveryMeetState isEqualToString:@"No"]) {
        
        shared.deliveryMeetState = @"No";
        [meetSwitch setOn:NO];
        
    }else if (shared.deliveryMeetState != nil || ![shared.deliveryMeetState isEqualToString:@""] || [shared.deliveryMeetState isEqualToString:@"Yes"]){
        
        shared.deliveryMeetState = @"Yes";
        [meetSwitch setOn:YES];
        
    }
    
    if (shared.deliveryShippingState == nil || [shared.deliveryShippingState isEqualToString:@""] || [shared.deliveryShippingState isEqualToString:@"No"]) {
        
        shared.deliveryShippingState = @"No";
        viewDomestic.hidden = YES;
        [shippingSwitch setOn:NO];
        
    }else if (shared.deliveryShippingState != nil || ![shared.deliveryShippingState isEqualToString:@""] || [shared.deliveryShippingState isEqualToString:@"Yes"]){
        
        shared.deliveryShippingState = @"Yes";
        [shippingSwitch setOn:YES];
        viewDomestic.hidden = NO;
        if (shared.domesticCost == nil || [shared.domesticCost isEqualToString:@""]) {
            
            selectedDomesticCost         = NO;
            [domesticSwitch setOn:NO];
            txtDomestic.hidden           = YES;
            txtDomestic.text             = @"£5.00";
            
        }else{
            [domesticSwitch setOn:YES];
            selectedDomesticCost         = YES;
            txtDomestic.hidden           = NO;
            txtDomestic.text             = [NSString stringWithFormat:@"£%@", shared.domesticCost];
        }
        
        if (shared.internationalCost == nil || [shared.internationalCost isEqualToString:@""]) {
            
            [internationalSwitch setOn:NO];
            selectedInternationalCost    = NO;
            txtInternational.hidden      = YES;
            txtInternational.text        = @"£5.00";
            
        }else{
            
            [internationalSwitch setOn:YES];
            selectedInternationalCost    = YES;
            txtInternational.hidden      = NO;
            txtInternational.text        = [NSString stringWithFormat:@"£%@", shared.internationalCost];;
            
        }
    }
    /*shared.deliveryShippingState = @"No";
    shared.deliveryMeetState     = @"No";
    shared.domesticCost          = @"";
    shared.internationalCost     = @"";
    selectedDomesticCost         = NO;
    selectedInternationalCost    = NO;*/
}

- (IBAction)btnBackClicked:(id)sender {
    
    ESCache *shared = [ESCache sharedCache];
    
    if ([shared.deliveryShippingState isEqualToString:@"Yes"] && selectedDomesticCost == NO && selectedInternationalCost == NO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"A shipping option is required" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        if ([shared.deliveryShippingState isEqualToString:@"Yes"]) {
            if ([txtDomestic.text isEqualToString:@"£5.00"] && selectedDomesticCost == YES) {
                shared.domesticCost = @"5.00";
            }else if ([txtDomestic.text isEqualToString:@"£5.00"] && selectedDomesticCost == NO){
                shared.domesticCost = @"";
            }else{
                
                
            }
            if ([txtInternational.text isEqualToString:@"£5.00"] && selectedInternationalCost == YES) {
                shared.internationalCost = @"5.00";
            }else if ([txtInternational.text isEqualToString:@"£5.00"] && selectedInternationalCost == NO){
                shared.internationalCost = @"";
            }else {
              
            }
        }
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)shippingSwitchState:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    if ([shippingSwitch isOn]) {
        shared.deliveryShippingState = @"Yes";
        NSLog(@"Switch is on");
        viewDomestic.hidden = NO;
    } else {
        shared.deliveryShippingState = @"No";
        NSLog(@"Switch is off");
        viewDomestic.hidden = YES;
    }
}

- (IBAction)meetSwitchState:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    if ([meetSwitch isOn]) {
        shared.deliveryMeetState = @"Yes";
        NSLog(@"Switch is on");
    } else {
        shared.deliveryMeetState = @"No";
        NSLog(@"Switch is off");
    }
}
- (IBAction)domesticSwitchState:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    if ([domesticSwitch isOn]) {
        txtDomestic.hidden = NO;
        txtDomestic.text = @"£5.00";
        shared.domesticCost = @"5.00";
        selectedDomesticCost = YES;
    }else{
        txtDomestic.hidden = YES;
        txtDomestic.text = @"";
        shared.domesticCost = @"";
        selectedDomesticCost = NO;
    }
}

- (IBAction)internationalSwitchState:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    if ([internationalSwitch isOn]) {
        txtInternational.hidden = NO;
        txtInternational.text = @"£5.00";
        shared.internationalCost = @"5.00";
        selectedInternationalCost = YES;
    }else{
        txtInternational.hidden = YES;
        txtInternational.text = @"";
        shared.internationalCost = @"";
        selectedInternationalCost = NO;
    }
}

#pragma init currency textfield
- (void)initDomesticCurrencyTextField{
    
    UIColor *placeholderColor = [UIColor lightGrayColor];
    txtDomestic.placeholderColor = placeholderColor;
    txtDomestic.type = MPNumericTextFieldCurrency;
    txtDomestic.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtDomestic.currencyCode = @"GBP";
    txtDomestic.text = @"£5.00";
    txtDomestic.delegate = self;
    
    txtInternational.placeholderColor = placeholderColor;
    txtInternational.type = MPNumericTextFieldCurrency;
    txtInternational.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtInternational.currencyCode = @"GBP";
    txtInternational.text = @"£5.00";
    txtInternational.delegate = self;
    
}

#pragma mark - UITextField Delegate method.
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    ESCache *shared = [ESCache sharedCache];
    if (textField == txtDomestic) {
        NSString *domesticCost = [NSString stringWithFormat:@"%@", txtDomestic.numericValue];
        if (domesticCost == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please input domestic cost!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            shared.domesticCost = domesticCost;
        }
        
    }
    if (textField == txtInternational){
        NSString *internationaCost = [NSString stringWithFormat:@"%@", txtInternational.numericValue];
        if (internationaCost == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please input international cost!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            shared.internationalCost = internationaCost;
        }
       
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    ESCache *shared = [ESCache sharedCache];
    if (textField == txtDomestic) {
        NSString *domesticCost = [NSString stringWithFormat:@"%@", txtDomestic.numericValue];
        shared.domesticCost = domesticCost;
    }
    if (textField == txtInternational){
        NSString *internationalCost = [NSString stringWithFormat:@"%@", txtInternational.numericValue];
        shared.internationalCost = internationalCost;
    }
}

- (IBAction)btnReadShippingTipClicked:(id)sender {
    ESShipTipsViewController *vc = [[ESShipTipsViewController alloc]initWithNibName:@"ESShipTipsViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:NO completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
