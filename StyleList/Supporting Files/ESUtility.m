//
//  ESUtility.m


#import "ESUtility.h"
#import "UIImage+ResizeAdditions.h"
#import "SCLAlertView.h"
#import <AVFoundation/AVFoundation.h>
#import "IQAudioRecorderController.h"
#import "SCLAlertView.h"

@implementation ESUtility


#pragma mark - ESUtility

# pragma mark - Blocking users

+ (void)blockUser:(PFUser *)user2
{
    PFUser *user1 = [PFUser currentUser];
    [self blockUserOne:user1 withUser:user2];
    [self blockUserOne:user2 withUser:user1];
    
    [self deleteChatBetweenUser:user1 andUser:user2];
    
    [self unfollowUserEventually:user2];
    [self letUser:user2 unfollowMeEventually:user1];
    
    
}

+ (void)blockUserOne:(PFUser *)user1 withUser:(PFUser *)user2
{
    PFQuery *query = [PFQuery queryWithClassName:kESBlockedClassName];
    [query whereKey:kESBlockedUser equalTo:[PFUser currentUser]];
    [query whereKey:kESBlockedUser1 equalTo:user1];
    [query whereKey:kESBlockedUser2 equalTo:user2];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             if ([objects count] == 0)
             {
                 PFObject *object = [PFObject objectWithClassName:kESBlockedClassName];
                 object[kESBlockedUser] = [PFUser currentUser];
                 object[kESBlockedUser1] = user1;
                 object[kESBlockedUser2] = user2;
                 object[kESBlockedUserID2] = user2.objectId;
                 //[object setACL:[PFACL ACLWithUser:[PFUser currentUser]]];
                 [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"BlockUserOne save error.");
                  }];
             }
         }
         else NSLog(@"BlockUserOne query error.");
     }];
}

+ (void)unblockUser:(PFUser *)user2
{
    PFUser *user1 = [PFUser currentUser];
    [self unblockUserOne:user1 withUser:user2];
    [self unblockUserOne:user2 withUser:user1];
}

+ (void)unblockUserOne:(PFUser *)user1 withUser:(PFUser *)user2
{
    PFQuery *query = [PFQuery queryWithClassName:kESBlockedClassName];
    [query whereKey:kESBlockedUser equalTo:[PFUser currentUser]];
    [query whereKey:kESBlockedUser1 equalTo:user1];
    [query whereKey:kESBlockedUser2 equalTo:user2];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *blocked in objects)
             {
                 [blocked deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"UnblockUserOne delete error.");
                  }];
             }
         }
         else NSLog(@"UnblockUserOne query error.");
     }];
}


#pragma mark Like Photos

