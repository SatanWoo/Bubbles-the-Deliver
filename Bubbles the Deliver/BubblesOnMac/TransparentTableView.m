//
//  TransparentTableView.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-14.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "TransparentTableView.h"

@implementation TransparentTableView

- (void)awakeFromNib {
    
    [[self enclosingScrollView] setDrawsBackground: NO];
}

- (BOOL)isOpaque {
    
    return NO;
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    
    // don't draw a background rect
}

@end
