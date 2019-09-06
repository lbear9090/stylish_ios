//
//  ESPhotoEditorViewController.m
//  Style List
//
//  Created by 123 on 3/4/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESPhotoEditorViewController.h"
#import "UIImage+Utility.h"
#import "PhotoTweaksViewController.h"
#import "CHMagnifierView.h"

@interface ESPhotoEditorViewController ()<PhotoTweaksViewControllerDelegate>{
    BOOL selectDraw;
    BOOL mouseSwiped;
    BOOL onlyOneDraw;
    BOOL selectMagnifier;
    UIBezierPath *_aPath;
    CGPoint firstPoint;
    CGPoint lastPoint;
    UIImage *orgImage;
}
@property (strong, nonatomic) NSTimer *touchTimer;
@property (strong, nonatomic) CHMagnifierView *magnifierView;

@end

@implementation ESPhotoEditorViewController

@synthesize drawImgView, btnDraw, btnCrop,btnMagnification, drawView, tempImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    selectDraw = NO;
    mouseSwiped = NO;
    onlyOneDraw = NO;
    selectMagnifier = NO;
    [btnMagnification setBackgroundImage:[UIImage imageNamed:@"btnMagnification_dis.png"] forState:UIControlStateNormal];
    
    ESCache *shared = [ESCache sharedCache];
    drawImgView.image = shared.selectedGalleryOriginalImage;
    shared.selectedGalleryOriginalImage = [self renderWholeImageView:drawImgView];
    
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    ESCache *shared = [ESCache sharedCache];
    shared.selectedGalleryOriginalImage = drawImgView.image;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
//    ESCache *shared = [ESCache sharedCache];
//    shared.photoEditedTag = @"";
}

- (IBAction)btnCancelClicked:(id)sender {
    if(onlyOneDraw){
        onlyOneDraw = NO;
        ESCache *shared = [ESCache sharedCache];
        drawImgView.image = shared.selectedGalleryOriginalImage;
        self.tempImageView.image = nil;
        shared.drawingInPath = nil;
        //shared.selectedGalleryDrawingImage = drawImgView.image;
        shared.photoEditedTag = @"";
        [_aPath removeAllPoints];
    }else{
        ESCache *shared = [ESCache sharedCache];
        shared.photoEditedTag = @"";
        shared.ratioXPosition = @"";
        shared.ratioYPosition = @"";
        shared.ratioRectWidth = @"";
        shared.ratioRectHeight = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)btnDoneClicked:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([shared.photoEditedTag isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentEditPhotoVC" object:nil];
    }else if ([shared.photoEditedTag isEqualToString:@"photoEdited"]){
         [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentPhotoFilterVC" object:nil];
    }
}
#pragma magnifier function.

- (IBAction)btnMagnifierClicked:(id)sender {
    if(selectMagnifier == NO){
        selectMagnifier = YES;
        [btnMagnification setBackgroundImage:[UIImage imageNamed:@"btnMagnification_ena.png"] forState:UIControlStateNormal];
    }else if (selectMagnifier == YES){
        selectMagnifier = NO;
        [btnMagnification setBackgroundImage:[UIImage imageNamed:@"btnMagnification_dis.png"] forState:UIControlStateNormal];
    }
    
}
- (IBAction)btnDrawClicked:(id)sender {
    
    if (selectDraw == NO) {
        selectDraw = YES;
        mouseSwiped = YES;
        [btnDraw setImage:[UIImage imageNamed:@"draw_black.png"] forState:UIControlStateNormal];
        selectMagnifier = NO;
        [btnMagnification setBackgroundImage:[UIImage imageNamed:@"btnMagnification_dis.png"] forState:UIControlStateNormal];
        [self renderImage];
    }else if (selectDraw == YES){
        selectDraw = NO;
        mouseSwiped = NO;
        [btnDraw setImage:[UIImage imageNamed:@"draw_white.png"] forState:UIControlStateNormal];
        [self renderImage];
    }
}

- (IBAction)btnCropClicked:(id)sender {
    selectMagnifier = NO;
    [btnMagnification setBackgroundImage:[UIImage imageNamed:@"btnMagnification_dis.png"] forState:UIControlStateNormal];
    drawImgView.image = [self renderWholeImageView:drawImgView];
    PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:drawImgView.image];
    photoTweaksViewController.delegate = self;
    photoTweaksViewController.maxRotationAngle = M_PI_4;
    [self.navigationController presentViewController:photoTweaksViewController animated:YES completion:nil];
   
}

#pragma Crop view controller delegate method.
- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    drawImgView.image = croppedImage;
    [controller dismissViewControllerAnimated:NO completion:nil];
}
- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller
{
    [controller dismissViewControllerAnimated:NO completion:nil];
}

