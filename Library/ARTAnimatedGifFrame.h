//
//  ARTAnimatedGifFrame.h
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARTAnimatedGifFrame : NSObject

@property (nonatomic, strong) NSData *header;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) CGFloat delay;
@property (nonatomic) NSUInteger disposalMethod;
@property (nonatomic) CGRect area;

@end
