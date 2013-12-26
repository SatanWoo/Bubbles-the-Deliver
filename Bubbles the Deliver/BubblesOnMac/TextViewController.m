//
//  TextViewController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-8.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "TextViewController.h"
#import "WUTextView.h"

@implementation TextViewController
@synthesize textField = _textField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)awakeFromNib
{
    [_textField becomeFirstResponder];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)dealloc
{
    [_textField release];
    [super dealloc];
}
@end
