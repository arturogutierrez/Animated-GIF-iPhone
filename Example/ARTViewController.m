//
//  ARTViewController.m
//  AnimatedGifExample
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import "ARTViewController.h"
#import "ARTAnimatedGif.h"

@implementation ARTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"apple_jumps" ofType:@"gif"];
    ARTAnimatedGif *animatedGif = [[ARTAnimatedGif alloc] initWithContentsOfFile:path];
}

@end
