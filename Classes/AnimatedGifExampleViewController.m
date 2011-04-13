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
    
    // First example (Optimizied gif restoring background)
    NSURL 			* firstUrl = 		[NSURL URLWithString:@"http://www.gifs.net/Animation11/Food_and_Drinks/Fruits/Apple_jumps.gif"];
    UIImageView 	* firstAnimation = 	[AnimatedGif getAnimationForGifAtUrl: firstUrl];
    
    // Second example (Optimizied Gif), through HTTP
    NSURL 		* secondUrl       = [NSURL URLWithString:@"http://www.allweb.it/images/4_Humor/emoticon_3d/emoticon_3d_53.gif"];
    UIImageView * secondAnimation = [AnimatedGif getAnimationForGifAtUrl: secondUrl];
    
    // Third example (Disposal Method None)
    UIImageView * disposalNoneAnimation = [AnimatedGif getAnimationForGifAtUrl: [NSURL URLWithString:@"http://www.imagemagick.org/Usage/anim_basics/anim_none.gif"]];
    
    // Third example (Disposal Method Previous)
    UIImageView * disposalPrevAnimation = [AnimatedGif getAnimationForGifAtUrl: [NSURL URLWithString:@"http://www.imagemagick.org/Usage/anim_basics/canvas_prev.gif"]];
    
    // Third example (Disposal Method Background)
    UIImageView * disposalBgAnimation = [AnimatedGif getAnimationForGifAtUrl: [NSURL URLWithString:@"http://www.imagemagick.org/Usage/anim_basics/anim_bgnd.gif"]];
    
    // Add them to the view.
	[ivOne addSubview:firstAnimation];
	[ivTwo addSubview:secondAnimation];
    [ivThree addSubview:disposalNoneAnimation];
    [ivFour addSubview:disposalPrevAnimation];
    [ivFive addSubview:disposalBgAnimation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.

    [super didReceiveMemoryWarning];
}

@end
