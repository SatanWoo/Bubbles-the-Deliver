//
//  FeatureWindowController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-25.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "FeatureWindowController.h"

@implementation FeatureWindowController

- (void)setButtonStatus
{
    if (_currentPage == 0) {
        [_leftButton setHidden:YES];
    } else if (_currentPage == 5) {
        [_rightButton setHidden:YES];
    } else {
        [_rightButton setHidden:NO];
        [_leftButton setHidden:NO];
    }
}

- (id)init
{
    
    if (![super initWithWindowNibName:@"FeatureWindowController"]) {
        return nil;
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib
{
    _currentPage = 0;
    [_pageOne setImage:[NSImage imageNamed:@"1"]];
    [_pageTwo setImage:[NSImage imageNamed:@"2"]];
    [_pageThree setImage:[NSImage imageNamed:@"3"]];
    [_pageFour setImage:[NSImage imageNamed:@"4"]];
    [_pageFive setImage:[NSImage imageNamed:@"5"]];
    [_pageSix setImage:[NSImage imageNamed:@"6"]];
    
    [_pageControl setType:NSPageControlTypeOnFullOffFull];
    [_pageControl setNumberOfPages:kPagenumber];
    [_scrollView setDocumentView:_customView];
    
    NSRect scrollViewFrame = _scrollView.frame;
    CGPoint originPoint = scrollViewFrame.origin;
    CGSize size = scrollViewFrame.size;
    
    _leftButton.frame = NSMakeRect(originPoint.x + 2, size.height / 2, 32, 32);
    _rightButton.frame = NSMakeRect(originPoint.x + size.width - 32 , size.height / 2 ,32, 32);
    _pageControl.frame = NSMakeRect(originPoint.x + size.width / 2 - 45 , size.height - 48,169, 96);
    
    [[_leftButton cell] setHighlightsBy:NSContentsCellMask];
    [[_rightButton cell] setHighlightsBy:NSContentsCellMask];
    [_scrollView  addSubview:_pageControl];
    [_scrollView addSubview:_rightButton];
    [_scrollView addSubview:_leftButton];
    [self setButtonStatus];
    
}

- (void)dealloc
{
    [_customView removeFromSuperview];
    [_customView release];
    
    [_pageControl removeFromSuperview];
    [_pageControl release];
    
    [_leftButton removeFromSuperview];
    [_leftButton release];
    
    [_rightButton removeFromSuperview];
    [_rightButton release];
    
    [super dealloc];
}

#pragma mark - IBAction

- (IBAction)goNextPage:(id)sender
{
    [_pageControl setCurrentPage:++_currentPage];
    [DuxScrollViewAnimation animatedScrollToPoint:NSMakePoint(kViewWidth * _currentPage, 0) inScrollView:_scrollView];
    [self setButtonStatus];
}

- (IBAction)goPreviousPage:(id)sender
{
    [_pageControl setCurrentPage:--_currentPage];
    [DuxScrollViewAnimation animatedScrollToPoint:NSMakePoint(kViewWidth * _currentPage, 0) inScrollView:_scrollView];
    [self setButtonStatus];
    
}

@end
