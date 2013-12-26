//
//  ImageAndTextCell.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "ImageAndTextCell.h"

@implementation ImageAndTextCell

@synthesize previewImage = _previewImage;
@synthesize auxiliaryText = _auxiliaryText;
@synthesize primaryText = _primaryText;
@synthesize fileURL = _fileURL;
@synthesize delegate;

#pragma mark - Override

- (void)dealloc
{
    [_previewImage release];
    [_auxiliaryText release];
    [_primaryText release];
    [_previewImage release];
    [_fileURL release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    ImageAndTextCell *cell = (ImageAndTextCell *)[super copyWithZone:zone];
    cell.primaryText = nil;
    cell.auxiliaryText = nil;
    cell.delegate = nil;
    cell.previewImage = nil;
    cell.fileURL = nil;
    return cell;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self setTextColor:[NSColor blackColor]];
    
    // Wu:fetch the three attributes 02/05
    NSObject *data = [self objectValue];
    _primaryText = [[self.delegate primaryTextForCell:data] retain];
    _auxiliaryText = [[self.delegate auxiliaryTextForCell:data] retain];
    _previewImage = [[self.delegate previewIconForCell:data] retain];
    _fileURL = [[self.delegate URLForCell:data] retain];
    
    // Wu:For the primaryText 02/05
    NSColor *primartTextColor = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : 
    [NSColor textColor];
    NSDictionary *primaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:primartTextColor,NSForegroundColorAttributeName,[NSFont systemFontOfSize:13],NSFontAttributeName,nil];
    [_primaryText drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.height + 10, cellFrame.origin.y) withAttributes:primaryTextAttributes];
    
    // Wu:For the auxiliaryText 02/05
    NSColor *auxiliaryTextColor = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : 
    [NSColor disabledControlTextColor];
    NSDictionary *auxiliaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:auxiliaryTextColor,NSForegroundColorAttributeName,[NSFont systemFontOfSize:8],NSFontAttributeName,nil];
    [_auxiliaryText drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.height + 10, cellFrame.origin.y +cellFrame.size.height / 2) withAttributes:auxiliaryTextAttributes];
    
    // Wu:For the previewImage
    [[NSGraphicsContext currentContext] saveGraphicsState];
    float yOffset = cellFrame.origin.y;
	if ([controlView isFlipped]) {
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy: cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];		
		yOffset = 0-cellFrame.origin.y;
	}	
	
	NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];	
	
	[_previewImage drawInRect:NSMakeRect(cellFrame.origin.x + 5, yOffset + 3, cellFrame.size.height - 6, cellFrame.size.height - 6) 
                     fromRect:NSMakeRect(0,0,[_previewImage size].width,[_previewImage size].height) 
                    operation:NSCompositeSourceOver
                     fraction:1.0];
	
	[[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];	   
}

// Disable the mouse hover to show the tooltip You have to override is because the subclass of nstextfieldcell do not return zerorect
- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
    return NSZeroRect;
}

@end
