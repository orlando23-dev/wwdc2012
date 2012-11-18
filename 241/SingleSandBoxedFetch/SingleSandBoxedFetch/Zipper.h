//
//  Zipper.h
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/18/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//
//  @see - singleton proxy for zipper helper
//  @see - the original xpc files, /Users/llv22/Documents/02_apple_programming/05_wwdc/WWDC2012_Session_Code/OS\ X/241\ -\ Cocoa\ Interprocess\ Communication\ with\ XPC/SandboxedFetch2/zip-service/Zipper.h
//

#import <Foundation/Foundation.h>

@interface Zipper : NSObject

+ (Zipper *)sharedZipper;

- (void)compressFile:(NSFileHandle *)inFile
              toFile:(NSFileHandle *)outFile
           withReply:(void (^)(NSError *error))reply;

@end
