//
//  MainViewController.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-1-11.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DragAndDropImageView.h"
#import "PasswordMacViewController.h"
#import "NetworkFoundPopOverViewController.h"
#import "WDBubble.h"

@class WDBubble;
@class WDSound;
@class AboutWindowController;
@class PasswordMacViewController;
@class DragFileViewController;
@class PreferenceViewContoller;
@class TextViewController;
@class HistoryPopOverViewController;
@class NetworkFoundPopOverViewController;
@class FeatureWindowController;
@class WDLocalization;

#define kTextViewController 0
#define kDragFileController 1

@interface MainViewController : NSObject <WDBubbleDelegate,PasswordMacViewControllerDelegate,DragAndDropImageViewDelegate,NetworkFoundDelegate> {
    WDBubble *_bubble;
    NSURL *_fileURL;
    NSString *_selectedServiceName;
    NSOpenPanel *_selectFileOpenPanel;
    
    // Wu:NSView for adding two subView and constrain their bound
    IBOutlet NSView *_superView;
    
    NSToolbarItem *_selectFileItem;
    IBOutlet NSToolbarItem *_networkItem;
    IBOutlet NSToolbarItem *_historyItem;
    //IBOutlet NSTextField *_viewIndicator;
    IBOutlet NSButton *_sendButton;
    IBOutlet NSButton *_lockButton;
    IBOutlet NSMenuItem *_addFileItem;
    IBOutlet NSToolbar *_toolBar;
    
    BOOL _isView;
    
    // Wu:The window controller : for password sheet window and preference window
    PasswordMacViewController *_passwordController;
    PreferenceViewContoller *_preferenceController;
    FeatureWindowController *_featureController;
    AboutWindowController *_aboutController;
    
    // Wu:The viewcontroller for sending files and messages
    DragFileViewController *_dragFileController;
    TextViewController *_textViewController;
    
    // Wu:Two Popover
    HistoryPopOverViewController *_historyPopOverController;
    NetworkFoundPopOverViewController *_networkPopOverController;
    
    // DW: sound
    WDSound *_sound;
    
    //BOOL _menuItemCheck;
}

// DW: for binding
@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, assign) WDBubble *bubble;

// DW: only public methods can drage IBActions now
- (IBAction)send:(id)sender;
- (IBAction)swapView:(id)sender;
- (IBAction)openHistoryPopOver:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)openServiceFoundPopOver:(id)sender;


@end
