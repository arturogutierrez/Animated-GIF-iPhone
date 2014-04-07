# Animated-GIF-IPhone

Library for effective memory optimized GIF playback in iOS. This library will not prepare all frames at once, but will update frames in live. So in this way memory usage is strongly decreased, but CPU usage is increased (because gif decoding).

#Installation
Copy following files to your project: `AnimatedGif.h`, `AnimatedGif.m`,`UIImageView+AnimatedGif.h`,`UIImageView+AnimatedGif.m`.

# Example usage
Creating image view with GIF content:
```
AnimatedGif * gif = [AnimatedGif getAnimationForGifAtUrl:[NSURL URLWithString:@"http://s6.pikabu.ru/post_img/2014/04/07/6/1396854652_1659897712.gif"]];
UIImageView * newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 200)];
[newImageView setAnimatedGif:gif];
[gif setLoadingProgressBlock:^(AnimatedGif *obj, CGFloat progress) {
    progressView.progress = progress;
}];
[gif setWillShowFrameBlock:^(AnimatedGif *obj, UIImage *img) {
    progressView.hidden = YES;
    //... Do stuff
}];
[gif start];
[self.view addSubview:newImageView];
...
//Another way
NSData * animationData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1.gif" ofType:nil]];
AnimatedGif * animation = [AnimatedGif getAnimationForGifWithData:animationData];
UIImageView * newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 300, 200)];
[newImageView setAnimatedGif:animation startImmediately:YES];
[self.view addSubview:newImageView];
```

To manage gif image view you can set observe next events: `AnimatedGifDidStartLoadingingEvent`, `AnimatedGifDidFinishLoadingingEvent`.
```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
...
-(void)animatedGifDidStart:(NSNotification*) notify {
    AnimatedGif * object = notify.object;
    NSLog(@"Url will be loaded: %@", object.url);
}
-(void)animatedGifDidFinish:(NSNotification*) notify {
    AnimatedGif * object = notify.object;
    NSLog(@"Url is loaded: %@", object.url);
    ...
}
```
Also you can use block `setWillShowFrameBlock`.

See example for any questions.

# License
Created by Stijn Spijker

Upgraded by Roman Truba

The MIT License (MIT)

Copyright (c) 2014 Roman Truba

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
