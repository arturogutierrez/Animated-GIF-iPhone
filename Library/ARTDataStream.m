//
//  ARTDataStream.m
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import "ARTDataStream.h"

@interface ARTDataStream ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) NSUInteger pointer;

@end

@implementation ARTDataStream

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _data = data;
        _pointer = 0;
    }
    return self;
}

- (void)skipBytes:(NSUInteger)numBytes
{
    self.pointer = MIN(self.pointer + numBytes, self.data.length);
}

- (NSData *)readBytes:(NSUInteger)length
{
    length = MIN(self.data.length - self.pointer, length);
    NSData *data = [self.data subdataWithRange:NSMakeRange(self.pointer, length)];
    [self skipBytes:length];

    return data;
}

- (unsigned char)nextByte
{
    unsigned char buffer[1];
    [[self readBytes:1] getBytes:buffer length:1];
    
    return buffer[0];
}


- (BOOL)isEndOfFile
{
    return self.pointer >= self.data.length;
}

- (NSUInteger)pointer
{
    return _pointer;
}

@end
