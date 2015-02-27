//
//  ARTGifDecoder.h
//  AnimatedGif
//
//  Created by Arturo Gutierrez on 27/02/15.
//  Copyright (c) 2015 Arturo Gutierrez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARTGifDecoder : NSObject

- (NSArray *)decodeWithData:(NSData *)data;

@end
