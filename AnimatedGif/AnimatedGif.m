//
//  AnimatedGif2.m
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

#import "AnimatedGif.h"

/**
 * Creates new context for frames drawing.
 */
static CGContextRef CreateARGBBitmapContext(CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = size.width;
    size_t pixelsHigh = size.height;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (NULL,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     (CGBitmapInfo) kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
    
}

/**
 * Describes GIF animation frame
 */
@interface AnimatedGifFrame : NSObject

@property (nonatomic, copy) NSData *header;
@property (nonatomic, copy) NSData *data;
@property (nonatomic, assign) double delay;
@property (nonatomic, assign) int disposalMethod;
@property (nonatomic, assign) CGRect area;
@end

@implementation AnimatedGifFrame

- (void) dealloc
{
    _data = nil;
    _header = nil;
}
@end

@interface AnimatedGifQueueObject ()
{
    NSURLResponse * _urlResponse;
}
@property (nonatomic, copy) void(^loadingProgressChangedBlock)(AnimatedGifQueueObject *object);
@property (nonatomic, copy) void(^didLoadBlock)(AnimatedGifQueueObject *object);
@end

@implementation AnimatedGifQueueObject
- (id)init {
    self = [super init];
    return self;
}
/**
 * Downloads GIF from network, and caches it, if possible. NSURLCache may be removed
 */
- (void) downloadGif {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:5 * 1024 * 1024
                                                             diskCapacity:50 * 1024 * 1024
                                                                 diskPath:nil];
        [NSURLCache setSharedURLCache:URLCache];
    });
    
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    NSCachedURLResponse * response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    if (!response) {
        NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
        return;
    }
    self.data = response.data;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_didLoadBlock) {
            _didLoadBlock(self);
        }
    });
}
#pragma mark - NSURLConnectionDataDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (!_data) {
        expectedGifSize = response.expectedContentLength;
        if (expectedGifSize > 0) {
            _data = [NSMutableData dataWithCapacity:((NSUInteger)expectedGifSize)];
        } else {
            _data = [NSMutableData new];
        }
    }
    _urlResponse = response;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!_data)
        _data = [NSMutableData data];
    [(NSMutableData*)_data appendData:data];
    
    self.loadingProgress = _data.length * 1.0f / expectedGifSize;
    if (expectedGifSize < 0) {
        self.loadingProgress = 0;
    }
    if (_loadingProgressChangedBlock) {
        _loadingProgressChangedBlock(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AnimatedGifLoadingProgressEvent object:self];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self downloadGif];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (expectedGifSize > 0 && _data.length != expectedGifSize) {
        [self downloadGif];
        return;
    }
    NSCachedURLResponse * response = [[NSCachedURLResponse alloc] initWithResponse:_urlResponse data:_data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    [[NSURLCache sharedURLCache] storeCachedResponse:response forRequest:connection.originalRequest];
    if (_didLoadBlock) {
        _didLoadBlock(self);
    }
    
}

-(void)dealloc {
    _didLoadBlock                = nil;
    _loadingProgressChangedBlock = nil;
}
@end


@interface AnimatedGif ()
{
    NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
    NSDate * frameTime;
    CGContextRef imageContext;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int dataPointer;
    int totalFrames;
    
    BOOL didShowFrame, didCountAllFrames;
    
    AnimatedGifFrame *thisFrame, *lastFrame;
    UIImage * overlayImage;
    NSOperationQueue *opQueue;
    
}
@property (nonatomic, strong) AnimatedGifQueueObject * queueObject;
@end

@implementation AnimatedGif
+(AnimatedGif *)getAnimationForGifAtUrl:(NSURL *)animationUrl {
    AnimatedGifQueueObject * object = [AnimatedGifQueueObject new];
    object.url = animationUrl;
    
    AnimatedGif * animation = [AnimatedGif new];
    animation.queueObject = object;
    return animation;
}

+(AnimatedGif *)getAnimationForGifWithData:(NSData *)data {
    AnimatedGifQueueObject * object = [AnimatedGifQueueObject new];
    object.data = data;
    
    AnimatedGif * animation = [AnimatedGif new];
    animation.queueObject = object;
    return animation;
}

-(void)dealloc {
    [opQueue waitUntilAllOperationsAreFinished];
    opQueue = nil;
    if (imageContext)
        CGContextRelease(imageContext);
    overlayImage = nil;
}

-(NSURL *)url {
    return self.queueObject.url;
}