+ (void)likePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryExistingLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePhoto];
    [queryExistingLikes whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setLimit:1000];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kESActivityClassKey];
        [likeActivity setObject:kESActivityTypeLikePhoto forKey:kESActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kESPhotoUserKey] forKey:kESActivityToUserKey];
        [likeActivity setObject:photo forKey:kESActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kESPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
                NSLog(@"Completion block succeeded");
            }
            
            // refresh cache
            PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query whereKeyDoesNotExist:@"noneread"];
            if ([photo objectForKey:kESVideoFileKey]) {
                query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"])
            {
                query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto] && [activity objectForKey:kESActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                        } else if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPhoto] && [activity objectForKey:kESActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    
}
+ (void)likePostInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryExistingLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryExistingLikes setLimit:1000];
    [queryExistingLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePost];
    [queryExistingLikes whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kESActivityClassKey];
        [likeActivity setObject:kESActivityTypeLikePost forKey:kESActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kESPhotoUserKey] forKey:kESActivityToUserKey];
        [likeActivity setObject:photo forKey:kESActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kESPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
                NSLog(@"Completion block succeeded");
            }
            
            // refresh cache
            PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query whereKeyDoesNotExist:@"noneread"];
            if ([photo objectForKey:kESVideoFileKey]) {
                query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"])
            {
                query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost] && [activity objectForKey:kESActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                        } else if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPost] && [activity objectForKey:kESActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    
}
+ (void)likeVideoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryExistingLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikeVideo];
    [queryExistingLikes whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setLimit:1000];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
        }
        
        // proceed to creating new like
        PFObject *likeActivity = [PFObject objectWithClassName:kESActivityClassKey];
        [likeActivity setObject:kESActivityTypeLikeVideo forKey:kESActivityTypeKey];
        [likeActivity setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
        [likeActivity setObject:[photo objectForKey:kESPhotoUserKey] forKey:kESActivityToUserKey];
        [likeActivity setObject:photo forKey:kESActivityPhotoKey];
        
        PFACL *likeACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [likeACL setPublicReadAccess:YES];
        [likeACL setWriteAccess:YES forUser:[photo objectForKey:kESPhotoUserKey]];
        likeActivity.ACL = likeACL;
        
        [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (completionBlock) {
                completionBlock(succeeded,error);
                NSLog(@"Completion block succeeded");
            }
            
            // refresh cache
            PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query whereKeyDoesNotExist:@"noneread"];
            if ([photo objectForKey:kESVideoFileKey]) {
                query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"])
            {
                query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo] && [activity objectForKey:kESActivityFromUserKey]) {
                            [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                        } else if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPhoto] && [activity objectForKey:kESActivityFromUserKey]) {
                            [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:succeeded] forKey:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        }];
    }];
    
}

+ (void)unlikePhotoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryExistingLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePhoto];
    [queryExistingLikes whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes setLimit:1000];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query whereKeyDoesNotExist:@"noneread"];
            if ([photo objectForKey:kESVideoFileKey]) {
                query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"text"])
            {
                query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto]) {
                            [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                        } else if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPhoto]) {
                            [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePhoto]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}
+ (void)unlikePostInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryExistingLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePost];
    [queryExistingLikes whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes setLimit:1000];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query whereKeyDoesNotExist:@"noneread"];
            
            if ([photo objectForKey:kESVideoFileKey]) {
                query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"])
            {
                query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost]) {
                            [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                        } else if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPost]) {
                            [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikePost]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}

+ (void)unlikeVideoInBackground:(id)photo block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    PFQuery *queryExistingLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryExistingLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryExistingLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikeVideo];
    [queryExistingLikes whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [queryExistingLikes setCachePolicy:kPFCachePolicyNetworkOnly];
    [queryExistingLikes setLimit:1000];
    [queryExistingLikes findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        if (!error) {
            for (PFObject *activity in activities) {
                [activity delete];
            }
            
            if (completionBlock) {
                completionBlock(YES,nil);
            }
            
            // refresh cache
            PFQuery *query = [ESUtility queryForActivitiesOnPhoto:photo cachePolicy:kPFCachePolicyNetworkOnly];
            [query whereKeyDoesNotExist:@"noneread"];
            if ([photo objectForKey:kESVideoFileKey]) {
                query = [ESUtility queryForActivitiesOnVideo:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            if ([[photo objectForKey:@"type"] isEqualToString:@"text"] || [[photo objectForKey:@"type"] isEqualToString:@"retweet"])
            {
                query = [ESUtility queryForActivitiesOnPost:photo cachePolicy:kPFCachePolicyNetworkOnly];
            }
            [query setLimit:1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    
                    NSMutableArray *likers = [NSMutableArray array];
                    NSMutableArray *commenters = [NSMutableArray array];
                    
                    BOOL isLikedByCurrentUser = NO;
                    
                    for (PFObject *activity in objects) {
                        if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo]) {
                            [likers addObject:[activity objectForKey:kESActivityFromUserKey]];
                        } else if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeCommentPhoto]) {
                            [commenters addObject:[activity objectForKey:kESActivityFromUserKey]];
                        }
                        
                        if ([[[activity objectForKey:kESActivityFromUserKey] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                            if ([[activity objectForKey:kESActivityTypeKey] isEqualToString:kESActivityTypeLikeVideo]) {
                                isLikedByCurrentUser = YES;
                            }
                        }
                    }
                    
                    [[ESCache sharedCache] setAttributesForPhoto:photo likers:likers commenters:commenters likedByCurrentUser:isLikedByCurrentUser];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:ESUtilityUserLikedUnlikedPhotoCallbackFinishedNotification object:photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:ESPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey]];
            }];
            
        } else {
            if (completionBlock) {
                completionBlock(NO,error);
            }
        }
    }];
}
#pragma mark Facebook

