//
//  ESProfileImageView.m


#import "ESProfileImageView.h"

@interface ESProfileImageView ()
@end

@implementation ESProfileImageView

@synthesize profileImageView;
@synthesize profileButton;


#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.profileImageView = [[PFImageView alloc] initWithFrame:frame];
        [self addSubview:self.profileImageView];
        
        self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.profileButton];

    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.profileImageView.frame = CGRectMake( 1.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    self.profileButton.frame = CGRectMake( 0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}


#pragma mark - ESProfileImageView

- (void)setFile:(PFFile *)file {
    if (!file) {
        return;
    }

    self.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceholder"];
    self.profileImageView.file = file;
    [self.profileImageView loadInBackground];
}

@end
