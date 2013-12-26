//
//  MainViewController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-1-11.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "MainViewController.h"
#import "WDLocalization.h"
#import "WDSound.h"
#import "AboutWindowController.h"
#import "PasswordMacViewController.h"
#import "DragFileViewController.h"
#import "PreferenceViewContoller.h"
#import "NSImage+QuickLook.h"
#import "ImageAndTextCell.h"
#import "TextViewController.h"
#import "NSView+NSView_Fade_.h"
#import "HistoryPopOverViewController.h"
#import "NetworkFoundPopOverViewController.h"
#import "FeatureWindowController.h"
#import "WUTextView.h"

#define kButtonTitleSendText    @"Text"
#define kButtonTitleSendFile    @"File"
#define kTooBarIndexOfSelectButton    2

@implementation MainViewController
@synthesize fileURL = _fileURL;
@synthesize bubble = _bubble;

#pragma mark - Private Methods

- (void)storeMessage:(WDMessage *)message withNewURL:(NSURL *)url
{
    if ([message.state isEqualToString:kWDMessageStateFile]) {
        NSArray *originalMessages = [NSArray arrayWithArray:_historyPopOverController.fileHistoryArray];
        for (WDMessage *m in originalMessages) {
            if ([m.fileURL.path isEqualToString:message.fileURL.path])
            {
                NSLog(@"changed url");
                m.state = kWDMessageStateFile;
                m.fileURL = url;
                NSLog(@"new url is %@",m.fileURL);
            };
        }
    }
}

- (void)showHistoryPopOver
{
    NSButton *button  = (NSButton *)[_historyItem view];
    [_historyPopOverController showHistoryPopOver:button];
}

- (void)showNetworkPopOver
{
    [_networkPopOverController reloadNetwork];
    _networkPopOverController.selectedServiceName = _selectedServiceName;
    NSButton *button  = (NSButton *)[_networkItem view];
    [_networkPopOverController showServicesFoundPopOver:button];
}

- (void)restoreImageAndLabel:(NSNotification *)notification
{
    [_dragFileController.imageView setImage:nil];
    [_dragFileController.label setHidden:NO];
}

- (void)displayErrorMessage:(NSString *)message {
    NSRunAlertPanel(NSLocalizedString(@"SORRY", @"Sorry"), NSLocalizedString(message, message), NSLocalizedString(@"OK", @"Ok"), nil, nil);
}

- (void)firstUse
{
    NSInteger firstUser = [[NSUserDefaults standardUserDefaults] integerForKey:kFirstUseKey];
    if (firstUser == 0) {
        _featureController = [[FeatureWindowController alloc]init];
        [_featureController showWindow:self];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:++firstUser forKey:kFirstUseKey];
}

// Wu: NO for can not send, YES for will send
- (BOOL)sendToSelectedServiceOfMessage:(WDMessage *)message {
    if (!_selectedServiceName || [_selectedServiceName isEqualToString:@""]) {
        [self displayErrorMessage:kWDBubbleErrorMessageNoDeviceSelected];
        return NO;
    }
    
    if ([_bubble isBusy]) {
        [self displayErrorMessage:kWDBubbleErrorMessageDoNotSupportMultiple];
        return NO;
    }
    
    [_bubble sendMessage:message toServiceNamed:_selectedServiceName];
    return YES;
}

- (void)servicesUpdated:(NSNotification *)notification {
    
    if (_bubble.servicesFound.count > 1) {
        // DW: if we already have one service selected, we do not update the selection now
        if (_selectedServiceName) {
            for (NSNetService *s in self.bubble.servicesFound) {
                if ([_selectedServiceName isEqualToString:s.name]) {
                    if (_networkPopOverController != nil) {
                        [_networkPopOverController reloadNetwork];
                    }
                    
                    return;
                }
            }
            
            // DW: selected service name is not found in current services, it's no longer useful, release it
            [_selectedServiceName release];
            _selectedServiceName = nil;
        }
        
        for (NSNetService *s in self.bubble.servicesFound) {
            
            if ([self.bubble isDifferentService:s]) {
                _selectedServiceName = [s.name retain];
            }
        }    } else {
            if (_selectedServiceName) {
                [_selectedServiceName release];
            }
            _selectedServiceName = nil;
        }
    
    if (_networkPopOverController != nil) {
        _networkPopOverController.selectedServiceName = _selectedServiceName;
        [_networkPopOverController reloadNetwork];
    }
    
    [self showNetworkPopOver];
}

