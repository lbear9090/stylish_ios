//
//  ESEditPhotoViewController.m
//  Style List
//
//  Created by 123 on 4/11/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#define BACK_BTN_TAG    10
#define NEXT_BTN_TAG    11
#define CANCEL_BTN_TAG  20
#define PUBLISH_BTN_TAG 21

#import "ESEditPhotoViewController.h"
#import "UIImage+Trim.h"

@interface ESEditPhotoViewController ()

@end

@implementation ESEditPhotoViewController{
    BOOL    selectBtnDownFlag;
    NSArray *hashTagArray;
    CGSize trimmedSize;
    CGFloat off_height;
    __weak IBOutlet UILabel *lblInstruction;
}

@synthesize btnDown,btnCancel, btnPublish;
@synthesize lblItemTagName;
@synthesize txtSaleType, txtComment, txtItemTagName, txtCommentForPublish;
@synthesize viewSaleType, viewComment, viewItemTagName, viewCommentForPublish;
@synthesize photoImageView, tblSaleType;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    selectBtnDownFlag = NO;
    hashTagArray      = [NSArray arrayWithObjects:@"For Inspiration", @"For Sale", @"For Hire", nil];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];*/
    
    ESCache *shared = [ESCache sharedCache];
    if ([shared.photoEditedTag isEqualToString:@"photoEdited"]) {
        NSLog(@"photo Edited ---- *****");
        [btnCancel setTitle:@"Back" forState:UIControlStateNormal];
        [btnPublish setTitle:@"Next" forState:UIControlStateNormal];
        btnCancel.tag = BACK_BTN_TAG;
        btnPublish.tag = NEXT_BTN_TAG;
        viewCommentForPublish.hidden = YES;
        lblItemTagName.hidden        = NO;
        lblInstruction.hidden = NO;
    }else{
        NSLog(@"photo don't Edited ---- *****");
        [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [btnPublish setTitle:@"Publish" forState:UIControlStateNormal];
        btnCancel.tag = CANCEL_BTN_TAG;
        btnPublish.tag = PUBLISH_BTN_TAG;
        viewSaleType.hidden = YES;
        viewComment.hidden  = YES;
        viewItemTagName.hidden = YES;
        viewCommentForPublish.hidden = NO;
        lblItemTagName.hidden        = YES;
        lblInstruction.hidden = YES;
        [viewItemTagName setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f]];
         [viewComment setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f]];
         [viewSaleType setBackgroundColor:[UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f]];
    }
//    [self hiddenViews];
    //========= set photo ===========//
    self.image = shared.selectedGalleryOriginalImage;
    shared.postingPhotoImg = shared.selectedGalleryOriginalImage;
    photoImageView.image = self.image;
    //.//================================
    UIImage *newImg = [self.image imageByTrimmingTransparentPixels];
    trimmedSize = [self sizeOfImage:newImg inAspectFitImageView:photoImageView];
    off_height = (photoImageView.frame.size.height - trimmedSize.height) / 2;
    //========= enable touch delivery======//
    lblItemTagName.userInteractionEnabled = YES;
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(labelDragged:)];
    [lblItemTagName addGestureRecognizer:gesture];
    //========= fit image ===========//
   [self shouldUploadImage:self.image];
}

- (void)hiddenViews{
    [viewComment setHidden:YES];
    [viewItemTagName setHidden:YES];
    [viewCommentForPublish setHidden:YES];
}

