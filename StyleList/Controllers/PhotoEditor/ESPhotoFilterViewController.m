//
//  ESPhotoFilterViewController.m
//  Style List
//
//  Created by 123 on 3/4/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESPhotoFilterViewController.h"

@interface ESPhotoFilterViewController (){
    BOOL showFilterTypeView;
    NSArray *filterTypeArray;
    UIImage *filteredImage;
}

@end

@implementation ESPhotoFilterViewController
@synthesize viewFilterType, lblFilterType, btnDown, tableView, imgPhotoFilter, imgOriginalPhoto;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    showFilterTypeView = NO;
    filterTypeArray = [NSArray arrayWithObjects: @"None", @"GreyScale", @"Light/Glow", nil];
    ESCache *shared = [ESCache sharedCache];
    imgOriginalPhoto.image = shared.selectedGalleryOriginalImage;
    imgOriginalPhoto.hidden = YES;
    [self applyNoneFilter];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnBackClicked:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    shared.photoEditedTag = @"";
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentPhotoEditorVC" object:nil];
}
- (IBAction)btnNextClicked:(id)sender {
    ESCache *shared = [ESCache sharedCache];
    shared.selectedGalleryOriginalImage = filteredImage;
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentEditPhotoVC" object:nil];
}
- (IBAction)btnUpDownClicked:(id)sender {
    if (showFilterTypeView == NO) {
        viewFilterType.hidden = NO;
        showFilterTypeView = YES;
        [btnDown setImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
    }else if (showFilterTypeView == YES){
        viewFilterType.hidden = YES;
        showFilterTypeView = NO;
        [btnDown setImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateNormal];
    }
}

#pragma tableview delegate method.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filterTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier] ;
   
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:16.0f];
    cell.textLabel.text=[filterTypeArray objectAtIndex:indexPath.row];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            NSLog(@"None---");
            [self applyNoneFilter];
            break;
        case 1:
            NSLog(@"GreyScale---");
            [self applyGreyScaleFilter];
            break;
        case 2:
            NSLog(@"Glow---");
            [self applyGlowFilter];
            break;
        default:
            break;
    }
    lblFilterType.text = [filterTypeArray objectAtIndex:indexPath.row];
    [viewFilterType setHidden:YES];
    showFilterTypeView = NO;
    [btnDown setImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateNormal];
}

- (void)applyNoneFilter{
    ESCache *shared = [ESCache sharedCache];
    imgPhotoFilter.image = shared.selectedGalleryOriginalImage;
    imgPhotoFilter.image = [self renderWholeImageView:imgPhotoFilter];
    UIImage *imagePart = [[UIImage alloc]init];
    imagePart = [self cropInImageView:imgPhotoFilter withBezierPath:shared.drawingInPath];
    imgPhotoFilter.image = imagePart;
    imgOriginalPhoto.image = shared.selectedGalleryOriginalImage;
    imgOriginalPhoto.hidden = NO;
    filteredImage = [[UIImage alloc]init];
    filteredImage = [self mergeFromTwoImageToOneImage];
}
- (void)applyGreyScaleFilter{
    ESCache *shared = [ESCache sharedCache];
    UIImage *imagePart = [[UIImage alloc]init];
    imgPhotoFilter.image = shared.selectedGalleryOriginalImage;
    imgPhotoFilter.image = [self renderWholeImageView:imgPhotoFilter];
    
    UIImage *greyScaleImg = [[UIImage alloc]init];
    greyScaleImg = [self convertImageToGrayScale:imgPhotoFilter.image];
    imgOriginalPhoto.image = greyScaleImg;
    
    imagePart = [self cropInImageView:imgPhotoFilter withBezierPath:shared.drawingInPath];
    imgPhotoFilter.image = imagePart;
    imgOriginalPhoto.hidden = NO;
    
    filteredImage = [[UIImage alloc]init];
    filteredImage = [self mergeFromTwoImageToOneImage];
}
- (void)applyGlowFilter{
    ESCache *shared = [ESCache sharedCache];
    
    UIImage *imgGlowFilter = [[UIImage alloc]init];
    UIColor *color = [UIColor colorWithWhite:1.0f alpha:0.3f];
    imgPhotoFilter.image = shared.selectedGalleryOriginalImage;
    imgPhotoFilter.image = 	[self renderWholeImageView:imgPhotoFilter];
    
    imgGlowFilter = [self cropInImageView:imgPhotoFilter withBezierPath:shared.drawingInPath];
    imgGlowFilter = [self glowImageFrom:imgGlowFilter withColor:color];
    imgPhotoFilter.image = imgGlowFilter;
    
    imgOriginalPhoto.image = shared.selectedGalleryOriginalImage;
    imgOriginalPhoto.hidden = NO;
    filteredImage = [[UIImage alloc]init];
    filteredImage = [self mergeFromTwoImageToOneImage];
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
#pragma crop drawing image in all image.
- (UIImage*)cropInImageView:(UIImageView*)imgView withBezierPath:(UIBezierPath *)inBezierPath{
    
    UIGraphicsEndImageContext();
    [inBezierPath closePath];
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 0.0);
   

    CGSize imageSize = imgView.image.size;
    CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [[UIScreen mainScreen] scale]);
    [inBezierPath addClip];
    [imgView.image drawInRect:imageRect];
    
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  croppedImage;
    
}

#pragma greyscale filter to uiimage
- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}
#pragma glow filter to uiimage.
-(UIImage *)glowImageFrom:(UIImage *)source withColor:(UIColor *)color{
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

#pragma merge from Two image to one image.
- (UIImage*)mergeFromTwoImageToOneImage {
    
    UIGraphicsBeginImageContext(imgOriginalPhoto.frame.size);
    
    [imgOriginalPhoto.layer renderInContext:UIGraphicsGetCurrentContext()];
    [imgPhotoFilter.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end

