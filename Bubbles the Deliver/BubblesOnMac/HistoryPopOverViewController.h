//
//  HistoryPopOverViewController.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WDBubble;
@class TransparentTableView;
@class WDMessage;
@class ImageAndTextCell;
#import "ImageAndTextCell.h"
#import "NSTableView+ContextMenu.h"

#define kPreviewColumn 1
#define kDeleteColumn 2
#define kRestoreLabelAndImage @"kRestoreLabelAndImage"

@interface HistoryPopOverViewController : NSViewController<NSPopoverDelegate,NSTableViewDataSource,NSTableViewDelegate,ImageAndTextCellDelegate,ContextMenuDelegate>
{
    IBOutlet TransparentTableView *_fileHistoryTableView;
    NSPopover *_historyPopOver;
    NSMutableArray *_fileHistoryArray;
    
    ImageAndTextCell *_imageAndTextCell;
    
    IBOutlet NSButton *_removeButton;
    
    WDBubble *_bubbles;
}

@property (nonatomic ,retain) NSPopover *historyPopOver;
@property (nonatomic ,retain) NSMutableArray *fileHistoryArray;
@property (nonatomic ,retain) TransparentTableView *filehistoryTableView;
@property (nonatomic ,assign) WDBubble *bubbles;

// Wu:attachedView is the the view which popover attach to like the effect in Safari
- (void)showHistoryPopOver:(NSView *)attachedView;
- (void)deleteMessageFromHistory:(WDMessage *)aMessage;
- (void)refreshButton;
- (void)reloadTableView;

@end
