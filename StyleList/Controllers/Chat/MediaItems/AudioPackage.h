//
//  AudioPackage.h

#import "JSQMediaItem.h"

@interface AudioPackage : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
 
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSNumber *duration;

- (instancetype)initWithFileURL:(NSURL *)fileURL Duration:(NSNumber *)duration;

@end
