//
//  TextWindowController.h
//  215
//
//  Created by Ding Orlando on 8/2/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextWindowController : NSWindowController{
    IBOutlet NSTextView* _textview;
}

#pragma comment event handler
-(IBAction)changeSelector:(id)sender;

@end
