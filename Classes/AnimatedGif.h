//
//  AnimatedGif.m
//
//  Created by Stijn Spijker (http://www.stijnspijker.nl/) on 2009-07-03.
//  Based on gifdecode written april 2009 by Martin van Spanje, P-Edge media.
//
//  Changes on gifdecode:
//  - Small optimizations (mainly arrays)
//  - Object Orientated Approach (Class Methods as well as Object Methods)
//  - Added the Graphic Control Extension Frame for transparancy
//  - Changed header to GIF89a
//  - Added methods for ease-of-use
//  - Added animations with transparancy
//  - No need to save frames to the filesystem anymore
//
//  Changelog:
//
//	2010-03-16: Added queing mechanism for static class use
//  2010-01-24: Rework of the entire module, adding static methods, better memory management and URL asynchronous loading
//  2009-10-08: Added dealloc method, and removed leaks, by Pedro Silva
//  2009-08-10: Fixed double release for array, by Christian Garbers
//  2009-06-05: Initial Version
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#ifdef TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif //TARGET_OS_IPHONE

static NSString * AnimatedGifLoadingProgressEvent = @"AnimatedGifLoadingProgressEvent";
static NSString * AnimatedGifDidStartLoadingingEvent = @"AnimatedGifDidStartLoadingingEvent";
static NSString * AnimatedGifDidFinishLoadingingEvent = @"AnimatedGifDidFinishLoadingingEvent";

@interface AnimatedGifFrame : NSObject
{
	NSData *data;
	NSData *header;
	double delay;
	int disposalMethod;
	CGRect area;
}

@property (nonatomic, copy) NSData *header;
@property (nonatomic, copy) NSData *data;
@property (nonatomic) double delay;
@property (nonatomic) int disposalMethod;
@property (nonatomic) CGRect area;

@end

@interface AnimatedGifProgressImageView : UIImageView
@property (nonatomic, strong) UIProgressView * progressView;
@end

@interface AnimatedGifQueueObject : NSObject <NSURLConnectionDataDelegate>
{
    long long expectedGifSize;
}
@property (nonatomic, strong) AnimatedGifProgressImageView *gifView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) CGFloat loadingProgress;
@property (nonatomic, copy) void(^didFinishBlock)(AnimatedGifQueueObject *object);
-(void) sizeToParentWidth;
@end

@interface AnimatedGif : NSObject
{
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableArray *GIF_frames;
    
	bool busyDecoding;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;
    
    UIImageView *imageView;
}

@property (nonatomic, strong) UIImageView* imageView;
@property bool busyDecoding;

+ (void) clear;
+ (UIImageView*) getAnimationForGifAtUrl: (NSURL *) animationUrl;
+ (UIImageView*) getAnimationForGifWithData:(NSData*) data;
- (void) decodeGIF:(NSData *)GIF_Data;
- (void) GIFReadExtensions;
- (void) GIFReadDescriptor;
- (bool) GIFGetBytes:(NSInteger)length;
- (bool) GIFSkipBytes: (NSInteger) length;
- (NSData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;
- (UIImageView*) getAnimation;

@end