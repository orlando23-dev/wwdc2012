//
//  Zipper.m
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/18/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import "Zipper.h"
#import <zlib.h>

@implementation Zipper

#define ZIP_BUF_SIZE	16384

/**
 * refactoring with c, don't use goto any more.
 *
 */
// Given an input and output file, compress the input into the output using
// the gzip algorithm (using given compression level and strategy).
//
// Return Z_OK on success.  Otherwise return a zlib error.
static int zip_compress_file(int infd, int outfd, int level, int strategy,
                             const char **errmsg)
{
    int err = Z_OK;
    int len;
    uint8_t *buf = NULL;
    gzFile gzoutfp = NULL;
    char mode[5] = "wb  ";
    bool _isSuccess = true;
    
    // Build mode argument for gzdopen().
    if (level < 1 || level > 9)
	    level = 6;
    mode[2] = '0' + level;
    switch (strategy) {
        case Z_FILTERED:
            mode[3] = 'f';
            break;
        case Z_HUFFMAN_ONLY:
            mode[3] = 'h';
            break;
        case Z_RLE:
            mode[3] = 'R';
            break;
        case Z_FIXED:
            mode[3] = 'F';
            break;
        default:
            mode[3] = '\0';
            break;
    }
    
    if ((buf = (uint8_t *)malloc(ZIP_BUF_SIZE)) == NULL) {
        err = Z_MEM_ERROR;
        if (errmsg){
            *errmsg = "Out of memory";
        }
//        goto errout;
        _isSuccess = false;
    }
    else{
        // Use zlib gzip wrapper functions to do the compression.
        if ((gzoutfp = gzdopen(outfd, mode)) == NULL) {
            err = Z_ERRNO;
            if (errmsg){
                *errmsg = "Can't not gzdopen() output file";
            }
//            goto errout;
            _isSuccess = false;
        }
        while(_isSuccess) {
            if ((len = (int)read(infd, buf, ZIP_BUF_SIZE)) < 0) {
                err = Z_ERRNO;
                if (errmsg){
                    *errmsg = "Can't read input";
                }
//                goto errout;
                _isSuccess = false;
            }
        
            if (0 == len)
                break;
            // desc - if compressed failed before, just stop loop
            if (!_isSuccess) {
                break;
            }
        
            if (gzwrite(gzoutfp, buf, len) != len) {
                if (errmsg){
                    *errmsg = gzerror(gzoutfp, &err);
                }
//                goto errout;
                _isSuccess = false;
            }
        }//end...while
    }//end...else
    
//errout:
    if (buf)
	    free(buf);
    if (gzoutfp)
	    gzclose(gzoutfp);
    return (err);
}

+ (Zipper *)sharedZipper {
    static dispatch_once_t onceToken;
    static Zipper *shared;
    // desc - see http://developer.apple.com/library/ios/#documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html
    //      Executes a block object once and only once for the lifetime of an application.
    dispatch_once(&onceToken, ^{
        shared = [Zipper new];
    });
    return shared;
}

// This method will handle compressing a file. Note that NSFileHandle works together with NSXPCConnection, to allow an open file to be automatically passed from one application to another. The zip service itself does not have permissions to access arbitary files. It will be allowed to talk only to the file that it is given from the main GUI application.
- (void)compressFile:(NSFileHandle *)inFile
              toFile:(NSFileHandle *)outFile
           withReply:(void (^)(NSError *error))reply {
    int64_t errcode = 0;
    const char *errmsg = NULL;
    int infd = [inFile fileDescriptor];
    int outfd = [outFile fileDescriptor];
    if (infd == -1 || outfd == -1) {
        errcode = Z_ERRNO;
        errmsg = "Invalid file descriptor(s)";
    } else {
        errcode = zip_compress_file(infd, outfd, 6, 0, &errmsg);
    }
    
    // Create an error object to pass back, if appropriate.
    NSError *error = nil;
    if (errcode) {
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errcode userInfo:nil];
    }
    
    // Invoke the reply block, which will send a response back to the main application to let it know that we are finished.
    reply(error);
}

@end
