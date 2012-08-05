//
//  TextWindowController.m
//  215
//
//  Created by Ding Orlando on 8/2/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#import "TextWindowController.h"

@interface TextWindowController ()

-(void)reload;
-(void)fetchDataFinished:(id)valueOfRange;
-(void)enumerateByWords;
-(void)enumerateByWordsSlowly;
-(void)enumerateByString;
-(void)enumerateByWordsForSpecificWord;
-(NSCharacterSet*)quoteCharacterSet;
-(void)enumerateByCharacterSet;
-(BOOL)rangeIsInQuotes:(NSRange)substringRange;
-(void)enumerateByWordsInQuotes;
-(void)enumerateByRegualExpression;
-(void)enumerateByDataDetector;
-(void)enumerateByNouns;
-(void)enumerateByNounsInQuotes;
-(void)enumerateByNames;
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
        [self reload];
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
            [self reload];
            break;
        case 1:
            [self enumerateByWords];
            break;
        case 2:
            [self enumerateByWordsSlowly];
            break;
        case 3:
            [self enumerateByString];
            break;
        case 4:
            [self enumerateByWordsForSpecificWord];
            break;
        case 5:
            [self enumerateByCharacterSet];
            break;
        case 6:
            [self enumerateByWordsInQuotes];
            break;
        case 7:
            [self enumerateByRegualExpression];
            break;
        case 8:
            [self enumerateByDataDetector];
            break;
        case 9:
            [self enumerateByNouns];
            break;
        case 10:
            [self enumerateByNounsInQuotes];
            break;
        case 11:
            [self enumerateByNames];
            break;
        default:
            break;
    }
}

-(void)reload{
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

-(void)enumerateByWords{
    NSString* strContent = [_textview string];
    id color = [NSColor redColor];
    NSRange range = NSMakeRange(0, [strContent length]);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    double delayInSeconds = 0.0;
    dispatch_time_t _tPopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //TODO : dispatch_async
    dispatch_after(_tPopTime, dispatch_get_main_queue(), ^{
        [strContent enumerateSubstringsInRange:range
                                   options:NSStringEnumerationByWords
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                    [[_textview textStorage]addAttribute:NSForegroundColorAttributeName value:color range:substringRange];
                                }
         ];
    });
}

//TODO : http://stackoverflow.com/questions/10883738/nstextview-when-to-automatically-insert-characters-like-auto-matching-parenthe
//TODO : http://borkware.com/quickies/one?topic=NSTextView
//TODO : Colorized NSTextView http://topdraw.googlecode.com/svn-history/r154/trunk/Editor/ColorizingTextView.m
-(void)enumerateByWordsSlowly{
    NSString* strContent = [_textview string];
    long lfullTextLength = [strContent length];
    NSRange range = NSMakeRange(0, lfullTextLength);
    //TODO : remove existing color font
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    __block NSRange _substringRange;
    __block NSRange _enclosingRange = NSMakeRange(0, 0);
    long _leftlen = lfullTextLength;
    //TODO : submit to MachQueue with performSelector via increasing delta delay;
    double _timesleep = 0.001;
    long _counter = 0;
    
    do{
        //TODO : http://developer.apple.com/library/ios/#documentation/cocoa/reference/foundation/Classes/NSValue_Class/Reference/Reference.html#//apple_ref/occ/clm/NSValue/valueWithRange:
        [strContent enumerateSubstringsInRange:range
                                       options:NSStringEnumerationByWords
                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                        *stop = YES;
                                        _substringRange = substringRange;
                                        _enclosingRange = enclosingRange;
                                    }
         ];
        NSValue* _substringValueRange = [NSValue valueWithRange:_substringRange];
        [self performSelector:@selector(fetchDataFinished:) withObject:_substringValueRange afterDelay:_timesleep];
        if(_counter % 3 == 0){
            _timesleep += _timesleep/2.0;
        }
        _counter++;
        long _lEndWordLocation = _enclosingRange.location + _enclosingRange.length;
        _leftlen = lfullTextLength - _lEndWordLocation;
        //TODO : end of _lEndWordLocation may the next start index
        range = NSMakeRange(_lEndWordLocation, _leftlen);
    }while (_leftlen > 0);
}

