//
//  AppDelegate.h
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/11/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Zipper.h"
#import "Fetcher.h"

@interface AppDelegate : NSObject <FetchProgress, NSApplicationDelegate>{
@private
    // desc - proxy for downloading and compressing
    Zipper* zipper;
    Fetcher* fetcher;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *compressCheckbox;
@property (assign) IBOutlet NSButton *fetchButton;
@property (assign) IBOutlet NSTextField *sourceURL;

@property (assign) IBOutlet NSPanel *progressPanel;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSButton *progressCancelButton;
@property (copy) NSString *progressMessage;

- (IBAction)fetch:(id)sender;
- (IBAction)cancel:(id)sender;

@end
