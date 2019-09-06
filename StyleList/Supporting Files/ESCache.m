//
//  ESCache.m


#import "ESCache.h"

@interface ESCache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo;
@end

@implementation ESCache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];

        self.strBags = nil;
        self.strAccessories = nil;
        self.strBlazer = nil;
        self.strJacket = nil;
        self.strSkirt = nil;
        self.strPants = nil;
        self.strShirt = nil;
        self.strShoes = nil;
        self.strDress = nil;
        self.strSuit = nil;
        self.arrayFilterInfo = [[NSMutableArray alloc]init];
        
        //------ init Style Array------//
        self.mStyleInfoArray = [[NSMutableArray alloc]init];
        self.mStyleDetailInfoArray = [[NSMutableArray alloc]init];
        self.mSelectedStyleDetailInfoArray = [[NSMutableArray alloc]init];
        self.styleSelectedTag = 0;
        self.selectedStyleName = @"";
        //------ init Select Recent, Trending, Featured ------//
        self.selectedTap = @"";
        //------ init Select For Inspiration, For Sale, For Hire ------//
        self.selectedSaleTypeTap = @"";
        //------ init Select MyStyleButton or not ChoosePhotoButton , TakePhotoButton Tag ------//
        self.selectedBtnTag = @"";
        //------ init photo editor photoEditedDoneTag, photoEditedTag ------//
        self.photoEditedTag = @"";
        //------ init selected user gender, user name, logined user name -------//
        self.selectedUserGender = @"";
        self.selectedUserId = @"";
        self.loginedUserId = @"";
        self.selectedUserStyleTagName = @"";
        //------ selected original image from photo gallery --------//
        self.selectedGalleryOriginalImage = [[UIImage alloc]init];
        self.selectedGalleryImageStringTag = @"";
        //------ drawed image point (start point and end point).-----//
        
        //------ selected edited with drawing image from photo gallery and current user of comment, hashtag ------//
        self.currentUserComment = @"";
        self.selectSaleHireType = @"";
        self.selectItemTitle    = @"";
        self.postingPhotoImg = [[UIImage alloc]init];
        //----selected bezier path with drawing image. ----//
        self.drawingInPath = [[UIBezierPath alloc]init];
        self.selectedGalleryDrawingImage = [[UIImage alloc]init];
        self.selectedCropBtn = NO;
        //----  selected publish and tag with posting image ----//
        self.selectPublishAndTag = @"";
        self.selectedBeforeEditOriginalImg = [[UIImage alloc]init];
        //----selected ration position variables.----------------//
        self.ratioXPosition     = @"";
        self.ratioYPosition     = @"";
        self.ratioRectWidth     = @"";
        self.ratioRectHeight    = @"";
        self.ratioItemViewXPosition = @"";
        self.ratioItemViewYPosition = @"";
        self.notificationCount  = 0;
        self.photoPostObjectId  = @"";
        self.photoPostObject    = [PFObject objectWithClassName:kESPhotoClassKey];
        self.selectedItemObjects = [[NSMutableArray alloc]init];
        self.arrOwnLabel        = [[NSMutableArray alloc]init];
        self.selectedItemObjectUser = [[PFUser alloc]init];
        //----selected category location name variables.----------------//
        self.selectedCategoryName     = @"";
        self.selectedLocationInfoName = @"";
        self.deliveryMeetState        = @"";
        self.deliveryShippingState    = @"";
        self.conditionOption          = @"";
        self.domesticCost             = @"";
        self.internationalCost        = @"";

     
    }
    return self;
}

#pragma mark - ESCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (void)setAttributesForPhoto:(PFObject *)photo likers:(NSArray *)likers commenters:(NSArray *)commenters likedByCurrentUser:(BOOL)likedByCurrentUser {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:likedByCurrentUser],kESPhotoAttributesIsLikedByCurrentUserKey,
                                      @([likers count]),kESPhotoAttributesLikeCountKey,
                                      likers,kESPhotoAttributesLikersKey,
                                      @([commenters count]),kESPhotoAttributesCommentCountKey,
                                      commenters,kESPhotoAttributesCommentersKey,
                                      nil];
    [self setAttributes:attributes forPhoto:photo];
}

- (NSDictionary *)attributesForPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    return [self.cache objectForKey:key];
}

- (NSNumber *)likeCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kESPhotoAttributesLikeCountKey];
    }

    return [NSNumber numberWithInt:0];
}

- (NSNumber *)commentCountForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kESPhotoAttributesCommentCountKey];
    }
    
    return [NSNumber numberWithInt:0];
}

- (NSArray *)likersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kESPhotoAttributesLikersKey];
    }
    
    return [NSArray array];
}

