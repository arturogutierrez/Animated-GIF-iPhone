//
//  AnimatedGifExampleAppDelegate.m
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

#import <UIKit/UIKit.h>
#import "AnimatedGifExampleAppDelegate.h"
#import "AnimatedGifExampleViewController.h"

@interface AnimatedGifExampleAppDelegate()
@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) AnimatedGifExampleViewController *viewController;

@end

@implementation AnimatedGifExampleAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    self.mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.viewController = [[AnimatedGifExampleViewController alloc] init];
    
    // Override point for customization after app launch
    [self.mainWindow addSubview:self.viewController.view];
    [self.mainWindow makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


@end
