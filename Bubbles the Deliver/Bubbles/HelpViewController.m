//
//  HelpViewController.m
//  Bubbles
//
//  Created by 王 得希 on 12-2-16.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "HelpViewController.h"
#import "WDHeader.h"

#define kNumberOfPages  6

@implementation HelpViewController
@synthesize helpPages = _helpPages, helpPageControl = _helpPageControl;

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    UIImageView *t = [[UIImageView alloc] initWithImage:
                      [UIImage imageNamed:
                       [NSString stringWithFormat:@"help%i%i.png",
                        [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad, page+1]]];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
	[t addGestureRecognizer:recognizer];
    recognizer.delegate = self;
	[recognizer release];
    
    [_helpPages addSubview:t];
    [t release];
}

// DW: to support autorotate help pages
- (void)resizeImages {
    CGRect currentFrame;
    
    NSArray *subviews = [_helpPages subviews];
    for (int i = 0; i < subviews.count; i++) {
        // DW: get the currect frame, scale the image and set it's location (center)
        UIImageView *t = [subviews objectAtIndex:i];
        
        // DW: get a good frame
        CGRect frame = _helpPages.frame;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0;
        
        // DW: if it's the current frame, store it for later use
        if (i == _helpPageControl.currentPage) {
            currentFrame = frame;
        }
        
        // DW: record a good center
        CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        
        // DW: scale frame to image aspect, then set image
        frame.size.width = t.frame.size.width*frame.size.height/t.frame.size.height;
        t.frame = frame;
        t.center = center;
    }
    
    _helpPages.contentSize = CGSizeMake(_helpPages.frame.size.width * kNumberOfPages, _helpPages.frame.size.height);
    [_helpPages scrollRectToVisible:currentFrame animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_helpPages release];
    [_helpPageControl release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

// DW: table view max heigh is 457 pixels (iPhone 5), 3.5 inch is 88px shorter
const NSInteger SCREEN_HEIGHT_INCH_4 = 568; // DW: before it's 457
const NSInteger SCREEN_HEIGHT_INCH_35 = SCREEN_HEIGHT_INCH_4-88;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // a page is the width of the scroll view
    _helpPages.pagingEnabled = YES;
    _helpPages.showsHorizontalScrollIndicator = NO;
    _helpPages.showsVerticalScrollIndicator = NO;
    _helpPages.scrollsToTop = NO;
    _helpPages.delegate = self;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _helpPages.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    }
    
    // DW: add recognizer to _helpPages
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
	[_helpPages addGestureRecognizer:recognizer];
    recognizer.delegate = self;
	[recognizer release];
    
    for (int i = 0; i < kNumberOfPages; i++) {
        [self loadScrollViewWithPage:i];
    }
    
    _helpPageControl.numberOfPages = kNumberOfPages;
    _helpPageControl.currentPage = 0;
    
    // DW: register rotation event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    // DW: rotate view if needed
    if (([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft)
        ||([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.view.frame = CGRectMake(0, 0, 1024, 748);
        } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 320);
        }
    }
    
    [self resizeImages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSLog(@"HVC didRotateFromInterfaceOrientation");
}

- (void)didRotate:(NSNotification *)notification {
    [self resizeImages];
    return;
    // DW: rotate view if needed
    if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    } else if ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2*3);
    } else if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait) {
        self.view.transform = CGAffineTransformMakeRotation(0);
    } else if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

#pragma mark - IBActions

- (IBAction)changePage:(id)sender {
    int page = _helpPageControl.currentPage;
    
	// update the scroll view to the appropriate page
    CGRect frame = _helpPages.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_helpPages scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _helpPages.frame.size.width;
    int page = floor((_helpPages.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _helpPageControl.currentPage = page;
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    // DW: user taps to end the help
    [self.view removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsShouldShowHelp];
}

@end