- (NSArray *)commentersForPhoto:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [attributes objectForKey:kESPhotoAttributesCommentersKey];
    }
    
    return [NSArray array];
}

- (void)setPhotoIsLikedByCurrentUser:(PFObject *)photo liked:(BOOL)liked {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
    [attributes setObject:[NSNumber numberWithBool:liked] forKey:kESPhotoAttributesIsLikedByCurrentUserKey];
    [self setAttributes:attributes forPhoto:photo];
}

- (BOOL)isPhotoLikedByCurrentUser:(PFObject *)photo {
    NSDictionary *attributes = [self attributesForPhoto:photo];
    if (attributes) {
        return [[attributes objectForKey:kESPhotoAttributesIsLikedByCurrentUserKey] boolValue];
    }
    
    return NO;
}

- (void)incrementLikerCountForPhoto:(PFObject *)photo {
//    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] + 1];
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
//    [attributes setObject:likerCount forKey:kESPhotoAttributesLikeCountKey];
//    [self setAttributes:attributes forPhoto:photo];
//
//    NSNumber *onlineLikerCount = [photo objectForKey:kESPhotoPopularPointsKey];
//    onlineLikerCount = [NSNumber numberWithInt:[onlineLikerCount intValue] + 1];
//    [photo setObject:onlineLikerCount forKey:kESPhotoPopularPointsKey];
//    [photo saveInBackground];
}

- (void)decrementLikerCountForPhoto:(PFObject *)photo {
//    NSNumber *likerCount = [NSNumber numberWithInt:[[self likeCountForPhoto:photo] intValue] - 1];
//    if ([likerCount intValue] < 0) {
//        return;
//    }
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
//    [attributes setObject:likerCount forKey:kESPhotoAttributesLikeCountKey];
//    [self setAttributes:attributes forPhoto:photo];
//
//    NSNumber *onlineLikerCount = [photo objectForKey:kESPhotoPopularPointsKey];
//    onlineLikerCount = [NSNumber numberWithInt:[onlineLikerCount intValue] - 1];
//    if ([onlineLikerCount intValue] < 0) {
//        return;
//    }
//    [photo setObject:onlineLikerCount forKey:kESPhotoPopularPointsKey];
//    [photo saveInBackground];
}

- (void)incrementCommentCountForPhoto:(PFObject *)photo {
//    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] + 1];
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
//    [attributes setObject:commentCount forKey:kESPhotoAttributesCommentCountKey];
//    [self setAttributes:attributes forPhoto:photo];
//
//    NSNumber *onlineLikerCount = [photo objectForKey:kESPhotoPopularPointsKey];
//    onlineLikerCount = [NSNumber numberWithInt:[onlineLikerCount intValue] + 1];
//    [photo setObject:onlineLikerCount forKey:kESPhotoPopularPointsKey];
//    [photo saveInBackground];
}

- (void)decrementCommentCountForPhoto:(PFObject *)photo {
//    NSNumber *commentCount = [NSNumber numberWithInt:[[self commentCountForPhoto:photo] intValue] - 1];
//    if ([commentCount intValue] < 0) {
//        return;
//    }
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForPhoto:photo]];
//    [attributes setObject:commentCount forKey:kESPhotoAttributesCommentCountKey];
//    [self setAttributes:attributes forPhoto:photo];
//
//    NSNumber *onlineLikerCount = [photo objectForKey:kESPhotoPopularPointsKey];
//    onlineLikerCount = [NSNumber numberWithInt:[onlineLikerCount intValue] - 1];
//    if ([onlineLikerCount intValue] < 0) {
//        return;
//    }
//    [photo setObject:onlineLikerCount forKey:kESPhotoPopularPointsKey];
//    [photo saveInBackground];
}

- (void)setAttributesForUser:(PFUser *)user photoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count,kESUserAttributesPhotoCountKey,
                                [NSNumber numberWithBool:following],kESUserAttributesIsFollowedByCurrentUserKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)photoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *photoCount = [attributes objectForKey:kESUserAttributesPhotoCountKey];
        if (photoCount) {
            return photoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *followStatus = [attributes objectForKey:kESUserAttributesIsFollowedByCurrentUserKey];
        if (followStatus) {
            return [followStatus boolValue];
        }
    }

    return NO;
}

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kESUserAttributesPhotoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:following] forKey:kESUserAttributesIsFollowedByCurrentUserKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kESUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

- (NSArray *)facebookFriends {
    NSString *key = kESUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }

    return friends;
}

- (void)setShowTags:(PFObject *)photo flag:(NSString *) flag{
    
    [photo setObject:flag forKey:kESPhotoShowTags];
    [photo saveInBackground];
}

#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];    
}

- (NSString *)keyForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}
@end
