//
//  DDPageControl.m
//  DDPageControl
//
//  Created by Damien DeVille on 1/14/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//
//  Ported by Tim on 4/6/11.
//  Copyright 2011 Timstarockz LLC. All rights reserved.
//

#import "NSPageControl.h"

APPKIT_PRIVATE_EXTERN CGContextRef UIGraphicsGetCurrentContext(void);

CGContextRef UIGraphicsGetCurrentContext(void)
{
    return [[NSGraphicsContext currentContext] graphicsPort];
}

#define kDotDiameter	2.0f
#define kDotSpace		6.0f

@implementation NSPageControl

@synthesize numberOfPages ;
@synthesize currentPage ;
@synthesize hidesForSinglePage ;
@synthesize defersCurrentPageDisplay ;

@synthesize type ;
@synthesize onColor ;
@synthesize offColor ;
@synthesize indicatorDiameter ;
@synthesize indicatorSpace ;

#pragma mark -
#pragma mark Initializers - dealloc

- (id)initWithType:(NSPageControlType)theType
{
	self = [self initWithFrame: CGRectZero] ;
	[self setType: theType] ;
	return self ;
}

- (id)init
{
	//self = [self initWithFrame: CGRectZero] ;
	return self ;
}

/*
- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame: CGRectZero]))
	{
		//self.backgroundColor = [NSColor clearColor] ;
	}
	return self ;
}
*/
- (void)dealloc 
{
	[onColor release], onColor = nil ;
	[offColor release], offColor = nil ;
	
	[super dealloc] ;
}


#pragma mark -
#pragma mark drawRect

- (void)drawRect:(NSRect)dirtyRect
{
	// get the current context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//[[NSImage imageNamed:@"qr-youraweomseforreadingthis.png"] drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
	
	//NSDrawThreePartImage(dirtyRect, [NSImage imageNamed:@"qr-youraweomseforreadingthis.png"], [NSImage imageNamed:@"qr-youraweomseforreadingthis.png"], [NSImage imageNamed:@"qr-youraweomseforreadingthis.png"], NO, NSCompositeSourceOver, 1, YES);
	
	
	// save the context
	CGContextSaveGState(context) ;
	
	// allow antialiasing
	CGContextSetAllowsAntialiasing(context, TRUE);
	
	// get the caller's diameter if it has been set or use the default one 
	CGFloat diameter = (indicatorDiameter > 0) ? indicatorDiameter : kDotDiameter ;
	CGFloat space = (indicatorSpace > 0) ? indicatorSpace : kDotSpace ;
	
	// geometry
	CGRect currentBounds = self.bounds ;
	CGFloat dotsWidth = self.numberOfPages * diameter + MAX(0, self.numberOfPages - 1) * space ;
	CGFloat x = CGRectGetMidX(currentBounds) - dotsWidth / 2 ;
	CGFloat y = CGRectGetMidY(currentBounds) - diameter / 2 ;
	
	
	
	// get the caller's colors it they have been set or use the defaults
	CGColorRef onColorCG = CGColorCreateGenericRGB(1, 1, 1, 1);
	CGColorRef offColorCG = CGColorCreateGenericRGB(1, 1, 1, .5);
	
	// actually draw the dots
	for (int i = 0 ; i < numberOfPages ; i++)
	{
		CGRect dotRect = CGRectMake(x, y, diameter, diameter) ;
		
		if (i == currentPage)
		{
			if (type == NSPageControlTypeOnFullOffFull || type == NSPageControlTypeOnFullOffEmpty)
			{
				CGContextSetFillColorWithColor(context, onColorCG) ;
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -1.0f, -1.0f)) ;
			}
			else
			{
				CGContextSetStrokeColorWithColor(context, onColorCG) ;
				CGContextStrokeEllipseInRect(context, dotRect) ;
			}
		}
		else
		{
			if (type == NSPageControlTypeOnEmptyOffEmpty || type == NSPageControlTypeOnFullOffEmpty)
			{
				CGContextSetStrokeColorWithColor(context, offColorCG) ;
				CGContextStrokeEllipseInRect(context, dotRect) ;
			}
			else
			{
				CGContextSetFillColorWithColor(context, offColorCG) ;
				CGContextFillEllipseInRect(context, CGRectInset(dotRect, -1.0f, -1.0f)) ;
			}
		}
		
		x += diameter + space ;
	}
	
    //[onColor autorelease];
    //[offColor autorelease];
	// restore the context
	CGContextRestoreGState(context) ;
	 
}


