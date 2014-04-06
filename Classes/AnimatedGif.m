//
//  AnimatedGif2.m
//  AnimatedGifExample
//
//  Created by Roman Truba on 07.04.14.
//
//
#import <objc/runtime.h>
#import "AnimatedGif.h"

@interface AnimatedGif ()
{
    BOOL isKilled;
}
-(void) kill;
@end


static void *UIViewAnimationKey;
@implementation UIView (Animated)

-(void)setAnimationGif:(AnimatedGif *)animationGif {
    [self.animationGif kill];
    objc_setAssociatedObject(self, &UIViewAnimationKey, animationGif, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(AnimatedGif *)animationGif {
    return objc_getAssociatedObject(self, &UIViewAnimationKey);
}

@end

@implementation AnimatedGifFrame

- (void) dealloc
{
    _data = nil;
    _header = nil;
}
@end

#define ANIMATED_GIF_CENTER_IN_VIEW(parent, view) CGRectMake(0, (parent.frame.size.height - view.frame.size.height) / 2, parent.frame.size.width, view.frame.size.height)
@implementation AnimatedGifProgressImageView

-(id)init {
    self = [super init];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.progressView = [[UIProgressView alloc] init];
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self addSubview:_progressView];
    return self;
}
-(void)removeFromSuperview {
    self.animationGif = nil;
    [super removeFromSuperview];
}
-(void)willMoveToSuperview:(UIView *)newSuperview {
    self.superview.animationGif = nil;
    if (newSuperview == nil) {
        self.animationGif = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:AnimatedGifRemovedFromSuperview object:self userInfo:nil];
        return;
    }
    
    self.frame = CGRectMake(0, 0, newSuperview.frame.size.width, newSuperview.frame.size.height);
    //    CGRect parentFrame = newSuperview.frame, progressFrame = self.progressView.frame;
    self.progressView.frame = ANIMATED_GIF_CENTER_IN_VIEW(newSuperview, _progressView);
    self.activityView.frame = ANIMATED_GIF_CENTER_IN_VIEW(newSuperview, _activityView);
}

-(void)replaceToIndeterminate {
    [_progressView removeFromSuperview];
    [self addSubview:_activityView];
    [_activityView startAnimating];
}
-(void) hideProgress {
    [self.progressView removeFromSuperview];
    [self.activityView removeFromSuperview];
    
    self.progressView = nil;
    self.activityView = nil;
}
-(void) sizeToParent {
    self.frame = CGRectMake(0, 0, self.superview.frame.size.width, self.superview.frame.size.height);
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
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (!_data) {
        expectedGifSize = response.expectedContentLength;
        if (expectedGifSize > 0) {
            _data = [NSMutableData dataWithCapacity:expectedGifSize];
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
    NSLog(@"Deallocated %@", self);
    _didLoadBlock                = nil;
    _loadingProgressChangedBlock = nil;
}
@end

@interface AnimatedGif ()
@property (nonatomic, strong) AnimatedGifQueueObject * queueObject;
@end

@implementation AnimatedGif
-(void)dealloc {
    NSLog(@"Deallocated %@", self);
}
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
-(id)init {
    self = [super init];
    self.gifView = [AnimatedGifProgressImageView new];
    self.gifView.animationGif = self;
    return self;
}
- (void)setPreview:(UIImage *)newPreview {
    preview = newPreview;
    self.gifView.image = preview;
}
- (void)insertToView:(UIView *)parentView {
    [parentView addSubview:self.gifView];
    parentView.animationGif = self;
}
- (void)kill {
    if (isKilled) return;
    isKilled = YES;
    [self stop];
    [self.gifView removeFromSuperview];
    self.gifView = nil;
    self.queueObject = nil;
    
    lastImage = preview = nil;
    lastFrame = thisFrame = nil;
    
    GIF_pointer = nil;
    GIF_buffer  = nil;
    GIF_screen  = nil;
    GIF_global  = nil;
}
- (void) stop {
    [thisGifThread cancel];
    thisGifThread = nil;
    if (preview) {
        [self setPreview:preview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) start {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifViewRemovedFromSuperview:) name:AnimatedGifRemovedFromSuperview object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AnimatedGifDidStartLoadingingEvent object:self userInfo:nil];
    if (self.queueObject.data) {
        [self startThreadWithData:self.queueObject.data];
    } else if ([self.queueObject.url isFileURL]) {
        [self startThreadWithData:[NSData dataWithContentsOfURL:self.queueObject.url]];
    } else if (self.queueObject.url) {
        __weak AnimatedGif * wself = self;
        [self.queueObject setLoadingProgressChangedBlock:^(AnimatedGifQueueObject *obj) {
            wself.gifView.progressView.progress = obj.loadingProgress;
        }];
        [self.queueObject setDidLoadBlock:^(AnimatedGifQueueObject *obj) {
            [wself startThreadWithData:obj.data];
        }];
        [self.queueObject downloadGif];
    }
}
- (void) gifViewRemovedFromSuperview:(NSNotification*) notify {
    if (notify.object == self.gifView) {
        [self kill];
    }
}

- (void) startThreadWithData:(NSData*) gifData {
    [[NSNotificationCenter defaultCenter] postNotificationName:AnimatedGifDidFinishLoadingingEvent object:self userInfo:nil];
    [self.gifView replaceToIndeterminate];
    thisGifThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeGIF:) object:gifData];
    thisGifThread.name = @"Gif thread";
    [thisGifThread start];
}

