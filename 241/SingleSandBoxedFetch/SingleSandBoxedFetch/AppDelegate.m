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
- (void)stopProgressPanel;
- (void)setProgress:(double)progress;

@end

@implementation AppDelegate

#pragma mark Error Alert Sheet

- (void)showErrorAlert:(NSError *)error {
    [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window
                                               modalDelegate:self
                                              didEndSelector:nil
                                                 contextInfo:nil];
}

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

- (void)stopProgressPanel {
    [self.progressPanel orderOut:self];
    [NSApp endSheet:self.progressPanel returnCode:0];
}

- (void)setProgress:(double)progress {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.progressIndicator setDoubleValue:progress];
    }];
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

#pragma mark Save Panel Sheet

- (void)saveFile:(NSFileHandle *)fileHandle
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    NSString *fileName = [[NSURL URLWithString:[self.sourceURL stringValue]] lastPathComponent];
    if ([self.compressCheckbox state] == NSOffState) {
        [savePanel setNameFieldStringValue:fileName];
    } else {
        [savePanel setNameFieldStringValue:[fileName stringByAppendingPathExtension:@"gz"]];
    }
    
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [savePanel orderOut:self];
            
            NSError *error;
            
            if ([self.compressCheckbox state] == NSOffState) {
                [self startProgressPanelWithMessage:@"Copying..." indeterminate:YES];
                
                NSData *fetchedData = [fileHandle availableData];
                BOOL result = [fetchedData writeToURL:[savePanel URL] options:0 error:&error];
                if (!result) {
                    [self showErrorAlert:error];
                }
                
                [self stopProgressPanel];
                [fileHandle closeFile];
                
            } else {
                [self startProgressPanelWithMessage:@"Compressing..." indeterminate:YES];
                
                // Create the file, then create an NSFileHandle to transport it to our zip service.
                if (![[NSData data] writeToURL:[savePanel URL] options:0 error:&error]) {
                    [fileHandle closeFile];
                    [self showErrorAlert:error];
                    return;
                }
                
                // Create an NSFileHandle for transporting to our zip service. By opening it here, we are able to transfer the ability to write to this file to the service even though it does not have permission to open it on its own.
                NSFileHandle *outFile = [NSFileHandle fileHandleForWritingToURL:[savePanel URL] error:&error];
                if (!outFile) {
                    [fileHandle closeFile];
                    [self showErrorAlert:error];
                    return;
                }
                
                // Create a connection to the service and send it the message along with our file handles.
                self->zipper = [[Zipper alloc]init];
                
                [self->zipper compressFile:fileHandle toFile:outFile withReply:^(NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self stopProgressPanel];
                        if (error) {
                            [self showErrorAlert:error];
                        }
                    }];
                }];
            }
        }
        
        [fileHandle closeFile];
    }];
}

#pragma mark - Button action of fetch download resource and cancel download 

// TODO : Fetch Action
- (IBAction)fetch:(id)sender{
    // desc - reset UI status
    [self resetDownloadPanelToStart];
    self->fetcher = [[Fetcher alloc]initWithFetchProgressDelegate:self];
    [self->fetcher fetchURL:[NSURL URLWithString:[self.sourceURL stringValue]]
                  withReply:^(NSFileHandle *fileHandle, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self stopProgressPanel];
            
            if (error) {
                [self showErrorAlert:error];
            } else if ([fileHandle fileDescriptor] == -1) {
                [self showErrorAlert:[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil]];
            } else {
                [self saveFile:fileHandle];
            }
        }];
    }];
}

// TODO : reset DownloadPanel with initialization of "Downloading Message" and fetch url
- (void)resetDownloadPanelToStart {
    [[NSUserDefaults standardUserDefaults] setObject:[self.sourceURL stringValue] forKey:_strLastFetchURL];
    [self startProgressPanelWithMessage:@"Downloading..." indeterminate:NO];
}

//TODO : Cancel downloading
- (IBAction)cancel:(id)sender{
    [self.progressPanel orderOut:self];
    [NSApp endSheet:self.progressPanel returnCode:1];
}


@end
