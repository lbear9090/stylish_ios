//
//  ESPhotoCell.h
//  D'Netzwierk
//
//  Created by Eric Schanet on 6/05/2014.
//  Copyright (c) 2014 Eric Schanet. All rights reserved.
//

@class PFImageView;
/**
 *  Interface of the ESPhotoCell, the cell in which the loaded photo is displayed in the timeline
 */
@interface ESPhotoCell : PFTableViewCell
/**
 *  Button above the photo, used to catch taps
 */
@property (nonatomic, strong) UIButton *mediaItemButton;
@property (nonatomic, strong) UIButton *binocularsBtn;
@property (nonatomic, strong) UIButton *btnBookmark;
@property (nonatomic, strong) UIButton *btnHashTag;
/**
 *  Used to catch single taps
 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
/**
 *  Used to catch double taps
 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@property (nonatomic, strong) UIView                *tagTitleBar;
@property (nonatomic, strong) UILabel               *tagLabel;
@property (nonatomic, strong) UILabel               *costtagLabel;
@property (nonatomic, strong) UIImageView           *imgOwnTag;
@property (nonatomic, strong) UILabel               *lblOwnTag;


@end