- (void)initFirstResponder
{
    // Wu:Make the NSTextView as the first responder
    AppDelegate *appDel = (AppDelegate *)[NSApp delegate];
    [appDel.window makeFirstResponder:_textViewController.textField];
    appDel.window.initialFirstResponder = _textViewController.textField;
}

- (void)storeMessage:(WDMessage *)message
{
    if ([message.state isEqualToString:kWDMessageStateFile]) {
        NSArray *originalMessages = [NSArray arrayWithArray:_historyPopOverController.fileHistoryArray];
        for (WDMessage *m in originalMessages) {
            if (([m.fileURL.path isEqualToString:message.fileURL.path])
                &&(![m.state isEqualToString:kWDMessageStateFile])) {
                m.state = kWDMessageStateFile;
            };
        }
    } else {
        [_historyPopOverController.fileHistoryArray addObject:message];
    }
    
    [_historyPopOverController.fileHistoryArray sortUsingComparator:^NSComparisonResult(WDMessage *obj1, WDMessage * obj2) {
        if ([obj1.time compare:obj2.time] == NSOrderedAscending)
            return NSOrderedAscending;
        else if ([obj1.time compare:obj2.time] == NSOrderedDescending)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    [_historyPopOverController.filehistoryTableView reloadData];
    [_historyPopOverController refreshButton];
}

- (void)sendFile {
    if (_isView == kTextViewController || _fileURL == nil ) {
        return ;
    }
    WDMessage *t = [[WDMessage messageWithFile:_fileURL andState:kWDMessageStateReadyToSend] retain];
    if ([self sendToSelectedServiceOfMessage:t]) {
        [self storeMessage:t];
    }
    [t release];
}

- (void)sendText {
    if (_isView == kTextViewController || [_textViewController.textField.string length] == 0) {
        WDMessage *t = [[WDMessage messageWithText:_textViewController.textField.string] retain];
        if ([self sendToSelectedServiceOfMessage:t]) {
            [self storeMessage:t];
        }
        [t release];
    }   
}

#pragma mark - init & dealloc

- (id)init
{
    if (self = [super init]) {
        // Wu: init bubbles
        
        // DW: sound
        _sound = [[WDSound alloc] init];
        
        // DW: we specify user's home directory by NSHomeDirectory()
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@/Documents/", NSHomeDirectory()]];
        
        //NSURL *url = [NSURL URLWithString:@"~/Library/Containers/com.tjac.delivermac/Data/Downloads/"];
        NSFileManager *fileManager= [NSFileManager defaultManager]; 
        if(![fileManager fileExistsAtPath:url.path isDirectory:nil])
            if(![fileManager createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:NULL])
                NSLog(@"Error: Create folder failed %@", url);
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:url.path
                                                                                            forKey:kUserDefaultMacSavingPath]];
        
        _bubble = [[WDBubble alloc] init];
        _bubble.delegate = self;
        
        // Wu:Init two popover
        _historyPopOverController = [[HistoryPopOverViewController alloc]
                                     initWithNibName:@"HistoryPopOverViewController" bundle:nil];
        _historyPopOverController.bubbles = _bubble;
        
        _networkPopOverController = [[NetworkFoundPopOverViewController alloc]
                                     initWithNibName:@"NetworkFoundPopOverViewController" bundle:nil];
        _networkPopOverController.bubble = _bubble;
        _networkPopOverController.delegate = self;
        
        //Wu:the initilization is open the send text view;
        _isView = kTextViewController;
        
        //_sound = [[WDSound alloc]init];
        [_bubble publishServiceWithPassword:@""];
        [_bubble browseServices];
    }
    return self;
}

- (void)dealloc
{
    // DW: sound
    [_sound release];
    
    // Wu:Remove observe the notification
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"NSWindowDidBecomeKeyNotification"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kWDBubbleNotificationServiceUpdated];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kRestoreLabelAndImage];
    
    // Wu:Remove two subviews
    [[_textViewController view] removeFromSuperview];
    [[_dragFileController view] removeFromSuperview];
    [_superView release];
    [_dragFileController release];
    [_textViewController release];
    
    // Wu:Release two window controller
    [_passwordController release];
    [_preferenceController release];
    [_featureController release];
    [_aboutController release];
    
    [_lockButton release];
    [_selectFileItem release];
    [_selectFileOpenPanel release];
    
    [_bubble release];
    // [_sound release];
    [_fileURL release];
    [_selectFileItem release];
    [_networkItem release];
    [_historyItem release];
    [super dealloc];
}

