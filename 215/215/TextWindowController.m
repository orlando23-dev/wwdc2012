//
//  TextWindowController.m
//  215
//
//  Created by Ding Orlando on 8/2/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import "TextWindowController.h"

@interface TextWindowController ()

-(void)enumerateByWords;
-(void)enumerateByWordsSlowly;

@end

@implementation TextWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here -> Not valid here, as it's not intialized.
//         if(_textview){
//            NSLog(@"%@", _textview);
//        }
    }
    
    return self;
}


#pragma window lifecycle - just for controller loading *** NOT VALID ***
-(void)windowWillLoad
{
//    NSLog(@"%@", @"windowWillLoad");
}

#pragma window lifecycle - just for controller loading *** NOT VALID ***
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.-> windows controller initialization from NIB
}

#pragma current Nib loading logic - _textview loading content via GCD
//TODO : http://stackoverflow.com/questions/3956349/nstextview-loading-rtf-view-does-not-update-correctly-until-mouse-is-moved-ove
- (void)awakeFromNib
{
//  NSLog(@"%@", @"awakeFromNib");
    if(_textview){
        //TODO : GCD loading text logic asynchronously
        dispatch_async(dispatch_get_main_queue(), ^{
//           BOOL result = [_textview readRTFDFromFile:@"/Users/llv22/Documents/02_apple_programming/05_wwdc/devcode/readme.rtf"];
//            NSLog(@"%d", result);
            //TODO : read abosutely path content - https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Strings/Articles/readingFiles.html
            NSBundle * myMainBundle = [NSBundle mainBundle];
            NSString * rtfFilePath = [myMainBundle pathForResource:@"readme" ofType:@"rtf"];
            assert([_textview readRTFDFromFile:rtfFilePath]);
        });
    }
}

//TODO : switch case for implementation of NSMatrix
-(IBAction)changeSelector:(id)sender{
    NSMatrix* _optionMatrix = (NSMatrix*)sender;
    /* selected target NSButtonCell instance
     NSButtonCell* _selectedCell = (NSButtonCell*)_optionMatrix.selectedCell;
     NSLog(@"%@", _selectedCell.title);
     */
    int _selectedIndex = (int)_optionMatrix.selectedRow;
    switch (_selectedIndex) {
        case 0:
            break;
        case 1:
            [self enumerateByWords];
            break;
        case 2:
            [self enumerateByWordsSlowly];
            break;
        default:
            break;
    }
}

-(void)enumerateByWords{
    NSString* strContent = [_textview string];
    id color = [NSColor redColor];
    NSRange range = NSMakeRange(0, [strContent length]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [strContent enumerateSubstringsInRange:range
                                   options:NSStringEnumerationByWords
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                    [[_textview textStorage]addAttribute:NSForegroundColorAttributeName value:color range:substringRange];
                                }
         ];
    });
}

-(void)enumerateByWordsSlowly{
    
}

@end
