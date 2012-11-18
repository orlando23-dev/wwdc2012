//
//  AppDelegate.m
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/11/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import "AppDelegate.h"

//TODO : download url - http://images.apple.com/ipad/overview/images/hero_slide1.png

// TODO : see http://stackoverflow.com/questions/6828831/sending-const-nsstring-to-parameter-of-type-nsstring-discards-qualifier
// for issues
///Users/llv22/Documents/02_apple_programming/05_wwdc/devcode/wwdc2012/241/SingleSandBoxedFetch/SingleSandBoxedFetch/AppDelegate.m:21:39: Sending 'const NSString *__strong' to parameter of type 'NSString *' discards qualifiers
NSString* const _strSourceURL = @"sourceURL";
NSString* const _strLastFetchURL = @"LastFetchURL";

@interface AppDelegate (PrivateMethods)

- (void)resetDownloadPanelToStart;

@end

@implementation AppDelegate

#pragma mark - progress panel sheet

// TODO : startProgressPanelWithMessage
- (void)startProgressPanelWithMessage:(NSString *)message indeterminate:(BOOL)indeterminate {
    // Display a progress panel as a sheet
    self.progressMessage = message;
    if (indeterminate) {
        [self.progressIndicator setIndeterminate:YES];
    } else {
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setDoubleValue:0.0];
    }
    [self.progressIndicator startAnimation:self];
    [self.progressCancelButton setEnabled:NO];
    [NSApp beginSheet:self.progressPanel
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:NULL];
}

#pragma mark - application termination

- (void)applicationWillFinishLaunching:(NSNotification*)aNotification {
    [self addObserver:self forKeyPath:_strSourceURL options:NSKeyValueObservingOptionNew context: NULL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *lastFetchURL = [[NSUserDefaults standardUserDefaults] stringForKey:_strLastFetchURL];
    if (lastFetchURL) {
        [self.sourceURL setStringValue:lastFetchURL];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return (YES);
}

#pragma mark - Button action of fetch download resource and cancel download 

// TODO : Fetch Action
- (IBAction)fetch:(id)sender{
    // desc - reset UI status
    [self resetDownloadPanelToStart];
}

// TODO : reset DownloadPanel with initialization of "Downloading Message" and fetch url
- (void)resetDownloadPanelToStart {
    [[NSUserDefaults standardUserDefaults] setObject:[self.sourceURL stringValue] forKey:_strLastFetchURL];
    [self startProgressPanelWithMessage:@"Downloading..." indeterminate:NO];
}

//TODO : Save Panel Sheet
- (IBAction)cancel:(id)sender{
    
}


@end
