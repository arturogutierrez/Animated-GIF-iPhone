//
//  UIImageView+AnimatedGif.m
//  AnimatedGifExample
//
//  Created by Roman Truba on 07.04.14.
//  Copyright (c) 2014 VK.com
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

#import <objc/runtime.h>
#import <objc/message.h>
#import "UIImageView+AnimatedGif.h"
void Swizzle(Class c, SEL orig, SEL new)
{
    Method originalMethod = class_getInstanceMethod(c, orig);
    Method overrideMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(c, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, overrideMethod);
    }
}
static NSMutableDictionary * swizzledClasses;
static void *UIViewAnimationKey;
@implementation UIImageView (AnimatedGif)
-(instancetype) initWithAnimationAtURL:(NSURL*) animationUrl startImmediately:(BOOL)start {
    self = [self init];
    self.animatedGif = [AnimatedGif getAnimationForGifAtUrl:animationUrl];
    if (start) {
        [self startAnimating];
    }
    return self;
}
-(instancetype) initWithAnimationData:(NSData*) animationData startImmediately:(BOOL)start {
    self = [self init];
    self.animatedGif = [AnimatedGif getAnimationForGifWithData:animationData];
    if (start) {
        [self startAnimating];
    }
    return self;
}
-(void)setAnimatedGif:(AnimatedGif *)animatedGif {
    //This is workaround for subclasses of UIImageView
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [NSMutableDictionary new];
    });
    if (!swizzledClasses[NSStringFromClass(self.class)]) {
        Swizzle([self class], @selector(willMoveToSuperview:), @selector(willMoveToSuperviewGif:));
        swizzledClasses[NSStringFromClass(self.class)] = @YES;
    }
    
    if (self.animatedGif != animatedGif) {
        [self.animatedGif stop];
    }
    objc_setAssociatedObject(self, &UIViewAnimationKey, animatedGif, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    animatedGif.parentView = self;
}
-(void)setAnimatedGif:(AnimatedGif *)animatedGif startImmediately:(BOOL)start {
    self.animatedGif = animatedGif;
    if (start) {
        [self startGifAnimation];
    }
}
-(AnimatedGif *)animatedGif {
    return objc_getAssociatedObject(self, &UIViewAnimationKey);
}
-(void) startGifAnimation {
    [self.animatedGif start];
}
-(void)stopGifAnimation {
    [self.animatedGif stop];
    
}
-(void)willMoveToSuperviewGif:(UIView *)newSuperview {
    if ([self respondsToSelector:@selector(willMoveToSuperviewGif:)]) {
        [self willMoveToSuperviewGif:newSuperview];
    }
    if (newSuperview == nil) {
        [self stopGifAnimation];
        self.animatedGif = nil;
    }
}
-(void)dealloc {
    self.animatedGif = nil;
}
@end