+ (void)processProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        NSLog(@"ESUtility: No picture data");
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            NSLog(@"ESUtility: OldProfile matches NewProfile");
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:86 transparentBorder:0 cornerRadius:42 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kESUserProfilePicMediumKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
        NSLog(@"ESUtility: Uploaded medium Image");
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kESUserProfilePicSmallKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
        NSLog(@"ESUtility: Uploaded small Image");
    }
    
    NSLog(@"ESUtility: Uplpoaded pictures to Parse");
}
+ (void)processHeaderPhotoWithData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        NSLog(@"ESUtility: No picture data");
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            NSLog(@"ESUtility: OldProfile matches NewProfile");
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:86 transparentBorder:0 cornerRadius:42 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    if (mediumImageData.length > 0) {
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileMediumImage forKey:kESUserHeaderPicMediumKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
        NSLog(@"ESUtility: Uploaded medium Image");
    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kESUserHeaderPicSmallKey];
                [[PFUser currentUser] saveEventually];
            }
        }];
        NSLog(@"ESUtility: Uploaded small Image");
    }
    
    NSLog(@"ESUtility: Uploaded pictures to Parse");
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kESUserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureMedium = [user objectForKey:kESUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kESUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kESActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
    [followActivity setObject:user forKey:kESActivityToUserKey];
    [followActivity setObject:kESActivityTypeFollow forKey:kESActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    [followACL setPublicWriteAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[ESCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:kESActivityClassKey];
    [followActivity setObject:[PFUser currentUser] forKey:kESActivityFromUserKey];
    [followActivity setObject:user forKey:kESActivityToUserKey];
    [followActivity setObject:kESActivityTypeFollow forKey:kESActivityTypeKey];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    [followACL setPublicWriteAccess:YES];
    
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[ESCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [ESUtility followUserEventually:user block:completionBlock];
        [[ESCache sharedCache] setFollowStatus:YES user:user];
    }
}

+ (void)letUser:(PFUser *)user unfollowMeEventually:(PFUser *)me {
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityToUserKey equalTo:me];
    [query whereKey:kESActivityFromUserKey equalTo:user];
    [query whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
}
+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kESActivityToUserKey equalTo:user];
    [query whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[ESCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:kESActivityClassKey];
    [query whereKey:kESActivityFromUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kESActivityToUserKey containedIn:users];
    [query whereKey:kESActivityTypeKey equalTo:kESActivityTypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[ESCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnPhoto:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePhoto];
    //[queryLikes setLimit:1000];

    PFQuery *queryComments = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryComments whereKey:kESActivityPhotoKey equalTo:photo];
    [queryComments whereKeyDoesNotExist:@"noneread"];
    //[queryComments setLimit:1000];

    [queryComments whereKey:kESActivityTypeKey equalTo:kESActivityTypeCommentPhoto];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query setLimit:1000];
    [query includeKey:kESActivityFromUserKey];
    [query includeKey:kESActivityPhotoKey];
    
    return query;
}
+ (PFQuery *)queryForActivitiesOnVideo:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryLikes whereKey:kESActivityPhotoKey equalTo:photo];
    [queryLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikeVideo];
//    [queryLikes setLimit:1000];

    PFQuery *queryComments = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryComments whereKey:kESActivityPhotoKey equalTo:photo];
    [queryComments whereKey:kESActivityTypeKey equalTo:kESActivityTypeCommentVideo];
    [queryComments whereKeyDoesNotExist:@"noneread"];
