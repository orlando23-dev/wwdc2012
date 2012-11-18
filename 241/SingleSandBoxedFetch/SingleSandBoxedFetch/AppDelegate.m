//
//  AppDelegate.m
//  SingleSandBoxedFetch
//
//  Created by Ding Orlando on 11/11/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

#pragma mark - application termination

- (void)applicationWillFinishLaunching:(NSNotification*)aNotification {
    [self addObserver:self forKeyPath:@"sourceURL" options:NSKeyValueObservingOptionNew context: NULL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *lastFetchURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFetchURL"];
    if (lastFetchURL) {
        [self.sourceURL setStringValue:lastFetchURL];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return (YES);
}

#pragma mark - Button action of fetch download resource and cancel download 
- (IBAction)fetch:(id)sender{
    
}

- (IBAction)cancel:(id)sender{
    
}


@end
