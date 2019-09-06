//
//  JTSSimpleImageDownloader.h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@import Foundation;

@interface JTSSimpleImageDownloader : NSObject

+ (NSURLSessionDataTask *)downloadImageForURL:(NSURL *)imageURL
                                 canonicalURL:(NSURL *)canonicalURL
                                   completion:(void(^)(UIImage *image))completion;

@end
