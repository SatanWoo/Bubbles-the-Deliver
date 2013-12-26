//
//  PreferenceViewContoller.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-1-20.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "PreferenceViewContoller.h"
#import "WDHeader.h"
#import "WDLocalization.h"

#define kGeneralIdentifier @"GeneralIdentifier"

@implementation PreferenceViewContoller

#pragma mark - Private Methods

- (void)refreshSavePathButton {
    // DW: 20121126 construct folder icon
    NSImage *folderIcon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    [folderIcon setScalesWhenResized:YES];
    [folderIcon setSize:NSMakeSize(16, 16)];
    
    // DW: 20121126 get folder name
    NSString *string = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultMacSavingPath];
    string = [[NSURL URLWithString:string] path];
    string = [[NSFileManager defaultManager] displayNameAtPath:string];
    
    [_savePathButton removeAllItems];
    [_savePathButton addItemWithTitle:string];
    [[_savePathButton itemAtIndex:0] setImage:folderIcon];
    
    [[_savePathButton menu] addItem:[NSMenuItem separatorItem]];
    [_savePathButton addItemWithTitle:kWDBubblePreferenceOther];
    
    [_toolBar setSelectedItemIdentifier:kGeneralIdentifier];
}

- (id)init {
    if (![super initWithWindowNibName:@"PreferenceViewController"]) {
        return nil;
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    [self refreshSavePathButton];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //DLog(@"haha is %@",[_savePathButton numberOfItems]);
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)dealloc
{
    [_selectDirectoryOpenPanel release];
    [super dealloc];
}

#pragma mark - IBAction

- (IBAction)choosePopUp:(NSPopUpButton *)sender
{
    if ([sender indexOfItem:[sender selectedItem]] == 2) {
        _selectDirectoryOpenPanel = [[NSOpenPanel openPanel] retain];
        [_selectDirectoryOpenPanel setCanChooseFiles:NO];
        [_selectDirectoryOpenPanel setCanChooseDirectories:YES];
        
        void (^selectFileDirectoryHandler)(NSInteger) = ^( NSInteger result )
        {
            if (result == NSCancelButton) {
                // Means Cancel 
                [_savePathButton selectItemAtIndex:0]; 
            } else {
                // Means Select
                NSURL *selectedFileURL = [_selectDirectoryOpenPanel URL];
                
                if(selectedFileURL) {
                    // DW: 20121126 save current path
                    [[NSUserDefaults standardUserDefaults] setValue:selectedFileURL.absoluteString forKey:kUserDefaultMacSavingPath];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self refreshSavePathButton];
                }
            }
            [NSApp stopModal];
        };
        
        [_selectDirectoryOpenPanel beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow
                                    completionHandler:selectFileDirectoryHandler];
    }
}

#pragma mark - NSToolbarItem

-(NSArray*) toolbarSelectableItemIdentifiers: (NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:kGeneralIdentifier,nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    return YES;
}


@end
