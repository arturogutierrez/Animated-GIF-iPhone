# Animated-GIF-IPhone

Library for effective GIF playback in iOS.

#Installation
Copy `AnimatedGif.h` and `AnimatedGif.m` to your project.

# Example usage
Creating image view with GIF content:
```
NSURL 			* firstUrl = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"gif"];
UIImageView 	* firstAnimation = 	[AnimatedGif getAnimationForGifAtUrl: firstUrl];
[self.view addSubview:firstAnimation];
...
NSURL 			* secondUrl = [NSURL URLWithString:@"https://ps.vk.me/c538316/u896232/docs/aea430132f2c/1394991425_140509903.gif?extra=lAhS4VR5PB3t8Q4vKh1Bw0UyjiYVhMZRowikezVvQzVeh5u3b1YScaiXGqpl9djZnJg8w46l_rjOYi5kaLGPm2Zo"];
UIImageView 	* secondAnimation = 	[AnimatedGif getAnimationForGifAtUrl: secondUrl];
[ivTwo addSubview:secondAnimation];
```

To manage gif image view you can set observe next events: `AnimatedGifDidStartLoadingingEvent`, `AnimatedGifDidFinishLoadingingEvent`.
```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
...
-(void)animatedGifDidStart:(NSNotification*) notify {
    AnimatedGifQueueObject * object = notify.object;
    NSLog(@"Url will be loaded: %@", object.url);
}
-(void)animatedGifDidFinish:(NSNotification*) notify {
    AnimatedGifQueueObject * object = notify.object;
    NSLog(@"Url is loaded: %@", object.url);
    ...
}
```

# License
Created by Stijn Spijker
Upgraded by Roman Truba
Permission is given to use this source code files, free of charge, in any
project, commercial or otherwise, entirely at your risk, with the condition
that any redistribution (in part or whole) of source code must retain
this copyright and permission notice. Attribution in compiled projects is
appreciated but not required.