- (void)awakeFromNib
{
    // Wu:Add observer to get the notification when the main menu become key window then the sheet window will appear
    /*[[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(delayNotification)
     name:@"NSWindowDidBecomeKeyNotification" object:nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initFirstResponder) name:@"NSWindowDidBecomeKeyNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(servicesUpdated:) 
                                                 name:kWDBubbleNotificationServiceUpdated
                                               object:nil];  
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreImageAndLabel:) name:kRestoreLabelAndImage object:nil];
    
    // Wu: Alloc the two view controller and first add textviewcontroller into superview
    _textViewController = [[TextViewController alloc]initWithNibName:@"TextViewController" bundle:nil];
    _dragFileController = [[DragFileViewController alloc]initWithNibName:@"DragFileViewController" bundle:nil];
    
    [[_textViewController view] setFrame:[_superView bounds]];
    [[_dragFileController view] setFrame:[_superView bounds]];
    
    [_superView addSubview:[_textViewController view]];
    [_superView addSubview:[_dragFileController view]];
    
    _dragFileController.imageView.delegate = self;
    [_dragFileController.view setHidden:YES];
    
    _sendButton.stringValue = kButtonTitleSendText;
    
    [self firstUse];
    
    //_menuItemCheck = FALSE;
    
    // [_addFileItem setEnabled:NO];
}



#pragma mark - IBActions

- (IBAction)showPassworFromShortCut:(id)sender
{
    _lockButton.state = !_lockButton.state;
    if (  _lockButton.state) {
        // DW: user turned password on.
        if (_passwordController == nil) {
            _passwordController = [[PasswordMacViewController alloc]init];
            _passwordController.delegate = self;
        }
        
        // Wu: show as a sheet window to force users to set usable password
        [NSApp beginSheet:[_passwordController window] modalForWindow:[NSApplication sharedApplication].keyWindow  modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    } else {
        NSArray* toolbarVisibleItems = [_toolBar visibleItems];
        NSEnumerator* enumerator = [toolbarVisibleItems objectEnumerator];
        NSToolbarItem* anItem = nil;
        BOOL stillLooking = YES;
        while ( stillLooking && ( anItem = [enumerator nextObject] ) )
        {
            if ( [[anItem itemIdentifier] isEqualToString:@"PasswordIdentifier"] )
            {
                [anItem setImage:[NSImage imageNamed:@"NSLockUnlockedTemplate"]];
                
                stillLooking = NO;
            }
        }
        
        _lockButton.state = NSOffState;
        [_bubble stopService];
        [_bubble publishServiceWithPassword:@""];
        [_bubble browseServices];
    }
}

- (IBAction)showPassword:(id)sender
{
    if (_lockButton.state == NSOnState) {
        // DW: user turned password on.
        if (_passwordController == nil) {
            _passwordController = [[PasswordMacViewController alloc]init];
            _passwordController.delegate = self;
        }
        
        // Wu: show as a sheet window to force users to set usable password
        [NSApp beginSheet:[_passwordController window] modalForWindow:[NSApplication sharedApplication].keyWindow  modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        
    } else {
        
        NSArray* toolbarVisibleItems = [_toolBar visibleItems];
        NSEnumerator* enumerator = [toolbarVisibleItems objectEnumerator];
        NSToolbarItem* anItem = nil;
        BOOL stillLooking = YES;
        while ( stillLooking && ( anItem = [enumerator nextObject] ) )
        {
            if ( [[anItem itemIdentifier] isEqualToString:@"PasswordIdentifier"] )
            {
                [anItem setImage:[NSImage imageNamed:@"NSLockUnlockedTemplate"]];
                
                stillLooking = NO;
            }
        }
        
        _lockButton.state = NSOffState;
        [_bubble stopService];
        [_bubble publishServiceWithPassword:@""];
        [_bubble browseServices];
    }
}

- (IBAction)showPreferencePanel:(id)sender
{
    if (_preferenceController == nil) {
        _preferenceController = [[PreferenceViewContoller alloc]init];
    }
    
    [_preferenceController showWindow:self];
}

- (IBAction)swapView:(id)sender {
    if (_isView == kTextViewController) {
        [_toolBar insertItemWithItemIdentifier:@"SelectItemIdentifier" atIndex:kTooBarIndexOfSelectButton];
        _isView = kDragFileController;
        [_addFileItem setEnabled:YES];
        [_textViewController.view setHidden:YES withFade:YES];
        [_dragFileController.view setHidden:NO withFade:YES];
        _sendButton.stringValue = kButtonTitleSendFile;
        
    } else {
        AppDelegate *appDel = (AppDelegate *)[NSApp delegate];
        //Reset as first responder
        [appDel.window makeFirstResponder:_textViewController.textField];
        appDel.window.initialFirstResponder = _textViewController.textField;
        
        [_addFileItem setEnabled:NO];
        [_toolBar removeItemAtIndex:kTooBarIndexOfSelectButton];
        _isView = kTextViewController;
        [_textViewController.view setHidden:NO withFade:YES];
        [_dragFileController.view setHidden:YES withFade:YES];
        _sendButton.stringValue = kButtonTitleSendText;
    }
}

- (IBAction)openHistoryPopOver:(id)sender
{
    [self showHistoryPopOver];
}

- (IBAction)openServiceFoundPopOver:(id)sender
{
    [self showNetworkPopOver];
}

- (IBAction)send:(id)sender {
    
    if (_isView == kTextViewController) {
        [self sendText];
    } else {
        [self sendFile];
    }
    //[_sound playSoundForKey:kWDSoundFileSent];
}

- (IBAction)selectFile:(id)sender
{
    if (_isView == kTextViewController) {
        return ;
    }
    
    _selectFileOpenPanel = [[NSOpenPanel openPanel] retain];
    
    [_selectFileOpenPanel setTitle:NSLocalizedString(@"CHOOSE_FILE", @"Choose files")];
	[_selectFileOpenPanel setPrompt:NSLocalizedString(@"BROWSE", @"Browse")];
	[_selectFileOpenPanel setNameFieldLabel:NSLocalizedString(@"CHOOSE_A_FILE", @"Choose a file")];
    [_selectFileOpenPanel setCanChooseDirectories:NO];
    [_selectFileOpenPanel setCanChooseFiles:YES];
    
    void (^selectFileHandler)(NSInteger) = ^( NSInteger result )
	{
        if (result != NSCancelButton) {
            NSURL *selectedFileURL = [_selectFileOpenPanel URL];
            
            BOOL isFolderApp = FALSE;
            
            [[NSFileManager defaultManager] fileExistsAtPath:selectedFileURL.path isDirectory:&isFolderApp];
            
            if(selectedFileURL && !isFolderApp)
            {
                _fileURL = [selectedFileURL retain];//the path of your selected photo
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:_fileURL];
                if (image != nil) {
                    [_dragFileController.imageView setImage:image];
                    [image release];   
                }else {
                    NSImage *quicklook = [NSImage imageWithPreviewOfFileAtPath:[_fileURL path] asIcon:YES];
                    [_dragFileController.imageView setImage:quicklook];
                }
                
                [_dragFileController.label setHidden:YES];
            }
            else {
                NSRunAlertPanel(NSLocalizedString(@"SORRY", @"Sorry"), 
                                NSLocalizedString(@"NOT_MULTI", @"We do not support folders, application package or multiple files for now.\nWe will improve this in the new version, many thanks for your support."), 
                                NSLocalizedString(@"OK", @"Ok"), nil, nil);
                return ;
            }
        }
    };
	
	[_selectFileOpenPanel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow 
                                 completionHandler:selectFileHandler];
}

- (IBAction)showFeature:(id)sender
{
    if (_featureController == nil) {
        _featureController = [[FeatureWindowController alloc]init];
    }
    [_featureController showWindow:self];
}

- (IBAction)showAbout:(id)sender
{
    if (_aboutController == nil) {
        _aboutController = [[AboutWindowController alloc]init];
    }
    [_aboutController showWindow:self];
}

- (IBAction)rateApp:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/deliver/id506655546?mt=12"]];
}

- (IBAction)checkBubblesTheDeliver:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/bubbles-the-deliver/id506646552?mt=8"]];
}
#pragma mark - WDBubbleDelegate

- (void)percentUpdated {
    [_historyPopOverController.filehistoryTableView reloadData];
}

- (void)errorOccured:(NSError *)error {
    [self displayErrorMessage:kWDBubbleErrorMessageDisconnectWithError];
}

- (void)willReceiveMessage:(WDMessage *)message {
    [self storeMessage:message];
}

- (void)didReceiveMessage:(WDMessage *)message {
    [_sound playSoundForKey:kWDSoundFileReceived];
    message.time = [NSDate date];
    if ([message.state isEqualToString:kWDMessageStateText]) {
        _textViewController.textField.string = [[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding] autorelease];
        [self storeMessage:message];
        
    } else if ([message.state isEqualToString:kWDMessageStateFile]) {
        [self storeMessage:message];
        [_dragFileController.label setHidden:YES];
        
        // DW: store this url for drag and drop
        if (_fileURL) {
            [_fileURL release],_fileURL = nil;
        }
        //_fileURL = [message.fileURL retain];
        // DW: stopAccessingSecurityScopedResource to balance the use
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_MAC
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        [savePanel setNameFieldStringValue:[message.fileURL lastPathComponent]];
        
        void (^selectFileHandler)(NSInteger) = ^( NSInteger result )
        {
            NSError *error;
            if (result != NSCancelButton) {
                NSURL *selectedFileURL = [[savePanel URL] URLWithoutNameConflict];
                _fileURL = selectedFileURL;
                if ([[NSFileManager defaultManager]moveItemAtPath:[message.fileURL path]                                     
                                                           toPath:[selectedFileURL path] error:&error]) {
                    [self storeMessage:message withNewURL:selectedFileURL];
                } else {
                    DLog(@"error is %@",error);
                }
            }
            else {
                [[NSFileManager defaultManager] removeItemAtPath:[message.fileURL path] error:&error];
                [_dragFileController.imageView setImage:nil];
                [_dragFileController.label setHidden:NO];
                [_historyPopOverController.fileHistoryArray removeLastObject];
                [_historyPopOverController reloadTableView];
            }
        };
        
        [savePanel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow 
                                     completionHandler:selectFileHandler];
#endif
        
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:message.fileURL];
        if (image != nil) {
            [_dragFileController.imageView setImage:image];
            [image release];
        } else {
            NSImage *quicklook = [NSImage imageWithPreviewOfFileAtPath:[message.fileURL path] asIcon:YES];
            [_dragFileController.imageView setImage:quicklook];
        }
    }
    [self showHistoryPopOver];
}

- (void)didSendMessage:(WDMessage *)message {
    [_sound playSoundForKey:kWDSoundFileSent];
    message.state = kWDMessageStateFile;
}

- (void)didTerminateReceiveMessage:(WDMessage *)message {
    if (_fileURL) {
        [_fileURL release];
        _fileURL = nil;
    }
    [self displayErrorMessage:kWDBubbleErrorMessageTerminatedBySender];
    
    [_historyPopOverController deleteMessageFromHistory:message];
}

- (void)didTerminateSendMessage:(WDMessage *)message {
    if (_fileURL) {
        [_fileURL release];
        _fileURL = nil;
    }
    [_historyPopOverController deleteMessageFromHistory:message];
}

#pragma mark - PasswordMacViewControllerDelegate

- (void)didCancel {
    NSArray* toolbarVisibleItems = [_toolBar visibleItems];
    NSEnumerator* enumerator = [toolbarVisibleItems objectEnumerator];
    NSToolbarItem* anItem = nil;
    BOOL stillLooking = YES;
    while ( stillLooking && ( anItem = [enumerator nextObject] ) )
    {
        if ( [[anItem itemIdentifier] isEqualToString:@"PasswordIdentifier"] )
        {
            [anItem setImage:[NSImage imageNamed:@"NSLockUnlockedTemplate"]];
            
            stillLooking = NO;
        }
    }
    _lockButton.state = NSOffState;
    [_bubble stopService];
    [_bubble publishServiceWithPassword:@""];
    [_bubble browseServices];
}

- (void)didInputPassword:(NSString *)pwd {
    NSArray* toolbarVisibleItems = [_toolBar visibleItems];
    NSEnumerator* enumerator = [toolbarVisibleItems objectEnumerator];
    NSToolbarItem* anItem = nil;
    BOOL stillLooking = YES;
    while ( stillLooking && ( anItem = [enumerator nextObject] ) )
    {
        if ( [[anItem itemIdentifier] isEqualToString:@"PasswordIdentifier"] )
        {
            [anItem setImage:[NSImage imageNamed:@"NSLockLockedTemplate"]];
            
            stillLooking = NO;
        }
    }
    _lockButton.state = NSOnState;
    [_bubble stopService];
    [_bubble publishServiceWithPassword:pwd];
    [_bubble browseServices];
    //[_networkPopOverController reloadNetwork];
}

#pragma mark - DragAndDropImageViewDelegate

- (void)dragDidFinished:(NSURL *)url
{
    if (_fileURL) {
        [_fileURL release];
    }
    _fileURL = [url retain];
    [_dragFileController.label setHidden:YES];
}

- (NSURL *)dataDraggedToSave
{
    if (_isView == kTextViewController) {
        return nil;
    } else if (_fileURL && _dragFileController.imageView.image != nil) {
        return _fileURL;
    }
    return nil;
}

#pragma mark - NetworkFoundDelegate

- (void)didSelectServiceName:(NSString *)serviceName
{
    _selectedServiceName = [serviceName retain];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem == _addFileItem && _isView == kDragFileController) {
        return YES;
    } else if (menuItem == _addFileItem && _isView == kTextViewController){
        return NO;
    }
    return YES;
}

@end
