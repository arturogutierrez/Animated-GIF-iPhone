//
//  AnimatedGifExampleViewController.m
//  AnimatedGifExample
//
//  Created by Stijn Spijker on 05-07-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AnimatedGifExampleViewController.h"
#import "AnimatedGif.h"

@implementation AnimatedGifExampleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
    
    AnimatedGif * gif = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:@"https://vk.com/doc220856570_282157553?hash=41a38efba790bafa06&dl=0898a180fd122f9547&wnd=1"]];
    [ivOne addSubview:gif.gifView];
    [gif setWillShowFrameBlock:^(AnimatedGif *obj, UIImage *img) {
        CGRect parentFrame = ivOne.frame;
        CGFloat scale = parentFrame.size.width / img.size.width;
        ivOne.frame = CGRectMake(parentFrame.origin.x, parentFrame.origin.y, parentFrame.size.width, img.size.height * scale);
        [obj.gifView sizeToParent];
    }];
    [gif start];
    
}

-(IBAction) makeClear:(id)sender {
    for (UIView * subview in ivOne.subviews) {
        [subview removeFromSuperview];
    }
    for (UIView * subview in ivTwo.subviews) {
        [subview removeFromSuperview];
    }
    [ivTwo removeFromSuperview];
    lastY = 0;
}
-(IBAction)addMore:(id)sender {
    NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2.gif" ofType:nil]];
    lastY += 20;
    AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
    [animation setWillShowFrameBlock:^(AnimatedGif *gif, UIImage * nextFrame) {
        CGRect viewFrame = gif.gifView.frame;
        viewFrame.origin.y = lastY;
        gif.gifView.frame = viewFrame;
    }];
	[ivOne addSubview:animation.gifView];
    [animation start];
}

- (void)didReceiveMemoryWarning {
	[self makeClear:nil];
    [super didReceiveMemoryWarning];
}

#pragma mark - AnimatedGif events
-(void)animatedGifDidStart:(NSNotification*) notify {
    AnimatedGifQueueObject * object = notify.object;
    NSLog(@"Url will be loaded: %@", object.url);
}
-(void)animatedGifDidFinish:(NSNotification*) notify {
    AnimatedGifQueueObject * object = notify.object;
    NSLog(@"Url is loaded: %@", object.url);
}

@end
