//
//  PasswordViewController.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-1-11.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PasswordMacViewControllerDelegate

- (void)didCancel;
- (void)didInputPassword:(NSString *)pwd;

@end

@interface PasswordMacViewController : NSWindowController {
    IBOutlet NSTextField *_textField;
    IBOutlet NSButton *_okButton;
    IBOutlet NSButton *_resetButton;
}

@property (nonatomic, retain) id<PasswordMacViewControllerDelegate> delegate;

- (IBAction)confirmPassword:(id)sender;
- (IBAction)resetPassword:(id)sender;

@end
