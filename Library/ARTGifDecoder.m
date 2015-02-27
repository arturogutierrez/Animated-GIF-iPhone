//
//  ARTGifDecoder.m
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import "ARTGifDecoder.h"
#import "ARTDataStream.h"
#import "ARTAnimatedGifFrame.h"

// ,
#define kImageBlockSentinel 0x2C
// !
#define kExtensionBlockSentinel 0x21
// ;
#define kTrailer 0x3B

@interface ARTGifDecoder ()

@end

@implementation ARTGifDecoder

- (NSArray *)decodeWithData:(NSData *)data
{
    NSMutableArray *frames = [NSMutableArray new];

    NSData *GIF_global;
    NSData *GIF_screen;
    NSData *GIF_frames;
    
    int GIF_sorted;
    int GIF_colorS;
    int GIF_colorC;
    int GIF_colorF;
    
    ARTDataStream *stream = [[ARTDataStream alloc] initWithData:data];
    
    // Jumping GIF89a
    [stream skipBytes:6];
    // Logical screen descriptor
    GIF_screen = [stream readBytes:7];
    
    // Copy the read bytes into a local buffer on the stack
    // For easy byte access in the following lines.
    NSUInteger length = [GIF_screen length];
    unsigned char aBuffer[length];
    [GIF_screen getBytes:aBuffer length:length];
    
    if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
    if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
    GIF_colorC = (aBuffer[4] & 0x07);
    GIF_colorS = 2 << GIF_colorC;
    
    if (GIF_colorF == 1)
    {
        GIF_global = [stream readBytes:3 * GIF_colorS];
    }
    
    while (!stream.endOfFile)
    {
        unsigned char byte = [stream nextByte];
        
        if (byte == kTrailer)
        { // This is the end
            break;
        }
        
        switch (byte)
        {
            case kExtensionBlockSentinel:
                // Graphic Control Extension (#n of n)
                [self GIFReadExtensions:stream frames:frames];
                break;
            case kImageBlockSentinel:
                // Image Descriptor (#n of n)
                [self GIFReadDescriptor:stream frames:frames GIF_sorted:GIF_sorted GIF_screen:GIF_screen GIF_global:GIF_global];
                break;
        }
    }
    
    
    return frames;
}

#pragma mark - Private methods

- (void)GIFReadExtensions:(ARTDataStream *)stream frames:(NSMutableArray *)frames
{
    // 21! But we still could have an Application Extension,
    // so we want to check for the full signature.
    unsigned char cur, prev = 0;
    
    cur = [stream nextByte];
    while (cur != 0x00)
    {
        // TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
        //       should check whether this combo follows directly after the 21.
        if (cur == 0x04 && prev == 0xF9)
        {
            NSData *data = [stream readBytes:5];
            
            ARTAnimatedGifFrame *frame = [[ARTAnimatedGifFrame alloc] init];
            
            unsigned char buffer[5];
            [data getBytes:buffer length:5];
            frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
            //NSLog(@"flags=%x, dm=%x", (int)(buffer[0]), frame.disposalMethod);
            
            // We save the delays for easy access.
            frame.delay = (buffer[1] | buffer[2] << 8);
            
            unsigned char board[8];
            board[0] = 0x21;
            board[1] = 0xF9;
            board[2] = 0x04;
            
            for(int i = 3, a = 0; a < 5; i++, a++)
            {
                board[i] = buffer[a];
            }
            
            frame.header = [NSData dataWithBytes:board length:8];
            
            [frames addObject:frame];
            break;
        }
        
        prev = cur;
        cur = [stream nextByte];
    }
}


- (void)GIFReadDescriptor:(ARTDataStream *)stream frames:(NSMutableArray *)frames GIF_sorted:(char)sorted GIF_screen:(NSData *)GIF_screen GIF_global:(NSData *)GIF_global
{
    NSData *GIF_screenTmp = [stream readBytes:9];
    
    unsigned char aBuffer[9];
    [GIF_screenTmp getBytes:aBuffer length:9];
    
    CGRect rect;
    rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
    rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
    rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
    rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
    
    ARTAnimatedGifFrame *frame = [frames lastObject];
    frame.area = rect;
    
    NSInteger GIF_colorF = 0;
    
    if (aBuffer[8] & 0x80) {
        GIF_colorF = 1;
    } else {
        GIF_colorF = 0;
    }
    
    unsigned char GIF_code = 0, GIF_sort = sorted
    ;
    
    if (GIF_colorF == 1)
    {
        GIF_code = (aBuffer[8] & 0x07);
        
        if (aBuffer[8] & 0x20)
        {
            GIF_sort = 1;
        }
        else
        {
            GIF_sort = 0;
        }
    }
    
    int GIF_size = (2 << GIF_code);
    
    size_t blength = [GIF_screen length];
    unsigned char bBuffer[blength];
    [GIF_screen getBytes:bBuffer length:blength];
    
    bBuffer[4] = (bBuffer[4] & 0x70);
    bBuffer[4] = (bBuffer[4] | 0x80);
    bBuffer[4] = (bBuffer[4] | GIF_code);
    
    if (GIF_sort)
    {
        bBuffer[4] |= 0x08;
    }
    
    NSMutableData *GIF_string = [NSMutableData dataWithData:[@"GIF89a" dataUsingEncoding: NSUTF8StringEncoding]];
    //[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: [NSData dataWithBytes:bBuffer length:blength]];
    
    if (GIF_colorF == 1)
    {
        NSData *data = [stream readBytes:3 * GIF_size];
        [GIF_string appendData:data];
    }
    else
    {
        [GIF_string appendData:GIF_global];
    }
    
    // Add Graphic Control Extension Frame (for transparancy)
    [GIF_string appendData:frame.header];
    
    char endC = 0x2c;
    [GIF_string appendBytes:&endC length:sizeof(endC)];
    
    size_t clength = [GIF_screenTmp length];
    unsigned char cBuffer[clength];
    [GIF_screenTmp getBytes:cBuffer length:clength];
    
    cBuffer[8] &= 0x40;
    
    
    [GIF_string appendData: [NSData dataWithBytes:cBuffer length:clength]];
    [GIF_string appendData: [stream readBytes:1]];

    while (true)
    {
     
        uint8_t byte = [stream nextByte];
        [GIF_string appendBytes:&byte length:sizeof(byte)];
        
        long u = (long) byte;
        
        if (u != 0x00)
        {
            NSData *data = [stream readBytes:u];
            [GIF_string appendData:data];
        }
        else
        {
            break;
        }
        
    }
    
    endC = 0x3b;
    [GIF_string appendBytes:&endC length:sizeof(endC)];
    
    // save the frame into the array of frames
    frame.data = GIF_string;
}

@end
