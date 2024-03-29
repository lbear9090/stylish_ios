//
//  ESVideoTableViewCell.h
//  d'Netzwierk
//
//  Created by Eric Schanet on 07.12.14.
//
//
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
/**
 *  Interface of the ESVideoTableViewCell, the cell that contains the video in the timeline
 */
@interface ESVideoTableViewCell : PFTableViewCell
/**
 *  Movieplayer used to play the video
 */
@property (nonatomic, retain) MPMoviePlayerController *movie;
/**
 *  Button on top the video used to catch taps
 */
@property (nonatomic, strong) UIButton *mediaItemButton;
@property (nonatomic, strong) UIButton *binocularsBtn;
@property (nonatomic, strong) UIButton *btnBookmark;
@property (nonatomic, strong) UIButton *btnHashTag;
/**
 *  Imageview containing the thumbnail image of the video. The thumbnail is displayed as static image and the video starts as soon as the play button is tapped
 */
@property (nonatomic, strong) PFImageView *thumbnail;

@property (nonatomic, strong) UIView                *tagTitleBar;
@property (nonatomic, strong) UILabel               *tagLabel;
@property (nonatomic, strong) UILabel               *costtagLabel;
@property (nonatomic, strong) UIImageView           *imgOwnTag;
@property (nonatomic, strong) UILabel               *lblOwnTag;

@end