- (IBAction)btnCancelClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == BACK_BTN_TAG) {
        [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentBeforePhotoFilterVC" object:nil];
    }else if (btn.tag == CANCEL_BTN_TAG){
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}
- (IBAction)btnDoneClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    ESCache *shared = [ESCache sharedCache];
    if (btn.tag == NEXT_BTN_TAG) {
        
        shared.currentUserComment = [txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        shared.selectSaleHireType = txtSaleType.text;
        shared.selectItemTitle    = lblItemTagName.text;
        if ([shared.selectSaleHireType isEqualToString:@""] || [shared.selectSaleHireType isEqualToString:@"Your current item"]) {
            [self displayErrorMessage];
        }else{
            [self.parentViewController dismissViewControllerAnimated:NO completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentESHireVC" object:nil];
        }
    }else if (btn.tag == PUBLISH_BTN_TAG){
        [self publishPhoto];
    }
   
    
}
- (IBAction)btnUpDownClicked:(id)sender {
    if (selectBtnDownFlag == NO) {
        selectBtnDownFlag = YES;
        [self.btnDown setImage:[UIImage imageNamed:@"btn_up.png"] forState:UIControlStateNormal];
        [tblSaleType setHidden:NO];
    }else if(selectBtnDownFlag == YES){
        selectBtnDownFlag = NO;
        [self.btnDown setImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateNormal];
        [tblSaleType setHidden:YES];
    }
}

#pragma photo publish
- (void)publishPhoto{
    NSDictionary *userInfo = [NSDictionary dictionary];
    NSString *trimmedComment = @"";
    trimmedComment = [txtCommentForPublish.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    /*ESCache *shared = [ESCache sharedCache];
    if ([shared.photoEditedTag isEqualToString:@"photoEdited"]) {
        trimmedComment = [txtComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }else{
         trimmedComment = [txtCommentForPublish.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }*/
    
    if (trimmedComment.length != 0) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    trimmedComment,kESEditPhotoViewControllerUserInfoCommentKey,
                    nil];
    }
    
    // Make sure there were no errors creating the image files
    if (!self.photoFile || !self.thumbnailFile) {
        [PXAlertView showAlertWithTitle:nil
                                message:NSLocalizedString(@"Couldn't post your photo, a network error occurred.", nil)
                            cancelTitle:@"OK"
                             completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                 if (cancelled) {
                                     NSLog(@"Simple Alert View cancelled");
                                 } else {
                                     NSLog(@"Simple Alert View dismissed, but not cancelled");
                                 }
                             }];
        return;
    }
    
    // both files have finished uploading
    
    // create a photo object
    ESCache * shared = [ESCache sharedCache];
    PFObject *photo = [PFObject objectWithClassName:kESPhotoClassKey];
    [photo setObject:[PFUser currentUser] forKey:kESPhotoUserKey];
    [photo setObject:self.photoFile forKey:kESPhotoPictureKey];
    [photo setObject:self.thumbnailFile forKey:kESPhotoThumbnailKey];
    [photo setObject:shared.selectedUserStyleTagNames forKey:kESPhotoStyleTags];
    if (localityString && [[[PFUser currentUser] objectForKey:@"locationServices"] isEqualToString:@"YES"]) {
        [photo setObject:localityString forKey:kESPhotoLocationKey];
    }
    
    // photos are public, but may only be modified by the user who uploaded them
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    [photoACL setPublicWriteAccess:YES]; // forUser:[PFUser currentUser]];
    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Save the Photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[ESCache sharedCache] setAttributesForPhoto:photo likers:[NSArray array] commenters:[NSArray array] likedByCurrentUser:NO];
            
            if ([[[[PFUser currentUser] objectForKey:@"verified"] lowercaseString] isEqualToString:@"yes"]) {
                PFObject *sponsored = [PFObject objectWithClassName:@"Sponsored"];
                [sponsored setObject:self.photoFile forKey:kESPhotoPictureKey];
                [sponsored setObject:self.thumbnailFile forKey:kESPhotoThumbnailKey];
                [sponsored setObject:[PFUser currentUser] forKey:kESPhotoUserKey];
                [sponsored saveInBackground];
            }
            
            // userInfo might contain any caption which might have been posted by the uploader
            if (userInfo) {
                NSString *commentText = [userInfo objectForKey:kESEditPhotoViewControllerUserInfoCommentKey];
                
                if (commentText && commentText.length != 0) {
                    // create and save photo caption
                    NSRegularExpression *_regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:nil];
                    NSArray *_matches = [_regex matchesInString:trimmedComment options:0 range:NSMakeRange(0, trimmedComment.length)];
                    NSMutableArray *hashtagsArray = [[NSMutableArray alloc]init];
                    for (NSTextCheckingResult *match in _matches) {
                        NSRange wordRange = [match rangeAtIndex:1];
                        NSString* word = [trimmedComment substringWithRange:wordRange];
                        [hashtagsArray addObject:[word lowercaseString]];
                    }
                    
                    PFObject *comment = [PFObject objectWithClassName:kESActivityClassKey];
                    if ([photo objectForKey:kESVideoFileKey]) {
                        [comment setObject:kESActivityTypeCommentVideo forKey:kESActivityTypeKey];
                    } else if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"]) {
                        [comment setObject:kESActivityTypeCommentPost forKey:kESActivityTypeKey];
                    }
                    else [comment setObject:kESActivityTypeCommentPhoto forKey:kESActivityTypeKey];
                    [comment setObject:photo forKey:kESActivityPhotoKey];
                    [comment setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
                    [comment setObject:[PFUser currentUser] forKey:kESActivityToUserKey];
                    [comment setObject:commentText forKey:kESActivityContentKey];
                    if (hashtagsArray.count > 0) {
                        [comment setObject:hashtagsArray forKey:@"hashtags"];
                        
                        for (int i = 0; i < hashtagsArray.count; i++) {
                            NSString *hash = [[hashtagsArray objectAtIndex:i] lowercaseString];
                            PFQuery *hashQuery = [PFQuery queryWithClassName:@"Hashtags"];
                            [hashQuery whereKey:@"hashtag" equalTo:hash];
                            [hashQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if (!error) {
                                    if (objects.count == 0) {
                                        PFObject *hashtag = [PFObject objectWithClassName:@"Hashtags"];
                                        [hashtag setObject:hash forKey:@"hashtag"];
                                        [hashtag saveInBackground];
                                    }
                                }
                            }];
                        }
                    }
                    
                    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
                    [ACL setPublicReadAccess:YES];
                    [ACL setWriteAccess:YES forUser:[PFUser currentUser]];
                    comment.ACL = ACL;
                    
                    [comment saveInBackgroundWithBlock:^(BOOL result, NSError *error){
                        if (error) {
                            [comment saveEventually];
                        }
                    }];
                    [[ESCache sharedCache] incrementCommentCountForPhoto:photo];
                    
                    PFObject *mention = [PFObject objectWithClassName:kESActivityClassKey];
                    [mention setObject:[PFUser currentUser] forKey:kESActivityFromUserKey]; // Set fromUser
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:nil];
                    NSArray *matches = [regex matchesInString:trimmedComment options:0 range:NSMakeRange(0, trimmedComment.length)];
                    NSMutableArray *mentionsArray = [[NSMutableArray alloc]init];
                    for (NSTextCheckingResult *match in matches) {
                        NSRange wordRange = [match rangeAtIndex:1];
                        NSString* word = [trimmedComment substringWithRange:wordRange];
                        [mentionsArray addObject:[word lowercaseString]];
                        
                        
                    }
                    if (mentionsArray.count > 0 ) {
                        PFUser *user = [PFUser currentUser];
                        
                        PFQuery *query1 = [PFQuery queryWithClassName:kESBlockedClassName];
                        [query1 whereKey:kESBlockedUser1 equalTo:user];
                        
                        PFQuery *mentionQuery = [PFUser query];
                        [mentionQuery whereKey:kESUserObjectIdKey doesNotMatchKey:kESBlockedUserID2 inQuery:query1];
                        [mentionQuery whereKey:@"usernameFix" containedIn:mentionsArray];
                        [mentionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                [mention setObject:objects forKey:@"mentions"]; // Set toUser
                                [mention setObject:kESActivityTypeMention forKey:kESActivityTypeKey];
                                [mention setObject:photo forKey:kESActivityPhotoKey];
                                [mention saveInBackgroundWithBlock:^(BOOL result, NSError *error){
                                    if (error) {
                                        [mention saveEventually];
                                    }
                                }];
                            }
                        }];
                    }
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ESTabBarControllerDidFinishEditingPhotoNotification object:photo];
        } else {
            [PXAlertView showAlertWithTitle:nil
                                    message:NSLocalizedString(@"Couldn't post your photo, a network error occurred.", nil)
                                cancelTitle:@"OK"
                                 completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                     if (cancelled) {
                                         NSLog(@"Simple Alert View cancelled");
                                     } else {
                                         NSLog(@"Simple Alert View dismissed, but not cancelled");
                                     }
                                 }];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Dismiss this screen
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize) sizeOfImage:(UIImage*)image inAspectFitImageView:(UIImageView*)imageView
{
    CGFloat imageViewWidth = imageView.bounds.size.width;
    CGFloat imageViewHeight = imageView.bounds.size.height;
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGFloat scaleFactor = MIN(imageViewWidth / imageWidth, imageViewHeight / imageHeight);
    
    return CGSizeMake(image.size.width*scaleFactor, image.size.height*scaleFactor);
}

