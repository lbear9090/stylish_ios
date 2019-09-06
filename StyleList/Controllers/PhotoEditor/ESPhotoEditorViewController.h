//
//  ESPhotoEditorViewController.h
//  Style List
//
//  Created by 123 on 3/4/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESPhotoEditorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *drawImgView;
@property (weak, nonatomic) IBOutlet UIButton *btnDraw;
@property (weak, nonatomic) IBOutlet UIButton *btnCrop;
@property (weak, nonatomic) IBOutlet UIView *drawView;
@property (weak, nonatomic) IBOutlet UIImageView *tempImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnMagnification;

@end
