//
//  HistoryPopOverViewController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "HistoryPopOverViewController.h"
#import "WDMessage.h"
#import "NSImage+QuickLook.h"
#import "AppDelegate.h"
#import "TransparentTableView.h"
#import "WDBubble.h"

@implementation HistoryPopOverViewController
@synthesize historyPopOver = _historyPopOver;
@synthesize fileHistoryArray = _fileHistoryArray;
@synthesize filehistoryTableView = _fileHistoryTableView;
@synthesize bubbles = _bubbles;

#pragma mark - Private Methods

- (void)showItPreview
{
    if (0 <= [_fileHistoryTableView selectedRow] && [_fileHistoryTableView selectedRow] < [_fileHistoryArray count]) {
        WDMessage *message = (WDMessage *)[_fileHistoryArray objectAtIndex:[_fileHistoryTableView selectedRow]];
        AppDelegate *del = (AppDelegate *)[NSApp delegate];
        if (![del.array containsObject:message.fileURL]) {
            del.array = [NSArray arrayWithObject:message.fileURL];
        }
        [del showPreviewInHistory];
    }
}

- (void)showItFinder:(NSURL *)aFileURL
{
    // Wu:Use NSWorkspace to open Finder with specific NSURL and show the selected status 
    [[NSWorkspace sharedWorkspace]selectFile:[aFileURL path] inFileViewerRootedAtPath:nil];
}

- (void)deleteSelectedRow
{
    if (0 <= [_fileHistoryTableView selectedRow] && [_fileHistoryTableView selectedRow] < [_fileHistoryArray count]) {
        WDMessage *message = [_fileHistoryArray objectAtIndex:[_fileHistoryTableView selectedRow]];
        
        DLog(@"message state is %@",message.state);
        
        // Wu :Terminate 
        if (!(([message.state isEqualToString:kWDMessageStateFile])
              ||([message.state isEqualToString:kWDMessageStateText]))) {
            [_bubbles terminateTransfer];
            
            // Wu:Remove all unstable 
            NSArray *originalArray = [NSArray arrayWithArray:_fileHistoryArray];
            for (WDMessage *m in originalArray) {
                if (![m.state isEqualToString:kWDMessageStateFile] && ![m.state isEqualToString:kWDMessageStateText]) {
                    [self deleteMessageFromHistory:m];
                }
            }
        }
        
        // Wu:Delete
        else {
            [_fileHistoryArray removeObjectAtIndex:[_fileHistoryTableView selectedRow]];
        }
        
    }
    
    if ([_fileHistoryArray count] == 0) {
        [_removeButton setHidden:YES];
        [_historyPopOver close];
    }
    [_fileHistoryTableView reloadData];
}

- (void)previewSelectedRow
{
    if (0 <= [_fileHistoryTableView selectedRow] && [_fileHistoryTableView selectedRow] < [_fileHistoryArray count]) {
        WDMessage *message = (WDMessage *)[_fileHistoryArray objectAtIndex:[_fileHistoryTableView selectedRow]];
        [self showItFinder:message.fileURL];
    }
}

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fileHistoryArray = [[NSMutableArray alloc]init];
    }
    
    return self;
}

- (void)dealloc
{
    [_imageAndTextCell release];
    [_fileHistoryTableView release];
    [_fileHistoryArray release];
    [_historyPopOver release];
    [super dealloc];
}