#pragma label dragging
- (void)labelDragged:(UIPanGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    CGPoint translation = [gesture translationInView:label];
    CGPoint trans = [gesture locationInView:photoImageView];
    if ( (trans.y < off_height) || (trans.y > photoImageView.frame.size.height - off_height)) {
        NSLog(@"position out!!!");
        return;
    }
    // move label
    label.center = CGPointMake(label.center.x + translation.x,
                               label.center.y + translation.y);
    
    // reset translation
    [gesture setTranslation:CGPointZero inView:label];
    
//    NSString *strXEdgePosition = [NSString stringWithFormat:@"%f",label.frame.origin.x];
//    NSString *strYEdgePosition = [NSString stringWithFormat:@"%f",label.frame.origin.y];
    
    float originImgViewWidth = photoImageView.frame.size.width;
    float originImgViewHeight = photoImageView.frame.size.height;
    
    float ratioEdgeX = label.frame.origin.x/originImgViewWidth;
    float ratioEdgeY = label.frame.origin.y/originImgViewHeight;
    
    ESCache *shared = [ESCache sharedCache];
    shared.ratioItemViewXPosition   = [NSString stringWithFormat:@"%f",ratioEdgeX];
    shared.ratioItemViewYPosition   = [NSString stringWithFormat:@"%f", ratioEdgeY];
//    NSLog(@"photoImageViewWidth --- %f", originImgViewWidth);
//    NSLog(@"photoImageViewHeight --- %f", originImgViewHeight);
//    NSLog(@"xedgepoistion --- %@", strXEdgePosition);
//    NSLog(@"yedgepoistion --- %@", strYEdgePosition);
//    NSLog(@"ratioXedgepoistion --- %@", shared.ratioItemViewXPosition);
//    NSLog(@"ratioYedgepoistion --- %@", shared.ratioItemViewYPosition);
}

