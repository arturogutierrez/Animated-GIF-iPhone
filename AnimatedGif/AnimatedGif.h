//
//  AnimatedGif2.h
//
//  Created by Stijn Spijker on 05-07-09.
//  Upgraded by Roman Truba on 2014
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
static NSString * const AnimatedGifLoadingProgressEvent = @"AnimatedGifLoadingProgressEvent";
static NSString * const AnimatedGifDidStartLoadingingEvent = @"AnimatedGifDidStartLoadingingEvent";
static NSString * const AnimatedGifDidFinishLoadingingEvent = @"AnimatedGifDidFinishLoadingingEvent";
static NSString * const AnimatedGifRemovedFromSuperview = @"AnimatedGifRemovedFromSuperview";

@class AnimatedGif;

@protocol AnimatedGifDelegate <NSObject>

- (void)animationWillRepeat:(AnimatedGif *)animatedGif;

@end

/**
 * Class for enqueing gif loading requests. Also, it keeps gif data info
 */
@interface AnimatedGifQueueObject : NSObject <NSURLConnectionDataDelegate>
{
    long long expectedGifSize;
}
/// URL of gif been loaded
@property (nonatomic, strong) NSURL *url;
/// Data of gif
@property (nonatomic, strong) NSData *data;
/// Current network gif download progress
@property (nonatomic, assign) CGFloat loadingProgress;

@end

/**
 * Class for creating animated gif playback.
 */
@interface AnimatedGif : NSObject

@property (nonatomic, assign) id<AnimatedGifDelegate> delegate;

/// Progress block will be called when GIF is loading from network.
@property (nonatomic, copy) void(^loadingProgressBlock)(AnimatedGif *object, CGFloat progressLevel);
/**
 * This block will be called when we are ready to show first frame of animation.
 * You can use it to correctly size your parent UIImageView. 
 * First frame of animation will be passed in frame.
 * Also, animationSize property will be set before this block invokation.
*/
@property (nonatomic, copy) void(^willShowFrameBlock)(AnimatedGif *object, UIImage * frame);
/// URL of current animation gif if it was passed
@property (nonatomic, readonly) NSURL *url;
/// Size of current animation GIF. Will be set only after loading and first frame processed
@property (nonatomic, assign)   CGSize animationSize;
/// Image view where animation will be shown
@property (nonatomic, weak)     UIImageView * parentView;

/// Creates new animation from URL. It may be local file URL, or web URL
+ (AnimatedGif*) getAnimationForGifAtUrl: (NSURL *) animationUrl;
/// Creates new animation with GIF data
+ (AnimatedGif*) getAnimationForGifWithData:(NSData*) data;
/// Starts animation process (loading -> preparing -> display)
- (void) start;
/// Stops current animation
- (void) stop;

@end
