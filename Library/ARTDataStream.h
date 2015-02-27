//
//  ARTDataStream.h
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARTDataStream : NSObject

- (instancetype)initWithData:(NSData *)data;

- (void)skipBytes:(NSUInteger)numBytes;
- (NSData *)readBytes:(NSUInteger)length;
- (unsigned char)nextByte;

@property (nonatomic, readonly) BOOL endOfFile;

@end