//    [queryComments setLimit:1000];

    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query setLimit:1000];
    [query includeKey:kESActivityFromUserKey];
    [query includeKey:kESActivityPhotoKey];
    
    return query;
}
+ (PFQuery *)queryForActivitiesOnPost:(PFObject *)photo cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *queryLikes = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryLikes whereKey:kESActivityPhotoKey equalTo:photo];
//    [queryLikes setLimit:1000];
    [queryLikes whereKey:kESActivityTypeKey equalTo:kESActivityTypeLikePost];
    
    PFQuery *queryComments = [PFQuery queryWithClassName:kESActivityClassKey];
    [queryComments whereKey:kESActivityPhotoKey equalTo:photo];
    [queryComments whereKey:kESActivityTypeKey equalTo:kESActivityTypeCommentPost];
//    [queryComments setLimit:1000];
    [queryComments whereKeyDoesNotExist:@"noneread"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryLikes,queryComments,nil]];
    [query setCachePolicy:cachePolicy];
    [query setLimit:1000];
    [query includeKey:kESActivityFromUserKey];
    [query includeKey:kESActivityPhotoKey];
    
    return query;
}

#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 3.0f)];
    [gradientView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    navigationController.navigationBar.clipsToBounds = NO;
    [navigationController.navigationBar addSubview:gradientView];
}
+ (void)reportUser:(int)i withUser:(PFUser *)user andObject:(PFObject *)_object{
    PFObject *object = [PFObject objectWithClassName:@"Report"];
    [object setObject:user forKey:@"ReportedUser"];
    [object setObject:_object forKey:@"ReportedObject"];
    
    if (i == 0) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Sexual", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 1) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Offensive", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 2) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Spam", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    else if (i == 3) {
        NSString *reason = [NSString stringWithFormat:NSLocalizedString(@"Other", nil)];
        [object setObject:reason forKey:@"Reason"];
    }
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
    }];
    
    
}

#pragma mark - delete chat

+ (void)deleteChatBetweenUser:(PFUser *)user1 andUser:(PFUser *)user2 {
    NSString *id1 = user1.objectId;
    NSString *id2 = user2.objectId;
    NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
    
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             [snapshot.ref removeValue];
         }
     }];
    
}

#pragma mark - push methods

+ (void)deliverPushTo:(NSString *)groupId withText:(NSString *)text {
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             NSArray *recents = [snapshot.value allValues];
             NSDictionary *recent = [recents firstObject];
             if (recent != nil)
             {
                 PFUser *user = [PFUser currentUser];
                 NSString *message = [NSString stringWithFormat:@"%@: %@", user[kESUserDisplayNameKey], text];
                 /*
                  PFQuery *userQuery = [PFUser query];
                  [userQuery whereKey:@"objectId" containedIn:recent[@"members"]];
                  
                  PFQuery *pushQuery = [PFInstallation query];
                  [pushQuery whereKey:@"user" matchesQuery: userQuery];
                  
                  // Send push notification to query
                  PFPush *push = [[PFPush alloc] init];
                  [push setQuery:pushQuery]; // Set our Installation query
                  [push setMessage:message];
                  [push sendPushInBackground];
                  
                  */
                 [PFCloud callFunctionInBackground:@"sendPushToUser"
                                    withParameters:@{@"members": recent[@"members"], @"message": message}
                                             block:^(NSString *success, NSError *error) {
                                                 if (!error) {
                                                     NSLog(@"Push error: %@",error);
                                                 }
                                             }];
                 /*
                  
                  //Old way of sending pushes ... keeping it for good here - one never knows...
                  PFQuery *query = [PFQuery queryWithClassName:kESUserClassNameKey];
                  [query whereKey:kESUserObjectIdKey containedIn:recent[@"members"]];
                  [query whereKey:kESUserObjectIdKey notEqualTo:user.objectId];
                  [query setLimit:1000];
                  
                  PFQuery *queryInstallation = [PFInstallation query];
                  [queryInstallation whereKey:kESInstallationUserKey matchesQuery:query];
                  
                  PFPush *push = [[PFPush alloc] init];
                  [push setQuery:queryInstallation];
                  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                  message, @"alert",
                  @"Increment", @"badge",
                  @"homerun.caf", @"sound",
                  @"m", @"p",
                  nil];
                  [push setData:data];
                  [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                  if (succeeded) NSLog(@"SendPushNotification send succeeded.");
                  
                  if (error != nil)
                  {
                  NSLog(@"SendPushNotification send error.");
                  }
                  }];
                  
                  */
             }
         }
     }];
    
    
    
}