- (void) stop {
    [opQueue cancelAllOperations];
    [opQueue setSuspended:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) start {
    didShowFrame = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:AnimatedGifDidStartLoadingingEvent object:self userInfo:nil];
    if (self.queueObject.data) {
        [self startThreadWithData:self.queueObject.data];
    } else if ([self.queueObject.url isFileURL]) {
        [self startThreadWithData:[NSData dataWithContentsOfURL:self.queueObject.url]];
    } else if (self.queueObject.url) {
        __weak AnimatedGif * wself = self;
        [self.queueObject setLoadingProgressChangedBlock:^(AnimatedGifQueueObject *obj) {
            if (wself.loadingProgressBlock) {
                wself.loadingProgressBlock(wself, obj.loadingProgress);
            }
        }];
        [self.queueObject setDidLoadBlock:^(AnimatedGifQueueObject *obj) {
            [wself startThreadWithData:obj.data];
        }];
        [self.queueObject downloadGif];
    }
}

- (void) startThreadWithData:(NSData*) gifData {
    [[NSNotificationCenter defaultCenter] postNotificationName:AnimatedGifDidFinishLoadingingEvent object:self userInfo:nil];
    if (!opQueue) {
        opQueue = [[NSOperationQueue alloc] init];
        opQueue.maxConcurrentOperationCount = 1;
    }
    [opQueue addOperation:[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(decodeGIF:) object:gifData]];
    
}

/**
 * Main GIF loop. Decodes gif data and draws it on parent view.
 */
- (void)decodeGIF:(NSData *)GIFData
{
    opQueue.name = @"Gif queue";
    
    while (!opQueue.isSuspended) {
        @autoreleasepool {
            GIF_pointer = GIFData;
            GIF_buffer = nil;
            GIF_global = nil;
            GIF_screen = nil;
            
            GIF_buffer = [[NSMutableData alloc] init];
            GIF_global = [[NSMutableData alloc] init];
            GIF_screen = [[NSMutableData alloc] init];
            
            thisFrame = lastFrame = nil;
            
            // Reset file counters to 0
            dataPointer = 0;
            
            [self GIFSkipBytes: 6]; // GIF89a, throw away
            [self GIFGetBytes: 7]; // Logical Screen Descriptor
            
            // Deep copy
            [GIF_screen setData: GIF_buffer];
            
            // Copy the read bytes into a local buffer on the stack
            // For easy byte access in the following lines.
            NSInteger length = [GIF_buffer length];
            unsigned char aBuffer[length];
            [GIF_buffer getBytes:aBuffer length:length];
            
            if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
            if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
            GIF_colorC = (aBuffer[4] & 0x07);
            GIF_colorS = 2 << GIF_colorC;
            
            if (GIF_colorF == 1)
            {
                [self GIFGetBytes: (3 * GIF_colorS)];
                
                // Deep copy
                [GIF_global setData:GIF_buffer];
            }
            
            unsigned char bBuffer[1];
            
            
            while ([self GIFGetBytes:1] && !opQueue.isSuspended)
            {
                @autoreleasepool {
                    [GIF_buffer getBytes:bBuffer length:1];
                    
                    if (bBuffer[0] == 0x3B)
                    { // This is the end
                        break;
                    }
                    
                    switch (bBuffer[0])
                    {
                        case 0x21:
                            // Graphic Control Extension (#n of n)
                            [self GIFReadExtensions];
                            break;
                        case 0x2C:
                            frameTime = [NSDate new];
                            // Image Descriptor (#n of n)
                            [self GIFReadDescriptor];
                            break;
                    }
                }
                
                if ([self endOfGifReached:1]) {
                    if ([self.delegate respondsToSelector:@selector(animationWillRepeat:)]) {
                        [self.delegate performSelector:@selector(animationWillRepeat:) withObject:self];
                    }
                }
                
            }
            
            didCountAllFrames = YES;
            // clean up stuff
            GIF_buffer = nil;
            GIF_screen = nil;
            GIF_global = nil;
        }
    }
    
}

/**
 * This method draws next GIF frame on the canvas of imageContext, according disposal method.
 * After frame image is ready, it passes it to main thread and sets to parent image view.
 */
