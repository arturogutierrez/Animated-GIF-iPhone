//
//  AnimatedGifExampleViewController.m
//  AnimatedGifExample
//
//  Created by Stijn Spijker on 05-07-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//


#import "AnimatedGifExampleViewController.h"

@implementation AnimatedGifExampleViewController

//
// viewDidLoad
//
// Get's the animated gif, and places it on the view.
//
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // Second example (Optimizied Gif), through HTTP
    NSURL 		* secondUrl       = [NSURL URLWithString:@"http://www.allweb.it/images/4_Humor/emoticon_3d/emoticon_3d_53.gif"];
    UIImageView * secondAnimation = [AnimatedGif getAnimationForGifAtUrl: secondUrl];
    
    [ivTwo addSubview:secondAnimation];
}

-(IBAction) makeClear:(id)sender {
    for (UIView * subview in ivOne.subviews) {
        [subview removeFromSuperview];
    }
    lastY = 0;
    [AnimatedGif clear];
}
-(IBAction)addMore:(id)sender {
    NSURL 			* firstUrl = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"gif"];
    UIImageView 	* firstAnimation = 	[AnimatedGif getAnimationForGifAtUrl: firstUrl];
    [AnimatedGif setDelegate:self];
	[ivOne addSubview:firstAnimation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    
    [super didReceiveMemoryWarning];
}

#pragma mark - AnimatedGif delegate
-(void)animatedGifImageView:(UIImageView *)animatedView readyWithSize:(CGSize)gifSize {
    if (gifSize.width > ivOne.frame.size.width) {
        CGFloat scale = ivOne.frame.size.width / gifSize.width;
        
        animatedView.frame = CGRectMake(0, lastY, gifSize.width * scale, gifSize.height * scale);
        lastY += 20;
    }
    
}

@end