#pragma drawing part
- (void)renderImage{
    drawImgView.image = [self renderWholeImageView:drawImgView];
}

- (UIImage*)renderWholeImageView:(UIImageView*) imageView {
    //hide controls if needed
    CGRect rect = [imageView bounds];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imageView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - custom method
- (void)showLoupe:(NSTimer *)timer
{
    [self.magnifierView makeKeyAndVisible];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /*if (mouseSwiped) {
        if (onlyOneDraw == NO) {
            UITouch *touch = [touches anyObject];
            lastPoint = [touch locationInView:drawView];
            firstPoint = lastPoint;
            _aPath = [UIBezierPath bezierPath];
            [_aPath moveToPoint:firstPoint];
        }else if(onlyOneDraw == YES){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:@"You can only select one item." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }else{
        NSLog(@"no touch---");
    }*/
    
    if (selectMagnifier == YES) {
        self.TouchTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(showLoupe:)
                                                         userInfo:nil
                                                          repeats:NO];
        
        if (self.magnifierView == nil) {
            self.magnifierView = [[CHMagnifierView alloc] init];
            self.magnifierView.viewToMagnify = self.view;
        }
        
        self.magnifierView.pointToMagnify = [[touches anyObject] locationInView:self.view];
        
    }else if (selectMagnifier == NO){
        if (mouseSwiped) {
            if (onlyOneDraw == NO) {
                UITouch *touch = [touches anyObject];
                lastPoint = [touch locationInView:drawView];
                firstPoint = lastPoint;
                _aPath = [UIBezierPath bezierPath];
                [_aPath moveToPoint:firstPoint];
            }else if(onlyOneDraw == YES){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:@"You can only select one item." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }else{
            NSLog(@"no touch---");
        }
    }
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    /*if (mouseSwiped) {
        if (onlyOneDraw == NO) {
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:drawView];
            
            UIGraphicsBeginImageContext(drawView.frame.size);
            [self.tempImageView.image drawInRect:CGRectMake(0, 0, drawView.frame.size.width, drawView.frame.size.height)];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0f );
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
            
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            [self.tempImageView setAlpha:1.0f];
            UIGraphicsEndImageContext();
            
            lastPoint = currentPoint;
            [_aPath addLineToPoint:CGPointMake(currentPoint.x, currentPoint.y)];
        }
    }*/
    if (selectMagnifier == YES) {
        if (self.magnifierView.hidden == NO) {
            self.magnifierView.pointToMagnify = [[touches anyObject] locationInView:self.view];
        }
    }else if (selectMagnifier == NO){
        if (mouseSwiped) {
            if (onlyOneDraw == NO) {
                UITouch *touch = [touches anyObject];
                CGPoint currentPoint = [touch locationInView:drawView];
                
                UIGraphicsBeginImageContext(drawView.frame.size);
                [self.tempImageView.image drawInRect:CGRectMake(0, 0, drawView.frame.size.width, drawView.frame.size.height)];
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
                CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0f );
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
                
                CGContextStrokePath(UIGraphicsGetCurrentContext());
                self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
                [self.tempImageView setAlpha:1.0f];
                UIGraphicsEndImageContext();
                
                lastPoint = currentPoint;
                [_aPath addLineToPoint:CGPointMake(currentPoint.x, currentPoint.y)];
            }
        }
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /*if (mouseSwiped) {
        if (onlyOneDraw == NO) {
            ESCache *shared = [ESCache sharedCache];
            UIGraphicsBeginImageContext(drawView.frame.size);
            [self.tempImageView.image drawInRect:CGRectMake(0, 0, drawView.frame.size.width, drawView.frame.size.height)];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), firstPoint.x, firstPoint.y);
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0f );
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
            
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
            [self.tempImageView setAlpha:1.0f];
            UIGraphicsEndImageContext();
            [_aPath moveToPoint:CGPointMake(lastPoint.x, lastPoint.y)];
            [_aPath addLineToPoint:CGPointMake(firstPoint.x, firstPoint.y)];
            
            UIGraphicsBeginImageContext(self.drawImgView.frame.size);
            [self.drawImgView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
            [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:0.7];
            
            drawImgView.image = UIGraphicsGetImageFromCurrentImageContext();
            self.tempImageView.image = nil;
            UIGraphicsEndImageContext();
            [_aPath closePath];
            shared.drawingInPath = _aPath;
            shared.selectedGalleryDrawingImage = drawImgView.image;
            shared.photoEditedTag = @"photoEdited";
            
            [self getRectFrameFromBezierPath:shared.drawingInPath];
            onlyOneDraw = YES;
        }
        
    }*/
    
    if (selectMagnifier == YES) {
        [self.touchTimer invalidate];
        [self.magnifierView setHidden:YES];
    }else if (selectMagnifier == NO){
        if (mouseSwiped) {
            if (onlyOneDraw == NO) {
                ESCache *shared = [ESCache sharedCache];
                UIGraphicsBeginImageContext(drawView.frame.size);
                [self.tempImageView.image drawInRect:CGRectMake(0, 0, drawView.frame.size.width, drawView.frame.size.height)];
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), firstPoint.x, firstPoint.y);
                CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0f );
                CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [UIColor whiteColor].CGColor);
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
                
                CGContextStrokePath(UIGraphicsGetCurrentContext());
                self.tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
                [self.tempImageView setAlpha:1.0f];
                UIGraphicsEndImageContext();
                [_aPath moveToPoint:CGPointMake(lastPoint.x, lastPoint.y)];
                [_aPath addLineToPoint:CGPointMake(firstPoint.x, firstPoint.y)];
                
                /*UIGraphicsBeginImageContext(self.drawImgView.frame.size);
                [self.drawImgView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
                [self.tempImageView.image drawInRect:CGRectMake(0, 0, self.drawView.frame.size.width, self.drawView.frame.size.height) blendMode:kCGBlendModeNormal alpha:0.7];
                
                drawImgView.image = UIGraphicsGetImageFromCurrentImageContext();
                self.tempImageView.image = nil;
                UIGraphicsEndImageContext();*/
                
                [_aPath closePath];
                shared.drawingInPath = _aPath;
                shared.selectedGalleryDrawingImage = drawImgView.image;
                shared.photoEditedTag = @"photoEdited";
                
                [self getRectFrameFromBezierPath:shared.drawingInPath];
                onlyOneDraw = YES;
            }
            
        }
    }
    
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touchTimer invalidate];
    [self.magnifierView setHidden:YES];
}