- (void)awakeFromNib
{
    
    // Wu:Set the customize the cell for the  only one column
    _imageAndTextCell = [[ImageAndTextCell alloc] init];
    _imageAndTextCell.delegate = self;
    NSTableColumn *column = [[_fileHistoryTableView tableColumns] objectAtIndex:0];
    [column setDataCell:_imageAndTextCell];
    
    NSButtonCell *previewCell = [[[NSButtonCell alloc]init]autorelease];
    [previewCell setBordered:NO];
    [previewCell setImage:[NSImage imageNamed:@"NSRevealFreestandingTemplate"]];
    [previewCell setImageScaling:NSImageScaleProportionallyDown];
    [previewCell setAction:@selector(previewSelectedRow)];
    [previewCell setTitle:@""];
    previewCell.highlightsBy = NSContentsCellMask;
    NSTableColumn *columnThree = [[_fileHistoryTableView tableColumns] objectAtIndex:kPreviewColumn];
    [columnThree setDataCell:previewCell];
    
    NSButtonCell *deleteCell = [[[NSButtonCell alloc]init]autorelease];
    [deleteCell setBordered:NO];
    [deleteCell setImage:[NSImage imageNamed:@"NSStopProgressFreestandingTemplate"]];
    [deleteCell setImageScaling:NSImageScaleProportionallyDown];
    [deleteCell setAction:@selector(deleteSelectedRow)];
    deleteCell.highlightsBy = NSContentsCellMask;
    NSTableColumn *columnTwo = [[_fileHistoryTableView tableColumns] objectAtIndex:kDeleteColumn];
    [columnTwo setDataCell:deleteCell];
    
    // Wu:Set the tableview can accept being dragged from
    [_fileHistoryTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType,NSFilenamesPboardType,NSTIFFPboardType,nil]];
    
	// Wu:Tell NSTableView we want to drag and drop accross applications the default is YES means can be only interact with current application
	[_fileHistoryTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

#pragma mark - Public Method

- (void)refreshButton
{
    if ([_fileHistoryArray count] != 0) {
        
        [_removeButton setHidden:NO];
    } else
    {
        [_removeButton setHidden:YES];
    }
}

- (void)reloadTableView
{
    [_fileHistoryTableView reloadData];
}

- (void)showHistoryPopOver:(NSView *)attachedView
{
    // Wu: init the popOver
    if (_historyPopOver == nil) {
        // Create and setup our window
        _historyPopOver = [[NSPopover alloc] init];
        // The popover retains us and we retain the popover. We drop the popover whenever it is closed to avoid a cycle.
        _historyPopOver.contentViewController = self;
        _historyPopOver.behavior = NSPopoverBehaviorTransient;
        _historyPopOver.delegate = self;
    }
    
    // Wu:CGRectMaxXEdge means appear in the right of button
    [_historyPopOver showRelativeToRect:[attachedView bounds] ofView:attachedView preferredEdge:CGRectMinYEdge];
    [self refreshButton];
}

- (void)deleteMessageFromHistory:(WDMessage *)aMessage
{
    NSArray *originArray = [NSArray arrayWithArray:_fileHistoryArray];
    for (WDMessage *m in originArray) {
        if ([m.fileURL.path.lastPathComponent isEqualToString:aMessage.fileURL.path.lastPathComponent]) {
            [_fileHistoryArray removeObject:m];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRestoreLabelAndImage object:nil];
    [self refreshButton];
    [_fileHistoryTableView reloadData];
}

#pragma mark - IBAction

- (IBAction)removeAllHistory:(id)sender
{
    if ([_fileHistoryArray count] == 0) {
        return ;
    } else {
        BOOL willTerminate = FALSE;
        
        // Wu:Remove all unstable at first
        NSArray *originalArray = [NSArray arrayWithArray:_fileHistoryArray];
        for (WDMessage *m in originalArray) {
            if (![m.state isEqualToString:kWDMessageStateFile] && ![m.state isEqualToString:kWDMessageStateText]) {
                DLog(@"gosh");
                willTerminate = TRUE;
                [self deleteMessageFromHistory:m];
            }
        }
        
        if (willTerminate) {
            [_bubbles terminateTransfer];
        }
        
        // Wu:Remove other files;
        if ([_fileHistoryArray count] != 0) {
            [_fileHistoryArray removeAllObjects];
            [_fileHistoryTableView noteNumberOfRowsChanged];
            [_fileHistoryTableView reloadData];
        }
    }
    
    // Wu:Force it to close
    [_historyPopOver close];
    
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_fileHistoryArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [_fileHistoryArray objectAtIndex:rowIndex];
}

- (BOOL)   tableView:(NSTableView *)pTableView 
writeRowsWithIndexes:(NSIndexSet *)pIndexSetOfRows 
		toPasteboard:(NSPasteboard*)pboard
{
	// Wu:This is to allow us to drag files to save
	// We don't do this if more than one row is selected
	if ([pIndexSetOfRows count] > 1 ) {
		return NO;
	} 
	NSInteger zIndex	= [pIndexSetOfRows firstIndex];
	WDMessage *message	= [_fileHistoryArray objectAtIndex:zIndex];
    
    if ([message.state isEqualToString:kWDMessageStateText]) {
        return YES;
    }
    
    [pboard declareTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, nil] owner:self];
    NSArray *propertyArray = [NSArray arrayWithObject:message.fileURL.pathExtension];
    [pboard setPropertyList:propertyArray
                    forType:NSFilesPromisePboardType];
    return YES;
}

- (NSArray *)tableView:(NSTableView *)aTableView
namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
    NSInteger zIndex = [indexSet firstIndex];
    WDMessage *message = [_fileHistoryArray objectAtIndex:zIndex];
    NSLog(@"dropDes is %@",dropDestination);
    if ([message.state isEqualToString:kWDMessageStateText]) {
        return nil;
    }
    NSURL *newURL = [[NSURL URLWithString:[message.fileURL.lastPathComponent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                            relativeToURL:dropDestination] URLWithoutNameConflict];
    [[NSFileManager defaultManager] copyItemAtURL:message.fileURL toURL:newURL error:nil];
    return [NSArray arrayWithObjects:newURL.lastPathComponent, nil];
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    WDMessage *message = [_fileHistoryArray objectAtIndex:row];
    if ([message.state isEqualToString: kWDMessageStateText] && tableColumn == [[_fileHistoryTableView tableColumns]objectAtIndex:kPreviewColumn]) {
        NSButtonCell *buttonCell = (NSButtonCell *)cell;
        [buttonCell setImagePosition:NSNoImage];
    } else if ([message.state isEqualToString:kWDMessageStateFile] && tableColumn == [[_fileHistoryTableView tableColumns]objectAtIndex:kPreviewColumn]) {
        NSButtonCell *buttonCell = (NSButtonCell *)cell;
        [buttonCell setImagePosition:NSImageOverlaps];
    }
}

#pragma mark - ImageAndTextCellDelegate

- (NSImage *)previewIconForCell:(NSObject *)data
{
    //DLog(@"previewIconForCell");
    WDMessage *message = (WDMessage *)data;
    if ([message.state isEqualToString: kWDMessageStateText]){
        return [NSImage imageNamed:@"text"];
    } else if ([message.state isEqualToString:kWDMessageStateFile]){
        NSImage *icon = [NSImage imageWithPreviewOfFileAtPath:[message.fileURL path] asIcon:YES];
        return icon;
    }
    return nil;
}

- (NSString *)primaryTextForCell:(NSObject *)data
{
    //DLog(@"primaryTextForCell");
    WDMessage *message = (WDMessage *)data;
    if ([message.state isEqualToString: kWDMessageStateText]){
        NSString *string = [[[NSString alloc]initWithData:message.content encoding:NSUTF8StringEncoding] autorelease];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"."];
        if ([string length] >= 25) {
            NSString *temp = [string substringWithRange:NSMakeRange([string length] - 6 , 5)];
            string = [string substringWithRange:NSMakeRange(0,15)];
            string = [string stringByAppendingString:@"..."];
            string = [string stringByAppendingString:temp];
        }
        return string;
    } else if ([message.state isEqualToString:kWDMessageStateFile]){
        if ([[message.fileURL lastPathComponent] length] >= 20) {
            NSInteger length = [[message.fileURL lastPathComponent] length];
            NSString *string = [[message.fileURL lastPathComponent] substringWithRange:NSMakeRange(0, 8)];
            string = [string stringByAppendingString:@"......"];
            string = [string stringByAppendingString:[[message.fileURL lastPathComponent] substringWithRange:NSMakeRange(length - 4, 3)]];
            return string;
        }  else {
            return [message.fileURL lastPathComponent];
        }
    } else if (([message.state isEqualToString:kWDMessageStateReadyToSend])
               ||([message.state isEqualToString:kWDMessageStateSending]))
    {
        return [NSString stringWithFormat:@"%.0f%% %@ sent", 
                [self.bubbles percentTransfered]*100, 
                [NSURL formattedFileSize:[self.bubbles bytesTransfered]]];
    } else if ([message.state isEqualToString:kWDMessageStateReadyToReceive] || [message.state isEqualToString:kWDMessageStateReceiving]){
        return [NSString stringWithFormat:@"%.0f%% %@ received", 
                [self.bubbles percentTransfered]*100, 
                [NSURL formattedFileSize:[self.bubbles bytesTransfered]]];
    }
    
    return nil;
}

