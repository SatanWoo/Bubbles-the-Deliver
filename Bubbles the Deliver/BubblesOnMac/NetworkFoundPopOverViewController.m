//
//  NetworkFoundPopOverViewController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "NetworkFoundPopOverViewController.h"
#import "WDBubble.h"
#import "TransparentTableView.h"

@implementation NetworkFoundPopOverViewController
@synthesize bubble = _bubble;
@synthesize delegate;
@synthesize selectedServiceName;

#pragma mark - Public Methods

- (void)reloadNetwork
{
    [_serviceFoundTableView reloadData];   
}

- (void)showServicesFoundPopOver:(NSView *)attachedView
{
    if (_serviceFoundPopOver == nil) {
        // Wu:Create and setup our window
        _serviceFoundPopOver = [[NSPopover alloc] init];
        // Wu:The popover retains us and we retain the popover. We drop the popover whenever it is closed to avoid a cycle.
        _serviceFoundPopOver.contentViewController = self;
        _serviceFoundPopOver.behavior = NSPopoverBehaviorTransient;
        _serviceFoundPopOver.delegate = self;
    }
    // Wu:CGRectMaxXEdge means appear in the right of button
    [_serviceFoundPopOver showRelativeToRect:[attachedView bounds] ofView:attachedView preferredEdge:CGRectMaxXEdge];
}

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)awakeFromNib
{
    
    _imageCell = [[NSImageCell alloc]init];
    [_imageCell setImageScaling:NSImageScaleProportionallyDown];
    [_imageCell setImageAlignment:NSImageAlignCenter];
    [_imageCell setImageFrameStyle:NSImageFrameNone];
    [_imageCell setImage:[NSImage imageNamed:@"NSBonjour"]];
    NSTableColumn *columnZero = [[_serviceFoundTableView tableColumns] objectAtIndex:kImageCell];
    [columnZero setDataCell:_imageCell];
    
    _textFileCell = [[NSTextFieldCell alloc]init];
    NSTableColumn *columnOne = [[_serviceFoundTableView tableColumns] objectAtIndex:kTextFieldCell];
    [columnOne setDataCell:_textFileCell];

    
    NSButtonCell *clickCell = [[[NSButtonCell alloc]init]autorelease];
    [clickCell setBordered:NO];
    [clickCell setImage:[NSImage imageNamed:@"NSBonjour"]];
    [clickCell setImageScaling:NSImageScaleProportionallyDown];
    [clickCell setAction:nil];
    [clickCell setTitle:@""];
    clickCell.highlightsBy = NSContentsCellMask;
    NSTableColumn *columnTwo = [[_serviceFoundTableView tableColumns] objectAtIndex:kClickCellColumn];
    [columnTwo setDataCell:clickCell];
}

- (void)dealloc
{
    [_serviceFoundTableView release];
    [_serviceFoundPopOver release];
    [_imageCell release];
    [_textFileCell release];
    self.selectedServiceName = nil;
    [super dealloc];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _bubble.servicesFound.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
   //  NSNetService *t = [_bubble.servicesFound objectAtIndex:rowIndex];
    if (aTableView == [[_serviceFoundTableView tableColumns] objectAtIndex:1]) {
        return [_textFileCell stringValue];
        
    } else if (aTableView == [[_serviceFoundTableView tableColumns] objectAtIndex:0])
    {
        return [_imageCell image];
    } 
    return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    // DW: we changed bubble selected name a little bit
    NSNetService *t = [_bubble.servicesFound objectAtIndex:row];
    if (t.name == self.selectedServiceName && [_bubble isDifferentService:t] && tableColumn == [[_serviceFoundTableView tableColumns] objectAtIndex:kClickCellColumn]) {
        
        NSButtonCell *buttonCell = (NSButtonCell *)cell;
        [buttonCell setImagePosition:NSImageOverlaps];
        
    } else if (tableColumn == [[_serviceFoundTableView tableColumns]objectAtIndex:kClickCellColumn] && (self.selectedServiceName == NULL || self.selectedServiceName != t.name)){
        
        NSButtonCell *buttonCell = (NSButtonCell *)cell;
        [buttonCell setImagePosition:NSNoImage];
        
    } else if (tableColumn == [[_serviceFoundTableView tableColumns]objectAtIndex:kImageCell]) {
        
        NSImageCell *imageCell = (NSImageCell *)cell;
        [imageCell setImage:[NSImage imageNamed:[NSString stringWithFormat:@"%@_%d", 
                                                 [WDBubble platformForNetService:t], 
                                                 [WDBubble isLockedNetService:t]]]];
        [[imageCell controlView] setNeedsDisplay:YES];
    } else if (tableColumn == [[_serviceFoundTableView tableColumns] objectAtIndex:kTextFieldCell]) {
        
        if ([_bubble isIdenticalService:t]) {
            NSTextFieldCell *textCell = (NSTextFieldCell *)cell;
            NSString *string = [NSString stringWithFormat:@"%@ %@",t.name , NSLocalizedString(@"LOCAL", @"local")];
            [textCell setStringValue:string];
            [[textCell controlView] setNeedsDisplay:YES];
        } else {
            NSTextFieldCell *textCell = (NSTextFieldCell *)cell;
            [textCell setStringValue:t.name];
            [[textCell controlView] setNeedsDisplay:YES];
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    // Configure the cell...
    if ([_serviceFoundTableView selectedRow] >= 0 && [_serviceFoundTableView selectedRow] < [_bubble.servicesFound count]) {
        NSNetService *t = [_bubble.servicesFound objectAtIndex:[_serviceFoundTableView selectedRow]];
        if ([t.name isEqualToString:_bubble.service.name]) {
            
        } else {
            self.selectedServiceName = t.name;
            DLog(@"self.selected is %@",self.selectedServiceName);
            [self.delegate didSelectServiceName:self.selectedServiceName];
            [_serviceFoundTableView reloadData];
        }
    }
    [_serviceFoundTableView deselectRow:[_serviceFoundTableView selectedRow]];
   
}

@end
