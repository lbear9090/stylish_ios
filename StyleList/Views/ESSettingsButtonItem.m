//
//  ESSettingsButtonItem.m


#import "ESSettingsButtonItem.h"

@implementation ESSettingsButtonItem

#pragma mark - Initialization

- (id)initWithTarget:(id)target action:(SEL)action {
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self = [super initWithCustomView:settingsButton];
    if (self) {

        [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 35.0f, 32.0f)];
        [settingsButton setImage:[UIImage imageNamed:@"ButtonImageSettings"] forState:UIControlStateNormal];
        [settingsButton setImage:[UIImage imageNamed:@"ButtonImageSettingsSelected"] forState:UIControlStateHighlighted];
    }
    
    return self;
}
@end
