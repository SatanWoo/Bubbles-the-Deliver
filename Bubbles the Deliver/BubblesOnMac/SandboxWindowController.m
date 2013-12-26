//
//  SandboxWindowController.m
//  Bubbles
//
//  Created by 王得希 on 12-11-26.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "SandboxWindowController.h"
#import "WDHeader.h"
#import "WDLocalization.h"

@interface SandboxWindowController ()

@end

@implementation SandboxWindowController

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
    
}

- (id)init
{
    self = [super initWithWindowNibName:@"SandboxWindowController"];
    if (self) {
        // Initialization code here.
        [NSApp endSheet:[self window]];
        [[self window] orderOut:nil];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self refreshSavePathButton];
}

#pragma mark - IBAction

- (IBAction)ok:(id)sender {
    [NSApp endSheet:[self window]];
    [[self window] orderOut:sender];
}

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

@end