- (NSString *)auxiliaryTextForCell:(NSObject *)data
{
    WDMessage *message = (WDMessage *)data;
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    df.dateFormat = @"hh:mm:ss";
    return  [message.sender stringByAppendingFormat:@" %@", [df stringFromDate:message.time]];
}

- (NSURL *)URLForCell:(NSObject *)data
{
    WDMessage *message = (WDMessage *)data;
    return  message.fileURL;
}

- (NSInteger)indexForCell:(NSObject *)data
{
    WDMessage *message = (WDMessage *)data;
    DLog(@"index is %lu",[_fileHistoryArray indexOfObject:message]);
    return [_fileHistoryArray indexOfObject:message];
}

#pragma mark - ContextMenuDelegate

- (NSMenu*)tableView:(NSTableView*)aTableView menuForRows:(NSIndexSet*)rows
{
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    NSInteger selectedRow = [rows firstIndex];
    WDMessage *message = [_fileHistoryArray objectAtIndex:selectedRow];
    if ([message.state isEqualToString: kWDMessageStateText]) {
        NSMenuItem *deleteItem = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"DELETE", @"Delete") action:@selector(deleteSelectedRow) keyEquivalent:@""];
        [menu addItem:deleteItem];
        [deleteItem release];
    } else {
        
        NSMenuItem *previewItem = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"SHOW_IN_FINDER", @"Show in Finder") action:@selector(previewSelectedRow) keyEquivalent:@""];
        [menu addItem:previewItem];
        [previewItem release];
        
        NSMenuItem *deleteItem = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"DELETE", @"Delete") action:@selector(deleteSelectedRow) keyEquivalent:@""];
        [menu addItem:deleteItem];
        [deleteItem release];
        
        NSMenuItem *quicklookItem = [[NSMenuItem alloc]initWithTitle:NSLocalizedString(@"QUICKLOOK", @"Quicklook") action:@selector(showItPreview) keyEquivalent:@""];
        [menu addItem:quicklookItem];
        [quicklookItem release];
    }
    return menu;
}

@end
