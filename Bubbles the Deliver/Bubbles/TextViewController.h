//
//  TextViewController.h
//  Bubbles
//
//  Created by 王 得希 on 12-2-1.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextViewControllerDelegate
- (void)didFinishWithText:(NSString *)text;
@end

@interface TextViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UITextView *_textView;
    IBOutlet UIBarButtonItem *_done;
    IBOutlet UIBarButtonItem *_cancel;
    NSUndoManager *_undoManager;
}

@property (nonatomic, retain) NSUndoManager *undoManager;
@property (nonatomic, retain) id<TextViewControllerDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *popover;

- (void)setUpUndoManager;
- (void)cleanUpUndoManager;

@end
