//
//  Fetcher.h
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/18/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import <Foundation/Foundation.h>

// This is a protocol that describes the responsibility of presenting progress information to the user. The Fetcher object below will report progress as it downloads things.
@protocol FetchProgress
- (void)setProgress:(double)progress;
@end

@interface Fetcher : NSObject<NSURLConnectionDataDelegate>{
    NSMutableData *receivedData;
    NSURLConnection *urlConnection;
    long long expectedSize;
    void (^replyBlock)(NSFileHandle *, NSError *);
}

- (void)fetchURL:(NSURL *)url
       withReply:(void (^)(NSFileHandle *, NSError *))reply;
// This property is a weak reference because the connection will retain this object, so we don't want to create a retain cycle.
@property (weak) id<FetchProgress> fetchDelegate;

@end
