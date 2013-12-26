//
//  AppDelegate.m
//  BubblesOnMac
//
//  Created by 王 得希 on 12-1-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "AppDelegate.h"
#import "SandboxWindowController.h"
#import "WDBubble.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize array = _array;

- (void)dealloc
{
    [_array release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSNumber *firstUse = [NSNumber numberWithInt:0];
    NSDictionary *registrationDefaults = [NSDictionary dictionaryWithObject:firstUse forKey:kFirstUseKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:registrationDefaults];
    
    _window.delegate = self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    // DW: user turned password on.
    if (_sandboxController == nil) {
        _sandboxController = [[SandboxWindowController alloc]init];
        //_sandboxController.delegate = self;
        // Wu: show as a sheet window to force users to set usable password
        [NSApp beginSheet:[_sandboxController window]
           modalForWindow:_window
            modalDelegate:nil
           didEndSelector:NULL
              contextInfo:NULL];
    }
}

#pragma mark - Show Preview

- (IBAction)showPreview:(id)sender
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel]isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        [[QLPreviewPanel sharedPreviewPanel]makeKeyAndOrderFront:nil];
    }
}

- (void)showPreviewInHistory
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel]isVisible]) {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    } else {
        [[QLPreviewPanel sharedPreviewPanel]makeKeyAndOrderFront:nil];
    }
}

#pragma mark - QLPreviewPanel Support

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel;
{
    DLog(@"acceptsPreviewPanelControl");
    
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    DLog(@"beginPreviewPanelControl");
    
    // This document is now responsible of the preview panel
    // It is allowed to set the delegate, data source and refresh panel.
    _panel = [panel retain];
    panel.delegate = self;
    panel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document loses its responsisibility on the preview panel
    // Until the next call to -beginPreviewPanelControl: it must not
    // change the panel's delegate, data source or refresh it.
    DLog(@"endPreviewPanelControl");
    [_panel release];
    _panel = nil;
}

#pragma mark - QLPreviewPanel data source

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return [_array count];
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return [_array objectAtIndex:index];
}

#pragma mark - QLPreviewPanel Delegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    return YES;
}

// This delegate method provides the rect on screen from which the panel will zoom.
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
    return NSZeroRect;
}

// This delegate method provides a transition image between the table view and the preview panel
- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
{
    return nil;
}

@end
