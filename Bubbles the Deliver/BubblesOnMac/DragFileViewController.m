//
//  DragFileViewController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-8.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "DragFileViewController.h"
#import "DragAndDropImageView.h"

@implementation DragFileViewController
@synthesize imageView = _imageView;
@synthesize label = _label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DLog(@"DragFileViewController init");
    }
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)dealloc
{
    [_imageView release];
    [super dealloc];
}



@end
