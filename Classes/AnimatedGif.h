//
//  AnimatedGif2.h
//  AnimatedGifExample
//
//  Created by Roman Truba on 07.04.14.
//
//

#import <Foundation/Foundation.h>
static NSString * const AnimatedGifLoadingProgressEvent = @"AnimatedGifLoadingProgressEvent";
static NSString * const AnimatedGifDidStartLoadingingEvent = @"AnimatedGifDidStartLoadingingEvent";
static NSString * const AnimatedGifDidFinishLoadingingEvent = @"AnimatedGifDidFinishLoadingingEvent";
static NSString * const AnimatedGifRemovedFromSuperview = @"AnimatedGifRemovedFromSuperview";

@class AnimatedGif;
@interface AnimatedGifFrame : NSObject

@property (nonatomic, copy) NSData *header;
@property (nonatomic, copy) NSData *data;
@property (nonatomic, assign) double delay;
@property (nonatomic, assign) int disposalMethod;
@property (nonatomic, assign) CGRect area;
@end

@interface AnimatedGifProgressImageView : UIImageView
@property (nonatomic, strong) UIProgressView * progressView;
@property (nonatomic, strong) UIActivityIndicatorView * activityView;
@property (nonatomic, strong) AnimatedGif * animationGif;

-(void) sizeToParent;
@end

@interface AnimatedGifQueueObject : NSObject <NSURLConnectionDataDelegate>
{
    long long expectedGifSize;
}
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) CGFloat loadingProgress;

@end

@interface AnimatedGif : NSObject
{
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
    AnimatedGifFrame *thisFrame, *lastFrame;
    UIImage * lastImage, *preview;
    NSDate * frameTime;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int dataPointer;
    
    BOOL stoped;
    
    NSThread * thisGifThread;
}
@property (nonatomic, strong) AnimatedGifProgressImageView *gifView;
@property (nonatomic, copy) void(^willShowFrameBlock)(AnimatedGif *object, UIImage * frame);

+ (AnimatedGif*) getAnimationForGifAtUrl: (NSURL *) animationUrl;
+ (AnimatedGif*) getAnimationForGifWithData:(NSData*) data;
- (void) insertToView:(UIView*) parentView;
- (void) setPreview:(UIImage*) preview;
- (void) stop;
- (void) start;
@end
