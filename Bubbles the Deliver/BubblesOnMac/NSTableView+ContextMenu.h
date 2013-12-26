//
//  NSTableView+ContextMenu.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-14.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <AppKit/AppKit.h>

@protocol ContextMenuDelegate <NSObject>
- (NSMenu*)tableView:(NSTableView*)aTableView menuForRows:(NSIndexSet*)rows;
@end

@interface NSTableView (ContextMenu)

@end
