/*
 *  ImageCache.h
 *
 *  Description : A cache being able to download and store images so next time
 *  they will not be re-fetched and they can be resized easily
 *
 *
 */

@import UIKit;
@import Foundation;

typedef void (^WMOMImageCacheImageAvailableBlock)(UIImage *image);

@interface ImageCache : NSObject
{
    NSOperationQueue *_downloadImageQueue;
    NSMutableDictionary *_pathToContainerDictionary;
}

/* Singleton access */
+ (ImageCache *)defaultCache;


/* Single access, result is always through the block that may come instantaneously or not if a download is needed */
- (void) imageForURL:(NSURL *)url size:(CGSize)imageSize mode:(UIViewContentMode)mode availableBlock:(WMOMImageCacheImageAvailableBlock)availableBlock;

// Delete content of file
- (void)deleteCashedImageForURL:(NSURL *)url size:(CGSize)desiredImageSize;

@end
