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
@property (nonatomic, strong) IBOutlet UIScrollView *gifScroll;
@property (nonatomic, strong) IBOutlet UIView * buttons;
@property (nonatomic, strong) IBOutlet UIProgressView * progressView;
@property (nonatomic, strong) NSMutableArray *animations;
@end

@implementation AnimatedGifExampleViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self makeClear:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidStart:) name:AnimatedGifDidStartLoadingingEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedGifDidFinish:) name:AnimatedGifDidFinishLoadingingEvent object:nil];
    [self addAnimationWithURL:[NSURL URLWithString:@"http://s6.pikabu.ru/post_img/2014/04/07/6/1396854652_1659897712.gif"]];
}

-(IBAction) makeClear:(id)sender {
    for (UIView * v in self.gifScroll.subviews) {
        [v removeFromSuperview];
    }
    _animations = [NSMutableArray new];
}
-(IBAction)addMore:(id)sender {
    static int animationNum = 0;
    if (++animationNum > 6) {
        animationNum = 1;
    }
//    NSData * animationData  = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource: ofType:nil]];
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%d",animationNum] withExtension:@"gif"];
    [self addAnimationWithURL:url];
}

- (void)addAnimationWithURL:(NSURL*) url {
    AnimatedGif * animation = [AnimatedGif getAnimationForGifAtUrl:url];
    animation.delegate = self;
    
    UIView *lastView = self.animations.lastObject;
    UIImageView * newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lastView.frame), 300, 200)];
    [newImageView setAnimatedGif:animation startImmediately:YES];
    [animation setLoadingProgressBlock:^(AnimatedGif *obj, CGFloat progress) {
        _progressView.progress = progress;
    }];
    [animation setWillShowFrameBlock:^(AnimatedGif *gif, UIImage *img) {
        _progressView.hidden = YES;
        CGSize gifSize = img.size;
        if (gifSize.width > 300) {
            CGFloat ratio = 300 / gifSize.width;
            gifSize.width = 300;
            gifSize.height = roundf(gifSize.height * ratio);
        }
        CGRect frame = newImageView.frame;
        frame.size   = gifSize;
        newImageView.frame = frame;
        self.gifScroll.contentSize = CGSizeMake(320, CGRectGetMaxY(newImageView.frame));
        if (_gifScroll.contentSize.height > _gifScroll.bounds.size.height) {
            CGPoint bottomOffset = CGPointMake(0, self.gifScroll.contentSize.height - self.gifScroll.bounds.size.height);
            [self.gifScroll setContentOffset:bottomOffset animated:YES];
        }
    }];
    [self.gifScroll addSubview:newImageView];
    [self.animations addObject:newImageView];
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
