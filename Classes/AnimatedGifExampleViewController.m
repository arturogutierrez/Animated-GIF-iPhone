//
//  AnimatedGifExampleViewController.m
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

#import "AnimatedGifExampleViewController.h"
#import "UIImageView+AnimatedGif.h"

@interface AnimatedGifExampleViewController() <AnimatedGifDelegate>

@end

@implementation AnimatedGifExampleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
    
    AnimatedGif * gif = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:@"http://s6.pikabu.ru/post_img/2014/04/07/6/1396854652_1659897712.gif"]];
    gif.delegate = self;
    UIImageView * newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 200)];
    [newImageView setAnimatedGif:gif];
    [gif setLoadingProgressBlock:^(AnimatedGif *obj, CGFloat progress) {
        progressView.progress = progress;
    }];
    [gif setWillShowFrameBlock:^(AnimatedGif *obj, UIImage *img) {
        progressView.hidden = YES;
        CGFloat scaleFactor = newImageView.frame.size.width / img.size.width;
        CGRect newFrame = newImageView.frame;
        if (scaleFactor > 1) {
            newFrame.size.width = img.size.width;
            newFrame.size.height = img.size.height;
        } else {
            newFrame.size.height = img.size.height * scaleFactor;
        }
        newImageView.frame = newFrame;
    }];
    [gif start];
    [self.view insertSubview:newImageView atIndex:0];

}

-(IBAction) makeClear:(id)sender {
    for (UIView * v in self.view.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    lastY = 0;
}
-(IBAction)addMore:(id)sender {
    NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1.gif" ofType:nil]];
    lastY += 20;
    AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
    animation.delegate = self;
    UIImageView * newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, lastY, 300, 200)];
    [newImageView setAnimatedGif:animation startImmediately:YES];
    [self.view insertSubview:newImageView belowSubview:buttons];
}

- (void)didReceiveMemoryWarning {
	[self makeClear:nil];
    [super didReceiveMemoryWarning];
}

#pragma mark - AnimatedGif events
-(void)animatedGifDidStart:(NSNotification*) notify {
    AnimatedGif * object = notify.object;
    NSLog(@"Url will be loaded: %@", object.url);
}
-(void)animatedGifDidFinish:(NSNotification*) notify {
    AnimatedGif * object = notify.object;
    NSLog(@"Url is loaded: %@", object.url);
}

#pragma mark - AnimatedGifDelegate
- (void)animationWillRepeat:(AnimatedGif *)animatedGif
{
    NSLog(@"\nanimationWillRepeat");
    //[animatedGif stop];
}

@end