#pragma tableview delegate method.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [hashTagArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier] ;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[hashTagArray objectAtIndex:indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    txtSaleType.text = [hashTagArray objectAtIndex:indexPath.row];
    [tblSaleType setHidden:YES];
    selectBtnDownFlag = NO;
    [self.btnDown setImage:[UIImage imageNamed:@"btn_down.png"] forState:UIControlStateNormal];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtSaleType resignFirstResponder];
    [txtComment resignFirstResponder];
    [txtItemTagName resignFirstResponder];
    [txtCommentForPublish resignFirstResponder];
    if(textField == txtItemTagName){
        lblItemTagName.text = txtItemTagName.text;
    }else{
       
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSString *strItemName = txtItemTagName.text;
    if ([strItemName isEqualToString:@""]) {
        lblItemTagName.text = @"Your Current Item";
    }else{
        lblItemTagName.text = txtItemTagName.text;
    }
    
    [txtSaleType resignFirstResponder];
    [txtComment resignFirstResponder];
    [txtItemTagName resignFirstResponder];
    [txtCommentForPublish resignFirstResponder];
}

#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [anImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:42.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    return YES;
}


- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height += keyboardFrameEnd.size.height;
    [self.scrollView setContentSize:scrollViewContentSize];
    
    CGPoint scrollViewContentOffset = self.scrollView.contentOffset;
    // Align the bottom edge of the photo with the keyboard
    scrollViewContentOffset.y = scrollViewContentOffset.y + keyboardFrameEnd.size.height*3.0f - [UIScreen mainScreen].bounds.size.height;
    
    [self.scrollView setContentOffset:scrollViewContentOffset animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGRect keyboardFrameEnd = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize scrollViewContentSize = self.scrollView.bounds.size;
    scrollViewContentSize.height -= keyboardFrameEnd.size.height;
    [UIView animateWithDuration:0.200f animations:^{
        [self.scrollView setContentSize:scrollViewContentSize];
    }];
}

#pragma display error message.
- (void)displayErrorMessage{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:@"Please input sale type."
                                                      delegate:self cancelButtonTitle:@"Ok"
                                             otherButtonTitles:@"Cancel", nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
