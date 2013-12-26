//
//  NetworkFoundPopOverViewController.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WDBubble;
@class TransparentTableView;

#define kImageCell 0
#define kTextFieldCell 1
#define kClickCellColumn 2

@protocol NetworkFoundDelegate <NSObject>

- (void)didSelectServiceName:(NSString *)serviceName;

@end

@interface NetworkFoundPopOverViewController : NSViewController<NSTableViewDelegate,NSTableViewDataSource,NSPopoverDelegate>
{
    IBOutlet TransparentTableView *_serviceFoundTableView;
    NSPopover *_serviceFoundPopOver;
    WDBubble *_bubble;
    NSImageCell *_imageCell;
    NSTextFieldCell *_textFileCell;
}

@property (nonatomic , assign) WDBubble *bubble;
@property (nonatomic , retain) NSString *selectedServiceName;
@property (nonatomic , assign) id<NetworkFoundDelegate>delegate;

- (void)showServicesFoundPopOver:(NSView *)attachedView;
- (void)reloadNetwork;
@end
