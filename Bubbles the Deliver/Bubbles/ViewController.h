//
//  ViewController.h
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "WDSound.h"
#import "WDBubble.h"
#import "DirectoryWatcher.h"
#import "HelpViewController.h"
#import "PeersViewController.h"
#import "TextViewController.h"

@interface ViewController : UIViewController <
UIAlertViewDelegate, 
UITextFieldDelegate, 
UINavigationControllerDelegate, 
UIImagePickerControllerDelegate, 
WDBubbleDelegate, 
TextViewControllerDelegate, 
UITableViewDelegate, 
UITableViewDataSource, 
UIActionSheetDelegate, 
MFMailComposeViewControllerDelegate, 
MFMessageComposeViewControllerDelegate, 
UIDocumentInteractionControllerDelegate, 
DirectoryWatcherDelegate, 
UISplitViewControllerDelegate> {
    // DW: bubbles core
    WDBubble *_bubble;
    NSString *_selectedServiceName;
    NSURL *_fileURL;
    NSMutableArray *_messages;
    
    // DW: files
    NSMutableArray *_documents;
    DirectoryWatcher *_directoryWatcher;
    
    // DW: UI
    NSMutableArray *_itemsToShow;
    NSMutableDictionary *_thumbnails; // DW: key is file url path
    UIPopoverController *_popover;
    UIActionSheet *_actionSheet;
    UINavigationItem *_currentNavigationItem;   // DW: different in iPad and iPhone
    IBOutlet UINavigationBar *_bar;
    IBOutlet UISegmentedControl *_segmentSwith;
    IBOutlet UITableView *_messagesView;
    IBOutlet UIBarButtonItem *_lockButton;
    IBOutlet UIBarButtonItem *_clearButton;
    
    // DW: help
    HelpViewController *_helpViewController;
    
    // DW: sound
    WDSound *_sound;
}

@property (nonatomic, retain) WDBubble *bubble;

// DW: for opening files
@property (nonatomic, retain) NSURL *launchFile;

// DW: cooperate with peers
@property (nonatomic, retain) UIBarButtonItem *lockButton;
@property (nonatomic, retain) NSString *selectedServiceName;

- (void)lock;
- (void)refreshLockStatus;
- (void)restartBubbleWithPassword:(NSString *)password;

// DW: it's very weird that sometimes I can't drag actions to this vc unless I declare these methods as public
- (IBAction)sendText:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)showPeers:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)toggleUsePassword:(id)sender;
- (IBAction)toggleView:(id)sender;
- (IBAction)clearButton:(id)sender;

@end
