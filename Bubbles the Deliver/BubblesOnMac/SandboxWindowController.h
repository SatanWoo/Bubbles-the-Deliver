//
//  SandboxWindowController.h
//  Bubbles
//
//  Created by 王得希 on 12-11-26.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SandboxWindowController : NSWindowController {
    IBOutlet NSPopUpButton *_savePathButton;
    NSOpenPanel *_selectDirectoryOpenPanel;
}

@end
