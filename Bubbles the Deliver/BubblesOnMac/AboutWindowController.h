//
//  AboutWindowController.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-28.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController

@property (nonatomic, retain) IBOutlet NSTextField *infoProductName;
@property (nonatomic, retain) IBOutlet NSTextField *infoVersion;
@property (nonatomic, retain) IBOutlet NSTextField *infoCopyright;

@end