#pragma mark -
#pragma mark Accessors

- (void)setCurrentPage:(NSInteger)pageNumber
{
	// no need to update in that case
	if (currentPage == pageNumber)
		return ;
	
	// determine if the page number is in the available range
	currentPage = MIN(MAX(0, pageNumber), numberOfPages - 1) ;
	
	// in case we do not defer the page update, we redraw the view
	if (self.defersCurrentPageDisplay == NO)
		[self setNeedsDisplay] ;
}

- (void)setNumberOfPages:(NSInteger)numOfPages
{
	// make sure the number of pages is positive
	numberOfPages = MAX(0, numOfPages) ;
	
	// we then need to update the current page
	currentPage = MIN(MAX(0, currentPage), numberOfPages - 1) ;
	
	// correct the bounds accordingly
	self.bounds = self.bounds ;
	
	// we need to redraw
	[self setNeedsDisplay] ;
	
	// depending on the user preferences, we hide the page control with a single element
	if (hidesForSinglePage && (numOfPages < 2))
		[self setHidden: YES] ;
	else
		[self setHidden: NO] ;
}

- (void)setHidesForSinglePage:(BOOL)hide
{
	hidesForSinglePage = hide ;
	
	// depending on the user preferences, we hide the page control with a single element
	if (hidesForSinglePage && (numberOfPages < 2))
		[self setHidden: YES] ;
}

- (void)setDefersCurrentPageDisplay:(BOOL)defers
{
	defersCurrentPageDisplay = defers ;
}

- (void)setType:(NSPageControlType)aType
{
	type = aType ;
	
	[self setNeedsDisplay] ;
}

- (void)setOnColor:(NSColor *)aColor
{
	[aColor retain] ;
	[onColor release] ;
	onColor = aColor ;
	
	[self setNeedsDisplay] ;
}

- (void)setOffColor:(NSColor *)aColor
{
	[aColor retain] ;
	[offColor release] ;
	offColor = aColor ;
	
	[self setNeedsDisplay] ;
}

- (void)setIndicatorDiameter:(CGFloat)aDiameter
{
	indicatorDiameter = aDiameter ;
	
	// correct the bounds accordingly
	self.bounds = self.bounds ;
	
	[self setNeedsDisplay] ;
}

- (void)setIndicatorSpace:(CGFloat)aSpace
{
	indicatorSpace = aSpace ;
	
	// correct the bounds accordingly
	self.bounds = self.bounds ;
	
	[self setNeedsDisplay] ;
}

- (void)setFrame:(CGRect)aFrame
{
	// we do not allow the caller to modify the size struct in the frame so we compute it
	aFrame.size = [self sizeForNumberOfPages: numberOfPages] ;
	super.frame = aFrame ;
}

- (void)setBounds:(CGRect)aBounds
{
	// we do not allow the caller to modify the size struct in the bounds so we compute it
	aBounds.size = [self sizeForNumberOfPages: numberOfPages] ;
	super.bounds = aBounds ;
}

#pragma mark - UIPageControl methods
- (void)updateCurrentPageDisplay
{
	// ignores this method if the value of defersPageIndicatorUpdate is NO
	if (self.defersCurrentPageDisplay == NO)
		return ;
	
	// in case it is YES, we redraw the view (that will update the page control to the correct page)
	[self setNeedsDisplay] ;
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
	CGFloat diameter = (indicatorDiameter > 0) ? indicatorDiameter : kDotDiameter ;
	CGFloat space = (indicatorSpace > 0) ? indicatorSpace : kDotSpace ;
	
	return CGSizeMake(pageCount * diameter + (pageCount - 1) * space + 44.0f, MAX(44.0f, diameter + 4.0f)) ;
}


#pragma mark - Touches handlers
/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// get the touch location
	NSTouch *theTouch = [touches anyObject] ;
	CGPoint touchLocation = [theTouch locationInView: self] ;
	
	// check whether the touch is in the right or left hand-side of the control
	if (touchLocation.x < (self.bounds.size.width / 2))
		self.currentPage = MAX(self.currentPage - 1, 0) ;
	else
		self.currentPage = MIN(self.currentPage + 1, numberOfPages - 1) ;
	
	// call the target to alert that the value has changed
	[self callTargetForValueChanged] ;
}
*/

#pragma mark -
#pragma mark Target calls

@end