#pragma mark - message methods

+ (NSString *)createConversation:(NSMutableArray *)users
{
    NSString *groupId = @"";
    NSString *description = @"";
    [users addObject:[PFUser currentUser]];
    
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (PFUser *user in users) {
        [userIds addObject:user.objectId];
    }
    if ([users count] == 2) {
        PFUser *user1 = [users objectAtIndex:0];
        PFUser *user2 = [users objectAtIndex:1];
        NSString *id1 = user1.objectId;
        NSString *id2 = user2.objectId;
        NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
        NSLog(@"Create conversation item with user %@, groupId %@, userIds: %@", user1.objectId, groupId, userIds);
        FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
        FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
        [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
         {
             [firebase removeAllObservers];
             BOOL create1 = YES;
             BOOL create2 = YES;
             if (snapshot.value != [NSNull null])
             {
                 NSLog(@"snapshot: %@", snapshot.value);
                 for (NSDictionary *recent in [snapshot.value allValues])
                 {
                     if ([recent[@"userId"] isEqualToString:id1]) create1 = NO;
                     if ([recent[@"userId"] isEqualToString:id1]) create2 = NO;
                 }
             }
             if (create1) [self createConversationItemWitUser:user1 groupId:groupId members:userIds andDescription:[user2 objectForKey:kESUserDisplayNameKey]];
             if (create2) [self createConversationItemWitUser:user2 groupId:groupId members:userIds andDescription:[user1 objectForKey:kESUserDisplayNameKey]];
         }];
        
        return groupId;
    }
    NSArray *sorted = [userIds sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *userId in sorted) {
        groupId = [groupId stringByAppendingString:userId];
    }
    for (PFUser *user in users) {
        if ([description length] != 0) description = [description stringByAppendingString:@" & "];
        description = [description stringByAppendingString:user[kESUserDisplayNameKey]];
    }
    for (PFUser *user in users) {
        FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
        FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
        [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
         {
             [firebase removeAllObservers];
             if (snapshot.value != [NSNull null])
             {
                 //NSLog(@"snapshot: %@", snapshot.value);
                 for (NSDictionary *recent in [snapshot.value allValues])
                 {
                     if ([recent[@"userId"] isEqualToString:user.objectId]) [self createConversationItemWitUser:user groupId:groupId members:userIds andDescription:description];
                 }
             }
         }];
    }
    return groupId;
    
}

+ (void) recreateConversation:(NSString *)groupID
{
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];
    int len=0;
    while( (len+10)<[groupID length]) {
        NSString *objid = [groupID substringWithRange:NSMakeRange(len,10)];
        [userIDs addObject:objid];
        len+=10;
    }
    if (len%10 == 0) {
        [userIDs addObject:[groupID substringFromIndex:len]];
    }
    [userIDs removeObject:[[PFUser currentUser] objectId]];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:kESUserObjectIdKey containedIn:userIDs];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSMutableArray *mutableCopy = [[NSMutableArray alloc] initWithArray:objects];
            NSString *trueGroupId = [self createConversation:mutableCopy];
            NSLog(@"Comparing group ID %@ and true ID %@", groupID, trueGroupId);
        }
        else {
            NSLog(@"Error fetching users: %@",error);
        }
    }];
}

