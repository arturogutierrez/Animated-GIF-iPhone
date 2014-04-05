# Animated-GIF-IPhone

Library for effictive GIF playback in iOS.

# Example usage
Creating image view with GIF content:
```
NSURL 			* firstUrl = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"gif"];
UIImageView 	* firstAnimation = 	[AnimatedGif getAnimationForGifAtUrl: firstUrl];
[self.view addSubview:firstAnimation];
```

To manage gif image view you can set AnimatedGifDelegate:
```
[AnimatedGif setDelegate:self];
...
//Example sizing
-(void)animatedGifImageView:(UIImageView *)animatedView readyWithSize:(CGSize)gifSize {
    if (gifSize.width > ivOne.frame.size.width) {
        CGFloat scale = ivOne.frame.size.width / gifSize.width;
        animatedView.frame = CGRectMake(0, lastY, gifSize.width * scale, gifSize.height * scale);
    }
}
```

#License
==========
Permission is given to use this source code files, free of charge, in any
project, commercial or otherwise, entirely at your risk, with the condition
that any redistribution (in part or whole) of source code must retain
this copyright and permission notice. Attribution in compiled projects is
appreciated but not required.
