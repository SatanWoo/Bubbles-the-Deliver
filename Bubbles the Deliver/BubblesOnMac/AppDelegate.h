//
//  AppDelegate.h
//  BubblesOnMac
//
//  Created by 王 得希 on 12-1-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#define kFirstUseKey @"kUpdateFirstUseKey"

@class SandboxWindowController;

@interface AppDelegate : NSObject <NSWindowDelegate, NSApplicationDelegate,QLPreviewPanelDataSource,QLPreviewPanelDelegate>
{
    QLPreviewPanel *_panel;
    NSArray *_array;
    SandboxWindowController *_sandboxController;
}

@property (assign) IBOutlet NSWindow *window;
@property (copy) NSArray *array;

- (IBAction)showPreview:(id)sender;
- (void)showPreviewInHistory;

@end
