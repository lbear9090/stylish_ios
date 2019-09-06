//
//  CLImageEditorTheme.h


#import <Foundation/Foundation.h>

@protocol CLImageEditorThemeDelegate;

@interface CLImageEditorTheme : NSObject

@property (nonatomic, weak) id<CLImageEditorThemeDelegate> delegate;
@property (nonatomic, strong) NSString *bundleName;
@property (nonatomic, strong) UIColor  *backgroundColor;
@property (nonatomic, strong) UIColor  *toolbarColor;
@property (nonatomic, strong) NSString *toolIconColor;
@property (nonatomic, strong) UIColor  *toolbarTextColor;
@property (nonatomic, strong) UIColor  *toolbarSelectedButtonColor;
@property (nonatomic, strong) UIFont   *toolbarTextFont;

+ (CLImageEditorTheme*)theme;

@end


@protocol CLImageEditorThemeDelegate <NSObject>
@optional
- (UIActivityIndicatorView*)imageEditorThemeActivityIndicatorView;

@end