- (void)decodeGIF:(NSData *)GIFData
{
    while (![[NSThread currentThread] isCancelled]) {
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
            
            
            while ([self GIFGetBytes:1] == YES && ![[NSThread currentThread] isCancelled])
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
            }
            
            // clean up stuff
            GIF_buffer = nil;
            GIF_screen = nil;
            GIF_global = nil;
        }
    }

}

//
// This method converts the arrays of GIF data to an animation, counting
// up all the seperate frame delays, and setting that to the total duration
// since the iPhone Cocoa framework does not allow you to set per frame
// delays.
//
// Returns nil when there are no frames present in the GIF, or
// an autorelease UIImageView* with the animation.
- (void) drawNextFrame:(AnimatedGifFrame*) frame
{
    @autoreleasepool {
//        frameTime = [NSDate new];
        // Add all subframes to the animation
        UIImage * image = [UIImage imageWithData:frame.data];
        if (!image) return;
        
        UIImage *overlayImage;
        CGSize size = image.size;
        CGRect rect = CGRectZero;
        rect.size = size;
        
        UIGraphicsBeginImageContext(size);
        CGContextRef imageContext = UIGraphicsGetCurrentContext();
        if (lastImage) {
            CGContextDrawImage(imageContext, rect, lastImage.CGImage);
        }
        
        // Initialize Flag
        UIImage *previousCanvas = nil;
        
        // Save Context
        CGContextSaveGState(imageContext);
        // Change CTM
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
                previousCanvas = UIGraphicsGetImageFromCurrentImageContext();
                
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
        // Add Image created (only if the delay > 0)
        if (frame.delay > 0)
        {
            overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        // Set Last Frame
        lastFrame = frame;
        
        // Disposal Method (Operations afte draw frame)
        switch (frame.disposalMethod)
        {
            case 2: // Restore to background color the zone of the actual frame
                // Save Context
                CGContextSaveGState(imageContext);
                // Change CTM
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
                // Change CTM
                CGContextScaleCTM(imageContext, 1.0, -1.0);
                CGContextTranslateCTM(imageContext, 0.0, -size.height);
                // Clear Context
                CGContextClearRect(imageContext, lastFrame.area);
                // Draw previous frame
                CGContextDrawImage(imageContext, rect, previousCanvas.CGImage);
                // Restore State
                CGContextRestoreGState(imageContext);
                break;
        }
        UIGraphicsEndImageContext();
        
        // Count up the total delay, since Cocoa doesn't do per frame delays.
    //    double total = 0;
    //    for (AnimatedGifFrame2 *frame in GIF_frames) {
    //        total += frame.delay;
    //    }
        NSDate * now = [NSDate new];
        CGFloat frameDelay = frame.delay / 100, processTime = [now timeIntervalSinceDate:frameTime];
        CGFloat threadDelay = frameDelay - processTime;
        frameTime = now;
        if (threadDelay < 0) threadDelay = 0;
        [NSThread sleepForTimeInterval:threadDelay];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!lastImage && _willShowFrameBlock) {
                _willShowFrameBlock(self, overlayImage);
            }
            [self.gifView hideProgress];
            [self.gifView setImage:overlayImage];
        });
        lastImage = overlayImage;
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
	
	while (true && ![[NSThread currentThread] isCancelled])
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
