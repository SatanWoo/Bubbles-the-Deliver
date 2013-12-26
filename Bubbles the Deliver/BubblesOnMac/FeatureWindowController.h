//
//  FeatureWindowController.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-25.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPageControl.h"
#import "DuxScrollViewAnimation.h"
#define kPagenumber 6
#define kViewWidth 641
#define kViewHeight 517

@interface FeatureWindowController : NSWindowController
{
    IBOutlet NSPageControl *_pageControl;
    IBOutlet NSView *_customView;
    int _currentPage;
    
    IBOutlet NSScrollView *_scrollView;
    IBOutlet NSImageView *_pageOne;
    IBOutlet NSImageView *_pageTwo;
    IBOutlet NSImageView *_pageThree;
    IBOutlet NSImageView *_pageFour;
    IBOutlet NSImageView *_pageFive;
    IBOutlet NSImageView *_pageSix;
    
    IBOutlet NSButton *_rightButton;
    IBOutlet NSButton *_leftButton;
}

@end
