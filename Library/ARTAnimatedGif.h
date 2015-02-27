//
//  ARTAnimatedGif.h
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARTAnimatedGif : NSObject

+ (ARTAnimatedGif *)imageNamed:(NSString *)name;

- (instancetype)initWithContentsOfFile:(NSString *)path;
- (instancetype)initWithData:(NSData *)data;

@end
