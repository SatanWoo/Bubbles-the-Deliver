//
//  HelpViewController.h
//  Bubbles
//
//  Created by 王 得希 on 12-2-16.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView *helpPages;
@property (nonatomic, retain) IBOutlet UIPageControl *helpPageControl;

- (IBAction)changePage:(id)sender;

@end
