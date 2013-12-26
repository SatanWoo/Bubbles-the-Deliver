//
//  TextViewController.m
//  Bubbles
//
//  Created by 王 得希 on 12-2-1.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "TextViewController.h"
#import "WDLocalization.h"

@implementation TextViewController
@synthesize undoManager = _undoManager, popover = _popover, delegate;

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)dismiss {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc { 
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // DW: custom bar bg
    // this will appear as the title in the navigation bar
    self.title = kMainViewText;
    self.navigationItem.rightBarButtonItem = _done;
    self.navigationItem.leftBarButtonItem = _cancel;
    _done.enabled = NO;
    [self registerForKeyboardNotifications];    
    [self setUpUndoManager];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self cleanUpUndoManager];
}

/*
 The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.
 */
- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - IBActions

- (IBAction)cancelEditing:(id)sender {
    [_textView resignFirstResponder];
    [self dismiss];
}

- (IBAction)doneEditing:(id)sender {
    //self.navigationItem.rightBarButtonItem = nil;
    [_textView resignFirstResponder];
    [self.delegate didFinishWithText:_textView.text];
    [self dismiss];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    //self.navigationItem.rightBarButtonItem = _done;
    //[self.navigationItem setHidesBackButton:YES animated:YES];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _done.enabled = textView.text.length > 0;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    //[_textView resignFirstResponder];
    //[self performSelector:@selector(keyboardWillBeHidden:) withObject:nil];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    return YES;
}

#pragma mark - Undo support

- (void)setUpUndoManager {
	/*
	 If the diary's managed object context doesn't already have an undo manager, then create one and set it for the context and self.
	 The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
	 */
    NSUndoManager *anUndoManager = [[NSUndoManager alloc] init];
    [anUndoManager setLevelsOfUndo:3];
    self.undoManager = anUndoManager;
    [anUndoManager release];
	
	// Register as an observer of the diary's context's undo manager.
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self selector:@selector(undoManagerDidUndo:) name:NSUndoManagerDidUndoChangeNotification object:anUndoManager];
	[dnc addObserver:self selector:@selector(undoManagerDidRedo:) name:NSUndoManagerDidRedoChangeNotification object:anUndoManager];
}

- (void)cleanUpUndoManager {
	
	// Remove self as an observer.
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    self.undoManager = nil;
}

- (NSUndoManager *)undoManager {
	return _undoManager;
}

- (void)undoManagerDidUndo:(NSNotification *)notification {
	//[self updateRightBarButtonItemState];
}


- (void)undoManagerDidRedo:(NSNotification *)notification {
	//[self updateRightBarButtonItemState];
}

#pragma mark - Keyboard

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    DLog(@"kbh %f, %f", kbSize.width, kbSize.height);
    UIEdgeInsets contentInsets;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        } else {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.width, 0.0);
        }
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // DW: actually iPad is much clever than iPhone, we can do nothing here
        contentInsets = UIEdgeInsetsZero;
    }
    
    _textView.contentInset = contentInsets;
    _textView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _textView.contentInset = contentInsets;
    _textView.scrollIndicatorInsets = contentInsets;
}

@end