+ (void)createConversationItemWitUser:(PFUser *)user groupId:(NSString *)groupId members:(NSArray *)members andDescription:(NSString *)description
{
    
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         [firebase removeAllObservers];
//         BOOL create = YES;
//         if (snapshot.value != [NSNull null])
//         {
//             NSLog(@"snapshot: %@", snapshot.value);
//             for (NSDictionary *recent in [snapshot.value allValues])
//             {
//                 if ([recent[@"userId"] isEqualToString:user.objectId]) create = NO;
//             }
//         }
//         if (create) {
             FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
             FIRDatabaseReference *reference = [firebase childByAutoId];
             NSString *recentId = reference.key;
             PFUser *lastUser = [PFUser currentUser];
             NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
             [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
             [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
             NSString *date = [formatter stringFromDate:[NSDate date]];
             NSDictionary *recent = @{@"recentId":recentId, @"userId":user.objectId, @"groupId":groupId, @"members":members, @"description":description,
                                      @"lastUser":lastUser.objectId, @"lastMessage":@"", @"counter":@0, @"date":date};
             NSLog(@"Utility: creating new conversation with infos:%@", recent);
             [reference setValue:recent withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
              {
                  if (error != nil) NSLog(@"createConversation save error: %@",error);
                  else NSLog(@"Successfully created the new conversation with all info");
              }];
//         }
     }];
}
+ (void)clearUnreadMessagesCounterFor:(NSString *)groupId {
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             PFUser *user = [PFUser currentUser];
             for (NSDictionary *recent in [snapshot.value allValues])
             {
                 if ([recent[@"userId"] isEqualToString:user.objectId])
                 {
                     FIRDatabaseReference *firebase = [[[[FIRDatabase database] reference] child:@"Conversations"] child:[NSString stringWithFormat:@"%@", recent[@"recentId"]]];
                     [firebase updateChildValues:@{@"counter":@0} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
                      {
                          if (error != nil) NSLog(@"clearUnread save error.");
                      }];
                 }
             }
         }
     }];
}

+ (void)resetUnreadMessagesCounterFor:(NSString *)groupId withCounter:(NSInteger)amount andLastMessage:(NSString *)lastMessage {
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType :FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             for (NSDictionary *recent in [snapshot.value allValues])
             {
                 PFUser *user = [PFUser currentUser];
                 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                 [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
                 [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                 NSString *date = [formatter stringFromDate:[NSDate date]];
                 NSInteger counter = [recent[@"counter"] integerValue];
                 if ([recent[@"userId"] isEqualToString:user.objectId] == NO) counter += amount;
                 FIRDatabaseReference *firebase = [[[[FIRDatabase database] reference] child:@"Conversations"] child:[NSString stringWithFormat:@"%@", recent[@"recentId"]]];
                 NSDictionary *values = @{@"lastUser":user.objectId, @"lastMessage":lastMessage, @"counter":@(counter), @"date":date};
                 [firebase updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
                  {
                      if (error != nil) NSLog(@"resetUnread save error.");
                  }];
             }
         }
     }];}
+ (void)setReadForMessage:(NSString *)groupId andString:(NSString *)read {
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             for (NSDictionary *recent in [snapshot.value allValues])
             {
                 PFUser *user = [PFUser currentUser];
                 if ([recent[@"userId"] isEqualToString:user.objectId] == NO) {
                     //---------------------------------------------------------------------------------------------------------------------------------------------
                     FIRDatabaseReference *firebase = [[[[FIRDatabase database] reference] child:@"Conversations"] child:[NSString stringWithFormat:@"%@", recent[@"recentId"]]];
                     NSDictionary *values = @{@"status":read};
                     [firebase updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
                      {
                          if (error != nil) NSLog(@"setReadForMessage save error.");
                      }];
                 }
             }
         }
     }];
}
+ (void)setDeliveredForMessage:(NSString *)groupId andString:(NSString *)read {
    FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:@"Conversations"];
    FIRDatabaseQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot)
     {
         if (snapshot.value != [NSNull null])
         {
             for (NSDictionary *recent in [snapshot.value allValues])
             {
                 PFUser *user = [PFUser currentUser];
                 if ([recent[@"userId"] isEqualToString:user.objectId] == YES) {
                     //---------------------------------------------------------------------------------------------------------------------------------------------
                     FIRDatabaseReference *firebase = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"Conversations/%@", recent[@"recentId"]]];
                     NSDictionary *values = @{@"status":read};
                     [firebase updateChildValues:values withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref)
                      {
                          if (error != nil) NSLog(@"setDeliveredForMessage save error.");
                      }];
                 }
             }
         }
     }];
}
#pragma mark - audio methods

