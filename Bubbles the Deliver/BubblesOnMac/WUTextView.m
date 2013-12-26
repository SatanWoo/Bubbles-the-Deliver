//
//  WUTextView.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-15.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "WUTextView.h"

@implementation WUTextView

- (void)awakeFromNib
{
    [[self enclosingScrollView] setHasHorizontalScroller:NO];
    [self setHorizontallyResizable:NO];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
