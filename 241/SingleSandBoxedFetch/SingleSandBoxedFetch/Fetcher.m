//
//  Fetcher.m
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/18/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//
//  see reference in /Users/llv22/Documents/02_apple_programming/05_wwdc/WWDC2012_Session_Code/OS\ X/241\ -\ Cocoa\ Interprocess\ Communication\ with\ XPC/SandboxedFetch2/fetch-service/Fetcher.m 
//

#import "Fetcher.h"

@implementation Fetcher

- (id)initWithReply:(void (^)(NSFileHandle*, NSError*))reply{
    if (self = [super init]) {
        self->replyBlock = reply;
    }
    return (self);
}

- (void)fetchURL:(NSURL *)url
       withReply:(void (^)(NSFileHandle *, NSError *))reply {
    if (![[url scheme] isEqualToString:@"http"]) {
        reply(nil, [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{NSLocalizedDescriptionKey : @"Invalid URL"}]);
        return;
    }
    
    // We'll call back this reply block later. If this were a manual retain/release application, it is required to use 'copy' on this block to make sure it sticks around long enough for us to call it. This is compiled with ARC though, so the compiler will take care of it for us when we do this assignment.
    replyBlock = reply;
    
    // This object will hold the downloaded data.
    receivedData = [NSMutableData new];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSOperationQueue *queue = [NSOperationQueue new];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    // By assigning a delegate queue here, NSURLConnection will use dispatch queues instead of relying on a CFRunLoop being present in the current thread. Since this code is executing in a serial queue provided by NSXPCConnection, this is required.
    [urlConnection setDelegateQueue:queue];
    [urlConnection start];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
    expectedSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    
    // Send progress update to other side. The NSXPCListenerDelegate configured the connection to implement the 'FetchProgress' protocol, so we'll send the progress update message through the connection's remoteObjectProxy.
    double progress = ([receivedData length] / (double)expectedSize) * 100.0;
    if (self.fetchDelegate) {
        [self.fetchDelegate setProgress:progress];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Call back the other side's reply block with the error.
    receivedData = nil;
    replyBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Open a temporary file in the temp directory of the container.
    char *tempname;
    //desc - asprintf() and vasprintf() dynamically allocate a new string with malloc(3).
    if (asprintf(&tempname, "%sfetch.XXXXXXXX", [NSTemporaryDirectory() fileSystemRepresentation]) < 0) {
        replyBlock(nil,
                   [NSError errorWithDomain:NSPOSIXErrorDomain
                                       code:errno
                                   userInfo:@{NSLocalizedDescriptionKey : @"Couldn't get temporary file name"}]
                   );
        return;
    }
    
    int tempFileFD = -1;
    // desc - The mkstemp() function makes the same replacement to the template and creates the template file, mode 0600, returning a file descriptor opened for reading and writing.
    if ((tempFileFD = mkstemp(tempname)) < 0) {
        free(tempname);
        replyBlock(nil,
                   [NSError errorWithDomain:NSPOSIXErrorDomain
                                       code:errno
                                   userInfo:@{NSLocalizedDescriptionKey : @"Couldn't open temporary file"}]
                   );
    }
    
    // Unlink the file so it is removed as soon as it is closed.
    (void)unlink(tempname);
    free(tempname);
    
    // Write the data to the file, and seek to the beginning. Hand ownership of the fd to NSFileHandle.
    NSFileHandle *outFile = [[NSFileHandle alloc] initWithFileDescriptor:tempFileFD closeOnDealloc:YES];
    [outFile writeData:receivedData];
    [outFile seekToFileOffset:0];
    
    // Clear out our received data, then send the file handle back to the main process.
    receivedData = nil;
    replyBlock(outFile, nil);
}

@end
