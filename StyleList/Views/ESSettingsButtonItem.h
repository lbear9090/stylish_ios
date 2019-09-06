//
//  ESSettingsButtonItem.h


@interface ESSettingsButtonItem : UIBarButtonItem

/**
 *  Init method of the custom bar button
 *
 *  @param target target of the button
 *  @param action action that the button shall call
 *
 *  @return self
 */
- (id)initWithTarget:(id)target action:(SEL)action;

@end
