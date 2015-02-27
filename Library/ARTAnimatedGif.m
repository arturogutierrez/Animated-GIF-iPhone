//
//  ARTAnimatedGif.m
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import "ARTAnimatedGif.h"
#import "ARTGifDecoder.h"

@interface ARTAnimatedGif ()

@property (nonatomic, strong) NSArray *frames;

@end

@implementation ARTAnimatedGif

#pragma mark - Initialising

- (instancetype)initWithContentsOfFile:(NSString *)path
{
    return [self initWithData:[NSData dataWithContentsOfFile:path]];
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self decodeGif:data];
    }
    return self;
}

#pragma mark - Class methods

+ (ARTAnimatedGif *)imageNamed:(NSString *)name
{
    return nil;
}

#pragma mark - Private methods

- (void)decodeGif:(NSData *)data
{
    ARTGifDecoder *gifDecoder = [[ARTGifDecoder alloc] init];
    self.frames = [gifDecoder decodeWithData:data];
}
    

@end