#pragma comment delay caller/callee method
-(void)fetchDataFinished:(id)valueOfRange{
    id color = [NSColor redColor];
    NSValue* _value = (NSValue*)valueOfRange;
    NSRange substringRange = [_value rangeValue];
    [[_textview textStorage]addAttribute:NSForegroundColorAttributeName value:color range:substringRange];
}

-(void)enumerateByString{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    long lfullTextLength = [_strContent length];
    NSRange range = NSMakeRange(0, lfullTextLength);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    
    NSRange stringRange = NSMakeRange(0, 0);
    while (NSMaxRange(stringRange) < lfullTextLength) {
        stringRange = [_strContent rangeOfString:@"resume"
                                         options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSWidthInsensitiveSearch
                                           range:NSMakeRange(NSMaxRange(stringRange), lfullTextLength - NSMaxRange(stringRange))
                       ];
        if (stringRange.length > 0) {
            [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                           value:color
                                           range:stringRange];
        }
    }
}

-(void)enumerateByWordsForSpecificWord{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    [_strContent enumerateSubstringsInRange:range
                                    options:NSStringEnumerationByWords
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     NSRange matchRange = [_strContent rangeOfString:@"resume"
                                                                             options:NSAnchoredSearch |NSCaseInsensitiveSearch |NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch                       range:substringRange];
                                     if(NSEqualRanges(matchRange, substringRange)){
                                         [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                                        value:color
                                                                        range:substringRange];
                                     }
                                 }
     ];
}

-(NSCharacterSet*)quoteCharacterSet{
    static NSCharacterSet *quoteCharacterSet = nil;
    static dispatch_once_t predicate = 0;
    dispatch_once(&predicate, ^{
        //TODO : . / not in target set
        quoteCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"\"“”„“,':<<>>⟪⟫"]
                              retain];
    });
    return quoteCharacterSet;
}

-(void)enumerateByCharacterSet{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    NSRange charRange = NSMakeRange(0, 0);
    NSCharacterSet *quoteCharacterSet = [self quoteCharacterSet];
    NSString* strContent = [_textview string];
    long lfullTextLength = [strContent length];
    while (NSMaxRange(charRange) < lfullTextLength) {
        charRange = [strContent rangeOfCharacterFromSet:quoteCharacterSet
                                                options:0
                                                  range:NSMakeRange(NSMaxRange(charRange), lfullTextLength - NSMaxRange(charRange))];
        if (charRange.length > 0) {
            [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                           value:color
                                           range:charRange];
        }
    }
}

-(BOOL)rangeIsInQuotes:(NSRange)substringRange{
    NSString* _strContent = [_textview string];
    long lstrlength = _strContent.length;
    NSCharacterSet *quoteCharacterSet = [self quoteCharacterSet];
    NSRange precedingQuoteRange = NSMakeRange(NSNotFound, 0), followingQuoteRange = NSMakeRange(NSNotFound, 0);
    if (substringRange.location > 0) {
        precedingQuoteRange = [_strContent rangeOfCharacterFromSet:quoteCharacterSet
                                                           options:NSAnchoredSearch | NSBackwardsSearch
                                                             range:NSMakeRange(0, substringRange.location)
                               ];
    }
    if(NSMaxRange(substringRange) < lstrlength){
        followingQuoteRange = [_strContent rangeOfCharacterFromSet:quoteCharacterSet
                                                           options:NSAnchoredSearch
                                                             range:NSMakeRange(NSMaxRange(substringRange), lstrlength - NSMaxRange(substringRange))
                               ];
    }
    return precedingQuoteRange.length > 0 && followingQuoteRange.length > 0;
}

-(void)enumerateByWordsInQuotes{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    [_strContent enumerateSubstringsInRange:range
                                    options:NSStringEnumerationByWords
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if ([self rangeIsInQuotes:substringRange]) {
                                         [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                                        value:color
                                                                        range:substringRange];
                                     }
                                 }];
}