#pragma get ratioXPosition, ratioYPosition, ratioRectHeight, ratioRectWidth from BeizerPath
- (void)getRectFrameFromBezierPath:(UIBezierPath*)path{
    float originalImgViewWidth = drawImgView.frame.size.width;
    float originalImgViewHeight = drawImgView.frame.size.height;
    
    CGRect pathRect = CGPathGetPathBoundingBox(path.CGPath);
    
    float ratioX = pathRect.origin.x/originalImgViewWidth;
    float ratioY = pathRect.origin.y/originalImgViewHeight;
    float ratioWidth = pathRect.size.width/originalImgViewWidth;
    float ratioHeight = pathRect.size.height/originalImgViewHeight;
    
    NSLog(@"originalWidth--- %f", originalImgViewWidth);
    NSLog(@"originalHeight--- %f", originalImgViewHeight);
    
    NSLog(@"x--- %f", pathRect.origin.x);
    NSLog(@"y--- %f", pathRect.origin.y);
    NSLog(@"width--- %f", pathRect.size.width);
    NSLog(@"height--- %f", pathRect.size.height);
    
    NSLog(@"ratiox--- %f", ratioX);
    NSLog(@"ratioy--- %f", ratioY);
    NSLog(@"ratioWidth--- %f", ratioWidth);
    NSLog(@"ratioHeight--- %f", ratioHeight);

    ESCache *shared = [ESCache sharedCache];
    shared.ratioXPosition   = [NSString stringWithFormat:@"%f",ratioX];
    shared.ratioYPosition   = [NSString stringWithFormat:@"%f", ratioY];
    shared.ratioRectWidth   = [NSString stringWithFormat:@"%f",ratioWidth];
    shared.ratioRectHeight  = [NSString stringWithFormat:@"%f", ratioHeight];
    
    NSLog(@"sharedratiox--- %@", shared.ratioXPosition);
    NSLog(@"sharedratioy--- %@", shared.ratioYPosition);
    NSLog(@"sharedratioWidth--- %@", shared.ratioRectWidth);
    NSLog(@"sharedratioHeight--- %@", shared.ratioRectHeight);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