+ (NSNumber *)durationAudioMessage:(NSString *)path {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    int duration = (int) round(CMTimeGetSeconds(asset.duration));
    return [NSNumber numberWithInt:duration];
}

#pragma mark - video/camera methods
+ (UIImage *)createSquareImageForImage:(UIImage *)image withSize:(CGFloat)size {
    UIImage *cropped;
    if (image.size.height > image.size.width)
    {
        CGFloat ypos = (image.size.height - image.size.width) / 2;
        cropped = [self cropImage:image withX:0 withY:ypos withWidth:image.size.width andHeight:image.size.width];
    }
    else
    {
        CGFloat xpos = (image.size.width - image.size.height) / 2;
        cropped = [self cropImage:image withX:xpos withY:0 withWidth:image.size.width andHeight:image.size.width];
    }
    UIImage *resized = [self resizeImage:cropped withWidth:size andHeight:size];
    return resized;
}
+ (UIImage *)resizeImage:(UIImage *)image withWidth:(CGFloat)width andHeight:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [image drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}
+ (UIImage *)cropImage:(UIImage *)image withX:(CGFloat)x withY:(CGFloat)y withWidth:(CGFloat)width andHeight:(CGFloat)height {
    CGRect rect = CGRectMake(x, y, width, height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}
+ (UIImage *)createThumbnailForVideo:(NSURL *)video {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration]; time.value = 0;
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumbnail;
}
+ (NSNumber *)durationForVideo:(NSURL *)video {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
    int duration = (int) round(CMTimeGetSeconds(asset.duration));
    return [NSNumber numberWithInt:duration];
}

+ (BOOL)shouldPresentPhotoAndVideoCamera:(id)target editable:(BOOL)editable
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return NO;
    NSString *type1 = (NSString *)kUTTypeImage;
    NSString *type2 = (NSString *)kUTTypeMovie;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type1])
    {
        imagePicker.mediaTypes = @[type1, type2];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoMaximumDuration = VIDEO_LENGTH;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
        {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
        else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else return NO;
    imagePicker.allowsEditing = editable;
    imagePicker.showsCameraControls = YES;
    imagePicker.delegate = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [target presentViewController:imagePicker animated:YES completion:nil];
    });
    return YES;
}

+ (BOOL)shouldPresentPhotoLibrary:(id)target editable:(BOOL)editable
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
    NSString *type = (NSString *)kUTTypeImage;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else return NO;
    imagePicker.allowsEditing = editable;
    imagePicker.delegate = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [target presentViewController:imagePicker animated:YES completion:nil];
    });
    return YES;
}

+ (BOOL)shouldPresentVideoLibrary:(id)target editable:(BOOL)editable
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
    NSString *type = (NSString *)kUTTypeMovie;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.videoMaximumDuration = VIDEO_LENGTH;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.mediaTypes = [NSArray arrayWithObject:type];
    }
    else return NO;
    imagePicker.allowsEditing = editable;
    imagePicker.delegate = target;
    dispatch_async(dispatch_get_main_queue(), ^{
        [target presentViewController:imagePicker animated:YES completion:nil];
    });
    return YES;
}

#pragma mark - Converter

+ (NSString *)calculateElapsedPeriod:(NSTimeInterval)seconds
{
    NSString *elapsed;
    if (seconds < 60)
    {
        elapsed = @"Just now";
    }
    else if (seconds < 60 * 60)
    {
        int minutes = (int) (seconds / 60);
        elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
    }
    else if (seconds < 24 * 60 * 60)
    {
        int hours = (int) (seconds / (60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
    }
    else
    {
        int days = (int) (seconds / (24 * 60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
    }
    return elapsed;
}

@end

