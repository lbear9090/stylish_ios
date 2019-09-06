//
//  CLImageEditorTheme.m


#import "CLImageEditorTheme.h"

@implementation CLImageEditorTheme

#pragma mark - singleton pattern

static CLImageEditorTheme *_sharedInstance = nil;

+ (CLImageEditorTheme*)theme
{
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CLImageEditorTheme alloc] init];
    });
    return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [super allocWithZone:zone];
            return _sharedInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bundleName                     = @"CLImageEditor";
        self.backgroundColor                = [UIColor whiteColor];
        self.toolbarColor                   = [UIColor colorWithWhite:1 alpha:1];
		self.toolIconColor                  = @"white";
        self.toolbarTextColor               = [UIColor blackColor];
        self.toolbarSelectedButtonColor     = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        self.toolbarTextFont                = [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:10];
    }
    return self;
}

@end
