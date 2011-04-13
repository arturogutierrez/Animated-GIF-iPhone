//
//  AnimatedGifExampleAppDelegate.h
//  AnimatedGifExample
//
//  Created by Stijn Spijker on 05-07-09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnimatedGifExampleViewController;

@interface AnimatedGifExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    AnimatedGifExampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AnimatedGifExampleViewController *viewController;

@end