-(void)enumerateByRegualExpression{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(i|o)(n|f)\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    [regex enumerateMatchesInString:_strContent
                            options:0
                              range:range
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             //TODO : colorize all of ranges once in a while - for all
                             [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                            value:color
                                                            range:[result range]];
                         }];
}

-(void)enumerateByDataDetector{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    [detector enumerateMatchesInString:_strContent
                               options:0
                                 range:range
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                               value:color
                                                               range:[result range]];
                                NSLog(@"%lu sections of ranges, type - %llu\n", [result numberOfRanges], [result resultType]);
                            }];
}

//TODO : >> will be recognized as nouns, why?
//TODO :  Now try http://ushistory.org. will recognize http and ushistory.org.
//However,  Now try
//http://ushistory.org. won't recognize http and ushistory.org
-(void)enumerateByNouns{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc]initWithTagSchemes:[NSArray arrayWithObjects:NSLinguisticTagSchemeTokenType, NSLinguisticTagSchemeLexicalClass, NSLinguisticTagSchemeNameType, nil]
                                                                       options:0];
    [tagger setString:_strContent];
    [tagger enumerateTagsInRange:range scheme:NSLinguisticTagSchemeLexicalClass
                         options:0 usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                             if (tag == NSLinguisticTagNoun) {
                                 [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                                value:color
                                                                range:tokenRange];
//                                 NSLog(@"%@", [_strContent substringWithRange:tokenRange]);
                             }
                         }];
}

-(void)enumerateByNounsInQuotes{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    long _lstrLength = _strContent.length;
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc]initWithTagSchemes:[NSArray arrayWithObjects:NSLinguisticTagSchemeTokenType, NSLinguisticTagSchemeLexicalClass, NSLinguisticTagSchemeNameType, nil]
                                                                       options:0];
    [tagger setString:_strContent];
    [tagger enumerateTagsInRange:range scheme:NSLinguisticTagSchemeLexicalClass
                         options:0 usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                             if (tag == NSLinguisticTagNoun) {
                                 //TODO : check-up wth tag in quotes setting - tagger implementation with openquote
                                 BOOL precededByQuote = (tokenRange.location > 0 && [tagger tagAtIndex:tokenRange.location - 1
                                                                                                scheme:NSLinguisticTagSchemeLexicalClass
                                                                                            tokenRange:NULL sentenceRange:NULL] == NSLinguisticTagOpenQuote);
                                 BOOL followedByQuote = (NSMaxRange(tokenRange) < _lstrLength && [tagger tagAtIndex:NSMaxRange(tokenRange)
                                                                                                             scheme:NSLinguisticTagSchemeLexicalClass
                                                                                                         tokenRange:NULL
                                                                                                      sentenceRange:NULL] ==
                                                         NSLinguisticTagCloseQuote);
                                 if (precededByQuote && followedByQuote) {
                                     [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                                    value:color
                                                                    range:tokenRange];
                                 }
                             }
                         }];
}

-(void)enumerateByNames{
    id color = [NSColor redColor];
    NSString* _strContent = [_textview string];
    NSRange range = NSMakeRange(0, _strContent.length);
    [[_textview textStorage]removeAttribute:NSForegroundColorAttributeName range:range];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc]initWithTagSchemes:[NSArray arrayWithObjects:NSLinguisticTagSchemeTokenType, NSLinguisticTagSchemeLexicalClass, NSLinguisticTagSchemeNameType, nil]
                                                                       options:0];
    [tagger setString:_strContent];
    [tagger enumerateTagsInRange:range scheme:NSLinguisticTagSchemeNameType
                         options:0 usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                             if (tag == NSLinguisticTagPersonalName ||
                                 tag == NSLinguisticTagPlaceName ||
                                 tag == NSLinguisticTagOrganizationName) {
                                 [[_textview textStorage]addAttribute:NSForegroundColorAttributeName
                                                                value:color
                                                                range:tokenRange];
                             }
                         }];
}

@end
