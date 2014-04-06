//
//  AnimatedGifExampleViewController.m
//  AnimatedGifExample
//
//  Created by Stijn Spijker on 05-07-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "AnimatedGifExampleViewController.h"

static NSString * const ANIMATION_CAGE = @"local_animation_cage";
@implementation AnimatedGifExampleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
    
    NSURL * firstUrl = [NSURL URLWithString:@"https://ps.vk.me/c538316/u896232/docs/aea430132f2c/1394991425_140509903.gif?extra=lAhS4VR5PB3t8Q4vKh1Bw0UyjiYVhMZRowikezVvQzVeh5u3b1YScaiXGqpl9djZnJg8w46l_rjOYi5kaLGPm2Zo"];
    AnimatedGifQueueObject * firstAnimation = 	[AnimatedGif getAnimationForGifAtUrl: firstUrl];
    firstAnimation.animationId = @"Dog_shit_animation";
    [firstAnimation setReadyToShowBlock:^(AnimatedGifQueueObject *obj) {
        [obj sizeToParentWidth];
    }];
    [ivTwo addSubview:firstAnimation.gifView];
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
    [AnimatedGif clear];
}
-(IBAction)addMore:(id)sender {
    NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2.gif" ofType:nil]];
    AnimatedGifQueueObject * animation = [AnimatedGif getAnimationForGifWithData:animationData];
    animation.animationId = ANIMATION_CAGE;
    [animation setReadyToShowBlock:^(AnimatedGifQueueObject *object) {
        [object sizeToParentWidth];
        CGRect fr = object.gifView.frame;
        fr.origin.y = lastY;
        object.gifView.frame = fr;
        lastY += 20;
    }];
	[ivOne addSubview:animation.gifView];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    
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
