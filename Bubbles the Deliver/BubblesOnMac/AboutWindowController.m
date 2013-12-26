//
//  AboutWindowController.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-28.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "AboutWindowController.h"

@implementation AboutWindowController
@synthesize infoVersion;
@synthesize infoCopyright;
@synthesize infoProductName;

- (id)init
{
    self = [super initWithWindowNibName:@"AboutWindowController"];
    if (self) {
        
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.infoProductName setStringValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    [self.infoVersion setStringValue:[NSString stringWithFormat:@"%@ %@ (%@)",
                                      NSLocalizedString(@"VERSION", @"Version"),
                                      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 
                                      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
    [self.infoCopyright setStringValue:[NSString stringWithFormat:@"%@",NSLocalizedString([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"], @"All rights reversed")]];
    DLog(@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"]);
    //[self.infoProductName sizeToFit];
    //[self.infoVersion sizeToFit];
    //[self.infoCopyright sizeToFit];
}

- (void)dealloc
{
    [super dealloc];
}

@end