- (void) drawNextFrame:(AnimatedGifFrame*) frame
{
    @autoreleasepool {
        UIImage * image = [UIImage imageWithData:frame.data];
        
        if (!image) return;
        
        CGSize size = image.size;
        CGRect rect = CGRectZero;
        rect.size = size;
        self.animationSize = size;
        
        // Create new bitmap context if need
        if (!imageContext) {
            imageContext = CreateARGBBitmapContext(size);
        }
        
        // Initialize Flag
        UIImage *previousCanvas = nil;
        
        // Save Context
        CGContextSaveGState(imageContext);
        CGContextScaleCTM(imageContext, 1.0, -1.0);
        CGContextTranslateCTM(imageContext, 0.0, -size.height);
        
        // Check if lastFrame exists
        CGRect clipRect;
        
        // Disposal Method (Operations before draw frame)
        switch (frame.disposalMethod)
        {
            case 1: // Do not dispose (draw over context)
                // Create Rect (y inverted) to clipping
                clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
                // Clip Context
                CGContextClipToRect(imageContext, clipRect);
                break;
            case 2: // Restore to background the rect when the actual frame will go to be drawed
                // Create Rect (y inverted) to clipping
                clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
                // Clip Context
                CGContextClipToRect(imageContext, clipRect);
                break;
            case 3: // Restore to Previous
                // Get Canvas
                @autoreleasepool {
                    CGImageRef img = CGBitmapContextCreateImage(imageContext);
                    previousCanvas = [UIImage imageWithCGImage:img];
                    CGImageRelease(img);
                }
                
                // Create Rect (y inverted) to clipping
                clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
                // Clip Context
                CGContextClipToRect(imageContext, clipRect);
                break;
        }
        // Draw Actual Frame
        CGContextDrawImage(imageContext, rect, image.CGImage);
        // Restore State
        CGContextRestoreGState(imageContext);
        // Add Image created.
        @autoreleasepool {
            CGImageRef img = CGBitmapContextCreateImage(imageContext);
            overlayImage = [UIImage imageWithCGImage:img scale:1.0f orientation:UIImageOrientationDownMirrored];
            CGImageRelease(img);
            if (opQueue.isSuspended) {
                return;
            }
        }
        

		
		if (!didCountAllFrames) {
			totalFrames++;
		}
		
        static CGFloat defaultFrameRate = 10;
        if (frame.delay <= 1) {
            frame.delay = defaultFrameRate;
        }
        
        
        // Set Last Frame
        lastFrame = frame;
        
        // Disposal Method (Operations afte draw frame)
        switch (frame.disposalMethod)
        {
            case 2: // Restore to background color the zone of the actual frame
                // Save Context
                CGContextSaveGState(imageContext);
                CGContextScaleCTM(imageContext, 1.0, -1.0);
                CGContextTranslateCTM(imageContext, 0.0, -size.height);
                // Clear Context
                CGContextClearRect(imageContext, clipRect);
                // Restore Context
                CGContextRestoreGState(imageContext);
                break;
            case 3: // Restore to Previous Canvas
                // Save Context
                CGContextSaveGState(imageContext);
                // Clear Context
                CGContextClearRect(imageContext, lastFrame.area);
                // Draw previous frame
                CGContextDrawImage(imageContext, rect, previousCanvas.CGImage);
                // Restore State
                CGContextRestoreGState(imageContext);
                break;
        }
        previousCanvas = nil;
        NSDate * now = [NSDate new];
        CGFloat frameDelay = frame.delay / 100, processTime = [now timeIntervalSinceDate:frameTime];
        CGFloat threadDelay = frameDelay - processTime;
        frameTime = now;
        if (threadDelay < 0) threadDelay = 0;
        
        if (!opQueue.isSuspended) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (!didShowFrame && _willShowFrameBlock) {
                    _willShowFrameBlock(self, overlayImage);
                    //Useless now
                    _willShowFrameBlock = nil;
                     didShowFrame = YES;
                }
                self.parentView.image = overlayImage;
            });
        }
        
        [NSThread sleepForTimeInterval:threadDelay];
    }
    
}


- (void)GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];
    [self GIFGetBytes:1];
    [GIF_buffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
		
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
            
			AnimatedGifFrame *frame = [[AnimatedGifFrame alloc] init];
			
			unsigned char buffer[5];
			[GIF_buffer getBytes:buffer length:5];
			frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
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
            
			thisFrame = frame;
			break;
		}
		
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
	}
}

- (void) GIFReadDescriptor
{
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
	
	unsigned char aBuffer[9];
	[GIF_buffer getBytes:aBuffer length:9];
	
	CGRect rect;
	rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
	rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
	rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
	rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
    
	AnimatedGifFrame *frame = thisFrame;
	frame.area = rect;
	
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	
	unsigned char GIF_code = GIF_colorC, GIF_sort = GIF_sorted;
	
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
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIF_screen];
    
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
		[GIF_string appendData:GIF_buffer];
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
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIF_buffer];
	
	while (true && !opQueue.isSuspended)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIF_buffer];
		
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:1];
		
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:u];
			[GIF_string appendData: GIF_buffer];
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
    [self drawNextFrame:frame];
}

/* Puts (int) length into the GIF_buffer from file, returns whether read was succesfull */
- (bool) GIFGetBytes: (NSInteger) length
{
    if (GIF_buffer != nil)
    {
        GIF_buffer = nil;
    }
    
	if ([GIF_pointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		GIF_buffer = [[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)] mutableCopy];
        dataPointer += length;
		return YES;
	}
    else
    {
        return NO;
	}
}

- (BOOL) endOfGifReached:(NSInteger) length
{
	if ([GIF_pointer length] > dataPointer + length) // Don't read across the edge of the file..
    {
		return NO;
	}

    return YES;
}

/* Skips (int) length bytes in the GIF, faster than reading them and throwing them away.. */
- (bool) GIFSkipBytes: (NSInteger) length
{
    if ([GIF_pointer length] >= dataPointer + length)
    {
        dataPointer += length;
        return YES;
    }
    else
    {
    	return NO;
    }
    
}


@end
