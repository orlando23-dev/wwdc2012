//
//  Fetcher.h
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/18/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fetcher : NSObject{
    NSMutableData *receivedData;
    NSURLConnection *urlConnection;
    long long expectedSize;
    void (^replyBlock)(NSFileHandle *, NSError *);
}

- (void)setProgress:(double)progress;
- (void)fetchURL:(NSURL *)url
       withReply:(void (^)(NSFileHandle *, NSError *))reply;

@end
