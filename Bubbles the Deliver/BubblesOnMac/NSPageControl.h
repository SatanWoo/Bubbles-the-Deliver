//
//  DDPageControl.h
//  DDPageControl
//
//  Created by Damien DeVille on 1/14/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//
//  Ported by Tim on 4/6/11.
//  Copyright 2011 Timstarockz LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AppKit/NSControl.h>
#import <AppKit/AppKitDefines.h>

typedef enum
{
	NSPageControlTypeOnFullOffFull		= 0,
	NSPageControlTypeOnFullOffEmpty		= 1,
	NSPageControlTypeOnEmptyOffFull		= 2,
	NSPageControlTypeOnEmptyOffEmpty	= 3,
}
NSPageControlType ;


@interface NSPageControl : NSControl 
{
	NSInteger numberOfPages ;
	NSInteger currentPage ;
}

// Replicate UIPageControl features
@property(nonatomic) NSInteger numberOfPages ;
@property(nonatomic) NSInteger currentPage ;

@property(nonatomic) BOOL hidesForSinglePage ;

@property(nonatomic) BOOL defersCurrentPageDisplay ;
- (void)updateCurrentPageDisplay ;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount ;

/*
	NSPageControl add-ons - all these parameters are optional
	Not using any of these parameters produce a page control identical to Apple's UIPage control
 */
- (id)initWithType:(NSPageControlType)theType ;

@property (nonatomic) NSPageControlType type ;

@property (nonatomic,retain) NSColor *onColor ;
@property (nonatomic,retain) NSColor *offColor ;

@property (nonatomic) CGFloat indicatorDiameter ;
@property (nonatomic) CGFloat indicatorSpace ;

@end

