//
//  ViewController.m
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UIImage+Resize.h"
#import "UIImage+Normalize.h"
#import "WDLocalization.h"
#import <MobileCoreServices/UTType.h>
#import <MobileCoreServices/UTCoreTypes.h>

#define kTableViewCellHeight        50

#define kSegmentControlFiles        0
#define kSegmentControlHistory      1

@implementation ViewController
@synthesize bubble = _bubble, launchFile = _launchFile, lockButton = _lockButton, selectedServiceName = _selectedServiceName;

+ (NSString*)mimeTypeForFileAtPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    }
    return [NSMakeCollectable((NSString *)mimeType) autorelease];
}

- (void)refreshLockStatus {
    BOOL usePassword = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsUsePassword];
    if (usePassword) {
        _lockButton.image = [UIImage imageNamed:@"lock_on.png"];
    } else {
        _lockButton.image = [UIImage imageNamed:@"lock_off.png"];
    }
}

- (UIImage *)refreshImageAtURL:(NSURL *)fileURL {
    // DW: firstly try image
    UIImage *image = [[[[UIImage imageWithContentsOfFile:[fileURL path]] normalize] resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                                                                         bounds:CGSizeMake(kTableViewCellHeight, kTableViewCellHeight)
                                                                                           interpolationQuality:kCGInterpolationHigh] 
                      croppedImage:CGRectMake(0, 0, kTableViewCellHeight, kTableViewCellHeight)];
    if (!image) {
        // DW: secondly a normal file
        if (fileURL) {
            UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:fileURL] retain];
            if (interactionController && interactionController.icons.count > 0) {
                image = [interactionController.icons objectAtIndex:0];
            } else {
                image = [UIImage imageNamed:@"Icon"];
            }
            [interactionController release];
        } else {
            image = [UIImage imageNamed:@"Icon"];
        }
    }
    
    // DW: finally we get a good image to show and cache
    [_thumbnails setObject:image forKey:fileURL.path.lastPathComponent];
    return image;
}

- (void)storeMessage:(WDMessage *)message {
    // DW: replace transfering messages if needed
    
    if ([message.state isEqualToString:kWDMessageStateFile]) {
        NSArray *originalMessages = [NSArray arrayWithArray:_messages];
        for (WDMessage *m in originalMessages) {
            if (([m.fileURL.path isEqualToString:message.fileURL.path])
                &&(![m.state isEqualToString:kWDMessageStateFile])) {
                // DW: found a message with same file path but "unstable" state, replace it
                [self refreshImageAtURL:m.fileURL];
                m.state = kWDMessageStateFile;
            };
        }
    } else {
        [_messages addObject:message];
    }
    
    [_messages sortUsingComparator:^(WDMessage *obj1, WDMessage * obj2) {
        if ([obj1.time compare:obj2.time] == NSOrderedAscending)
            return NSOrderedDescending;
        else if ([obj1.time compare:obj2.time] == NSOrderedDescending)
            return NSOrderedAscending;
        else
            return NSOrderedSame;
    }];
    [_messagesView reloadData];
}


// DW: NO for can not send, YES for will send
- (BOOL)sendToSelectedServiceOfMessage:(WDMessage *)message {
    if (!_selectedServiceName || [_selectedServiceName isEqualToString:@""]) {
        // DW: there is actually no receiver, so we do not send
        [self displayErrorMessage:kWDBubbleErrorMessageNoDeviceSelected];
        return NO;
    }
    
    // DW: if bubble is busy sending, skip the current send
    if ([self.bubble isBusy]) {
        [self displayErrorMessage:kWDBubbleErrorMessageDoNotSupportMultiple];
        return NO;
    }
    
    [_bubble sendMessage:message toServiceNamed:_selectedServiceName];
    return YES;
}

// DW: can only send images and movies for now.
- (void)sendFile {
    if (_fileURL) {
        // DW: a movie or JPG or PNG        
        WDMessage *t = [[WDMessage messageWithFile:_fileURL andState:kWDMessageStateReadyToSend] retain];
        
        // DW: we use one to one sending for now
        //[_bubble broadcastMessage:t];
        if (![self sendToSelectedServiceOfMessage:t]) {
            [t release];
            return;
        }
        
        // DW: store message metadata without content data
        [self storeMessage:t];
        [t release];
    } else {
        DLog(@"VC sendFile no good file URL");
    }
}

- (void)displayMailComposerSheetToDeveloepr {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) {
        return;
    }
    picker.mailComposeDelegate = self;
    [picker setToRecipients:[NSArray arrayWithObject:@"teamace.leavesoft@gmail.com"]];
    [picker setSubject:kEmailToDeveloperSubject];
    [picker setMessageBody:kEmailToDeveloperBody isHTML:NO];
    [self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)displayMailComposerSheetWithMessage:(WDMessage *)message {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (!picker) {
        return;
    }
    
	picker.mailComposeDelegate = self;
    
    if ([message.state isEqualToString: kWDMessageStateText]) {
        NSString *emailBody = [[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding] autorelease];
        [picker setMessageBody:emailBody isHTML:YES];
    } else {
        NSData *myData = [NSData dataWithContentsOfFile:message.fileURL.path];
        NSURLRequest *req = [NSURLRequest requestWithURL:message.fileURL];
        NSURLResponse *res = nil;
        [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:nil];
        DLog(@"VC displayMailComposerSheetWithMessage UTI %@", [res MIMEType]);
        [picker addAttachmentData:myData 
                         mimeType:[ViewController mimeTypeForFileAtPath:message.fileURL.path]
                         fileName:message.fileURL.lastPathComponent];
	}
    
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)displayMessageComposerSheetWithMessage:(WDMessage *)message {
    if (![MFMessageComposeViewController canSendText]) {
        return;
    }
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    if (!picker) {
        return;
    }
    
    picker.messageComposeDelegate = self;
    picker.body = [[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding] autorelease];
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)displayErrorMessage:(NSString *)message {
    [_messagesView reloadData];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:kWDBubbleErrorMessageTitle
                                                 message:message
                                                delegate:nil 
                                       cancelButtonTitle:kAlertViewOK
                                       otherButtonTitles:nil];
    [av show];
    [av release];
}

- (void)displayHelpSplashScreen {
    if (_helpViewController) {
        [_helpViewController release];
        _helpViewController = nil;
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
        //[self.view addSubview:_helpViewController.view];
        [self.navigationController.view addSubview:_helpViewController.view];
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController_iPad" bundle:nil];
        [self.splitViewController.view addSubview:_helpViewController.view];
    }
    
}

- (void)dismissOtherPopovers {
    // DW: we do not show multiple popovers at one time
    if (_popover) {
        [_popover dismissPopoverAnimated:YES];
        [_popover release];
        _popover = nil;
    }
    
    if (_actionSheet) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        [_actionSheet release];
        _actionSheet = nil;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {
        
    } else {
        DLog(@"VC Image %@ saved.", image);
    }
    //[_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
}

- (void)deleteMessageInURL:(NSURL *)fileURL {
    // DW: delete records in messages
    // iterating and removing with a new array
    NSArray *originalMessages = [NSArray arrayWithArray:_messages];
    for (WDMessage *m in originalMessages) {
        if ([m.fileURL.path.lastPathComponent isEqualToString:fileURL.path.lastPathComponent]) {
            [_messages removeObject:m];
        }
    }
}

// DW: this deletes acutal documents and their referencing messages if they have
- (void)deleteDocumentAndMessageInURL:(NSURL *)fileURL {
    // DW: delete cached thumbnail
    [_thumbnails removeObjectForKey:fileURL.path.lastPathComponent];
    
    [self deleteMessageInURL:fileURL];
    
    // DW: files not in messages can also be deleted here
    [[NSFileManager defaultManager] removeItemAtPath:fileURL.path
                                               error:nil];
}

// DW: scan and delete all files
- (void)deleteAllDocuments {
    // set up Add and Edit navigation items here....
    for (NSURL *fileURL in _documents) {
        [self deleteDocumentAndMessageInURL:fileURL];
    }
}

- (void)fillCell:(UITableViewCell *)cell withFileURL:(NSURL *)fileURL {
    // DW: we now cache all image files
    UIImage *image = [_thumbnails objectForKey:fileURL.path.lastPathComponent];
    if (!image) {
        image = [self refreshImageAtURL:fileURL];
    }
    cell.imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_bubble release];
    [_selectedServiceName release];
    [_messages release];
    [_documents release];
    [_directoryWatcher release];
    [_helpViewController release];
    [_currentNavigationItem release];
    
    [super dealloc];
}

#pragma mark - Public Methods

- (void)lock {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:kLockTitle
                                                 message:kLockContent
                                                delegate:self 
                                       cancelButtonTitle:kAlertViewCancel
                                       otherButtonTitles:kAlertViewOK, nil];
    av.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [av textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
    [av release];
}

- (void)restartBubbleWithPassword:(NSString *)password {
    [_selectedServiceName release];
    _selectedServiceName = nil;
    
    [_bubble stopService];
    [_bubble publishServiceWithPassword:password];
    [_bubble browseServices];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // DW: help
    NSDictionary *t = [NSDictionary dictionaryWithObject:@"YES" forKey:kUserDefaultsShouldShowHelp];
    [[NSUserDefaults standardUserDefaults] registerDefaults:t];
    
    // DW: sound
    _sound = [[WDSound alloc] init];
    
    // DW: user defauts
    t = [NSDictionary dictionaryWithObject:@"NO" forKey:kUserDefaultsUsePassword];
    [[NSUserDefaults standardUserDefaults] registerDefaults:t];
    
    // DW: NC
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(servicesUpdated:) 
                                                 name:kWDBubbleNotificationServiceUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(shouldLock:) 
                                                 name:kWDBubbleNotificationShouldLock
                                               object:nil];
    
    // DW: messages or files
    _selectedServiceName = nil;
    _thumbnails = [[NSMutableDictionary alloc] init];
    _messages = [[NSMutableArray alloc] init];
    _directoryWatcher = [[DirectoryWatcher watchFolderWithPath:[NSURL iOSDocumentsDirectoryPath] delegate:self] retain];
    _documents = [[NSMutableArray alloc] init];
    [self directoryDidChange:_directoryWatcher];
    if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
        _itemsToShow = _messages;
    } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
        _itemsToShow = _documents;
    }
    
    // DW: other UI
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _currentNavigationItem = [_bar.topItem retain];
        self.navigationController.navigationBar.hidden = YES;
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _currentNavigationItem = [self.navigationItem retain];
    }
    _currentNavigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        // DW: use password or not
        BOOL usePassword = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsUsePassword];
        if (usePassword) {
            [self lock];
        } else {
            
            // DW: 20130815 fix _bubble issue
            if (!_bubble) {
                _bubble = [[WDBubble alloc] init];
            }
            
            [_bubble publishServiceWithPassword:@""];
            [_bubble browseServices];
        }
        [self refreshLockStatus];
    }
    
    [_messagesView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // DW: launch file
    // DW: I give up doing this, since I can now present a preview on start,
    // and if it's in background and invoke to foreground, nothing will happen anyway.
    // This feature is now so well supported.
    /*
     if (_launchFile) {
     DLog(@"VC viewDidLoad %@", _launchFile);
     UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:_launchFile] retain];
     interactionController.delegate = self;
     DLog(@"VC viewDidLoad preview %d", [interactionController presentPreviewAnimated:YES]);
     }
     */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsShouldShowHelp]) {
        [self displayHelpSplashScreen];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {    
    [super setEditing:editing animated:animated];
    
    [_messagesView setEditing:editing animated:YES];
    if (editing) {
        [_currentNavigationItem setLeftBarButtonItem:_clearButton animated:YES];
    } else {
        [_currentNavigationItem setLeftBarButtonItem:nil animated:YES];
        [self dismissOtherPopovers];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) || (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - IBOultets

- (IBAction)sendText:(id)sender {
    TextViewController *vc = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
    vc.delegate = self;
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self dismissOtherPopovers];
        
        _popover = [[UIPopoverController alloc] initWithContentViewController:nv];
        vc.popover = _popover;
        UIBarButtonItem *b = (UIBarButtonItem *)sender;
        [_popover presentPopoverFromBarButtonItem:b permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:nv animated:YES];
    }
    
    [nv release];
    [vc release];
}

- (IBAction)selectFile:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *t = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            t.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        t.delegate = self;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [self dismissOtherPopovers];
            
            _popover = [[UIPopoverController alloc] initWithContentViewController:t];
            UIBarButtonItem *b = (UIBarButtonItem *)sender;
            [_popover presentPopoverFromBarButtonItem:b permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:t animated:YES];
            [t release];
        }
    }
}

- (IBAction)showPeers:(id)sender {
    PeersViewController *vc = [[PeersViewController alloc] initWithNibName:@"PeersViewController" bundle:nil];
    vc.viewController = self;
    vc.bubble = _bubble;
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nv animated:YES];
    
    [vc release];
    [nv release];
}

- (IBAction)showHelp:(id)sender {
    [self dismissOtherPopovers];
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@ (%@)", 
                                                         kMainViewVersion, 
                                                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 
                                                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]
                                               delegate:self 
                                      cancelButtonTitle:kActionSheetButtonCancel
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:kActionSheetButtonHelpEmail, kActionSheetButtonHelpRate, kActionSheetButtonHelpPDF, kActionSheetButtonHelpSplash, nil];
    [_actionSheet showFromBarButtonItem:(UIBarButtonItem *)sender animated:YES];
}

- (IBAction)toggleUsePassword:(id)sender {
    BOOL usePassword = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsUsePassword];
    usePassword = !usePassword;
    
    if (usePassword) {
        [self lock];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsUsePassword];
        [self restartBubbleWithPassword:@""];
        [self refreshLockStatus];
    }
}

- (IBAction)toggleView:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    if (sc.selectedSegmentIndex == kSegmentControlHistory) {
        _itemsToShow = _messages;
    } else if (sc.selectedSegmentIndex == kSegmentControlFiles) {
        _itemsToShow = _documents;
    }
    [_messagesView reloadData];
}

- (IBAction)clearButton:(id)sender {
    [self dismissOtherPopovers];
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self 
                                      cancelButtonTitle:kActionSheetButtonCancel
                                 destructiveButtonTitle:kActionSheetButtonDeleteAll
                                      otherButtonTitles:nil];
    [_actionSheet showFromBarButtonItem:_clearButton animated:YES];
}

#pragma mark - WDBubbleDelegate

- (void)percentUpdated {
    [_messagesView reloadData];
    //DLog(@"VC persent %f", [self.bubble percentTransfered]*100);
}

- (void)errorOccured:(NSError *)error {
    [self displayErrorMessage:kWDBubbleErrorMessageDisconnectWithError];
}

- (void)willReceiveMessage:(WDMessage *)message {
    [self storeMessage:message];
}

- (void)didReceiveMessage:(WDMessage *)message {
    message.time = [NSDate date];
    [self storeMessage:message];
    [_sound playSoundForKey:kWDSoundFileReceived];
}

- (void)didSendMessage:(WDMessage *)message {
    message.state = kWDMessageStateFile;
    [_sound playSoundForKey:kWDSoundFileSent];
}

- (void)didTerminateReceiveMessage:(WDMessage *)message {
    [self displayErrorMessage:kWDBubbleErrorMessageTerminatedBySender];
    [self deleteDocumentAndMessageInURL:message.fileURL];
    [_messagesView reloadData];
}

- (void)didTerminateSendMessage:(WDMessage *)message {
    [self deleteMessageInURL:message.fileURL];
    [_messagesView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    DLog(@"VC didFinishPickingMediaWithInfo %@", info);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [_popover dismissPopoverAnimated:YES];
        [_popover release];
    }
    
    if (_fileURL) {
        [_fileURL release];
        _fileURL = nil;
    }
    
    NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSString *fileName = [[info valueForKey:UIImagePickerControllerReferenceURL] lastPathComponent];
        //fileName = [NSString stringWithFormat:@".%@", fileName];
        NSString *fileExtention = [[[info valueForKey:UIImagePickerControllerReferenceURL] pathExtension] lowercaseString];
        NSData *fileData = nil;
        
        // 20120209 DW: we changed back to previous rule, store files selected from photo album to /Documents
        NSURL *storeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", 
                                                [NSURL iOSDocumentsDirectoryURL], 
                                                [fileName lowercaseString]]];
        storeURL = [storeURL URLWithoutNameConflict];
        if ([fileExtention isEqualToString:@"jpg"]) {
            fileData = UIImageJPEGRepresentation(image, 1.0);
            [fileData writeToURL:storeURL atomically:YES];
            _fileURL = [storeURL retain];
        } else {
            DLog(@"VC didFinishPickingMediaWithInfo %@ not JPG", fileExtention);
            fileData = UIImagePNGRepresentation(image);
            [fileData writeToURL:storeURL atomically:YES];
            _fileURL = [storeURL retain];
        }
        DLog(@"VC didFinishPickingMediaWithInfo URL is %@", _fileURL.path);
        [self sendFile];
    } else if ([mediaType isEqualToString:@"public.movie"]) {
        _fileURL = [[info valueForKey:UIImagePickerControllerMediaURL] retain];
        DLog(@"VC didFinishPickingMediaWithInfo select %@", _fileURL.path);
        [self sendFile];
    } else {
        _fileURL = nil;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - PasswordViewControllerDelegate

- (void)didInputPassword:(NSString *)pwd {
    [_bubble publishServiceWithPassword:pwd];
    [_bubble browseServices];
}

#pragma mark - TextViewControllerDelegate

- (void)didFinishWithText:(NSString *)text {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [_popover dismissPopoverAnimated:YES];
        [_popover release];
    }
    
    WDMessage *t = [[WDMessage messageWithText:text] retain];
    if (![self sendToSelectedServiceOfMessage:t]) {
        [t release];
        return;
    }
    [self storeMessage:t];
    [t release];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *NUMBERS = @"0123456789";
    if ([NUMBERS rangeOfString:string].location == NSNotFound) {
        return NO;
    }
    return YES;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"VC clickedButtonAtIndex %i", buttonIndex);
    if (buttonIndex == 0) {
        // DW: user canceled
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsUsePassword];
        [self restartBubbleWithPassword:@""];
    } else if (buttonIndex == 1) {
        // DW: user inputed password
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsUsePassword];
        [self restartBubbleWithPassword:[alertView textFieldAtIndex:0].text];
    }
    
    [self refreshLockStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWDBubbleNotificationDidEndLock object:nil];
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WDMessage *t = nil;
    [self dismissOtherPopovers];
    
    // DW: construct a WDMessage
    if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
        t = [[_messages objectAtIndex:indexPath.row] retain];
    } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
        NSURL *fileURL = [_documents objectAtIndex:indexPath.row];
        t = [[WDMessage messageWithFile:fileURL andState:kWDMessageStateFile] retain];
    }
    
    // DW: chose an action
    if ([t.state isEqualToString: kWDMessageStateText]) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self 
                                          cancelButtonTitle:kActionSheetButtonCancel
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:kActionSheetButtonCopy, kActionSheetButtonEmail, kActionSheetButtonSend, kActionSheetButtonMessage, nil];
    } else if ([t.state isEqualToString:kWDMessageStateFile]) {
        if ([WDMessage isImageURL:t.fileURL]) {
            _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self 
                                              cancelButtonTitle:kActionSheetButtonCancel
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:kActionSheetButtonCopy, kActionSheetButtonEmail, kActionSheetButtonSend, kActionSheetButtonPreview, kActionSheetButtonSave, nil];
        } else {
            _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self 
                                              cancelButtonTitle:kActionSheetButtonCancel
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:kActionSheetButtonEmail, kActionSheetButtonSend, kActionSheetButtonPreview, nil];
        }
    } else  {
        // DW: states such as kWDMessageStateReadyToReceive, kWDMessageStateReadyToSend, kWDMessageStateSending
        // we can do a "Pause" feature here
        DLog(@"VC didSelectRowAtIndexPath %@", t.state);
        _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self 
                                          cancelButtonTitle:kActionSheetButtonCancel
                                     destructiveButtonTitle:kActionSheetButtonTransferTerminate
                                          otherButtonTitles:nil];
    }
    
    if (_actionSheet) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [_actionSheet showFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:_messagesView animated:YES];
        } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [_actionSheet showFromToolbar:self.navigationController.toolbar];
        }
    }
    
    [t release];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    // DW: we can use here to hide bar buttons
    if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
        BOOL canShowEditButton = (_messages.count > 0);
        [_currentNavigationItem setRightBarButtonItem:canShowEditButton?self.editButtonItem:nil];
        if (!canShowEditButton) {
            [self setEditing:NO];
        }
    } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
        BOOL canShowEditButton = (_documents.count > 0);
        [_currentNavigationItem setRightBarButtonItem:(_documents.count > 0)?self.editButtonItem:nil];
        if (!canShowEditButton) {
            [self setEditing:NO];
        }
    }
    
    return _itemsToShow.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
        [_messages removeObjectAtIndex:indexPath.row];
    } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
        NSURL *fileURL = [_documents objectAtIndex:indexPath.row];
        [self deleteDocumentAndMessageInURL:fileURL];
        [_documents removeObjectAtIndex:indexPath.row];
    }
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] 
                     withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self 
                                                                                                        action:@selector(longPress:)] autorelease];
		[cell addGestureRecognizer:longPressGesture];
    }
    
    // Configure the cell...
    cell.textLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    
    if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
        // DW: messages, AKA "History"
        
        WDMessage *t = [_itemsToShow objectAtIndex:indexPath.row];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"hh:mm:ss";
        cell.detailTextLabel.text = [t.sender stringByAppendingFormat:@" %@", [df stringFromDate:t.time]];
        [df release];
        if ([t.state isEqualToString: kWDMessageStateText]) {
            //DLog(@"VC cellForRowAtIndexPath t is %@", t);
            cell.textLabel.text = [[[NSString alloc] initWithData:t.content encoding:NSUTF8StringEncoding] autorelease];
            cell.imageView.image = [UIImage imageNamed:@"Icon-Text"];
        } else {
            // if ([t.state isEqualToString:kWDMessageStateFile])
            cell.textLabel.text = [t.fileURL lastPathComponent];
            
            // DW: we show percentage we transfered the file here
            if (([t.state isEqualToString:kWDMessageStateReadyToSend])
                ||([t.state isEqualToString:kWDMessageStateSending])) {
                cell.textLabel.text = [NSString stringWithFormat:@"%.0f%% %@ sent", 
                                       [self.bubble percentTransfered]*100, 
                                       [NSURL formattedFileSize:[self.bubble bytesTransfered]]];
            } else if (([t.state isEqualToString:kWDMessageStateReadyToReceive])
                       ||([t.state isEqualToString:kWDMessageStateReceiving])) {
                cell.textLabel.text = [NSString stringWithFormat:@"%.0f%% %@ received", 
                                       [self.bubble percentTransfered]*100, 
                                       [NSURL formattedFileSize:[self.bubble bytesTransfered]]];
            }
            
            [self fillCell:cell withFileURL:t.fileURL];
        }
    } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
        NSURL *fileURL = [_documents objectAtIndex:indexPath.row];
        
        UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:fileURL] retain];
        
        
        cell.textLabel.text = [[fileURL path] lastPathComponent];
        
        // DW: we show percentage we transfered the file here
        
        [self fillCell:cell withFileURL:fileURL];
        
        // DW: size info in detail label
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:interactionController.URL.path error:nil];
        NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                     [NSURL formattedFileSize:fileSize], interactionController.UTI];
        [interactionController release];
    }
    
    return cell;
}

// DW: we recognize long press since we hope to show full name of a file without any dots
- (void)longPress:(UILongPressGestureRecognizer *)gesture {
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan) {
		// get affected cell
		UITableViewCell *cell = (UITableViewCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [_messagesView indexPathForCell:cell];
        
		// do something with this action
		NSLog(@"Long-pressed cell at row %@", indexPath);
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewCellHeight;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    // DW: special actions that do not need WDMessage
    if ([buttonTitle isEqualToString:kActionSheetButtonDeleteAll]) {
        if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
            [_messages removeAllObjects];
        } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
            [self deleteAllDocuments];
            [_documents removeAllObjects];
        }
        [_messagesView reloadData];
        [self setEditing:NO animated:YES];
        return;
    } else if ([buttonTitle isEqualToString:kActionSheetButtonHelpEmail]) {
        [self displayMailComposerSheetToDeveloepr];
        return;
    } else if ([buttonTitle isEqualToString:kActionSheetButtonHelpRate]) {
        NSString *url = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", @"506646552"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        return;
    } else if ([buttonTitle isEqualToString:kActionSheetButtonHelpPDF]) {
        NSURL *manualURL = [[NSBundle mainBundle] URLForResource:@"Manual" withExtension:@"pdf"];
        UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:manualURL] retain];
        interactionController.delegate = self;
        [interactionController presentPreviewAnimated:YES];
        return;
    } else if ([buttonTitle isEqualToString:kActionSheetButtonHelpSplash]) {
        [self displayHelpSplashScreen];
        return;
    } else if ([buttonTitle isEqualToString:kActionSheetButtonCancel]) {
        // DW: just refresh to avoid a selected cell
        [_messagesView reloadData];
        if (_actionSheet) {
            [_actionSheet release];
            _actionSheet = nil;
        }
        return;
    } else if ([buttonTitle isEqualToString:kActionSheetButtonMacApp]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/deliver/id506655546?ls=1&mt=12"]];
        return;
    }
    
    // DW: construct a WDMessage
    WDMessage *message = nil;
    if (_segmentSwith.selectedSegmentIndex == kSegmentControlHistory) {
        // DW: messages
        message = [[_messages objectAtIndex:[_messagesView indexPathForSelectedRow].row] retain];
    } else if (_segmentSwith.selectedSegmentIndex == kSegmentControlFiles) {
        NSURL *fileURL = [_documents objectAtIndex:_messagesView.indexPathForSelectedRow.row];
        message = [[WDMessage messageWithFile:fileURL andState:kWDMessageStateFile] retain];
    }
    
    // DW: chose an action
    if ([buttonTitle isEqualToString:kActionSheetButtonEmail]) {
        [self displayMailComposerSheetWithMessage:message];
    } else if ([buttonTitle isEqualToString:kActionSheetButtonMessage]) {
        [self displayMessageComposerSheetWithMessage:message];
    } else if ([buttonTitle isEqualToString:kActionSheetButtonCopy]) {
        if ([message.state isEqualToString: kWDMessageStateText]) {
            [UIPasteboard generalPasteboard].string = [[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding] autorelease];
        } else if ([message.state isEqualToString:kWDMessageStateFile]) {
            [UIPasteboard generalPasteboard].image = [UIImage imageWithContentsOfFile:message.fileURL.path];
        }
    } else if ([buttonTitle isEqualToString:kActionSheetButtonPreview]) {
        UIDocumentInteractionController *interactionController = [[UIDocumentInteractionController interactionControllerWithURL:message.fileURL] retain];
        interactionController.delegate = self;
        
        BOOL result = [interactionController presentPreviewAnimated:YES];
        if (!result) {
            // DW: file not supproted
            DLog(@"VC upported or currpted file.");
        }
    } else if ([buttonTitle isEqualToString:kActionSheetButtonSave]) {
        UIImage *image = [UIImage imageWithContentsOfFile:message.fileURL.path];
        if (image) {
            UIImageWriteToSavedPhotosAlbum(image, 
                                           self, 
                                           @selector(image:didFinishSavingWithError:contextInfo:), 
                                           nil);
        }
    } else if ([buttonTitle isEqualToString:kActionSheetButtonCancel]) {
        [_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
    } else if ([buttonTitle isEqualToString:kActionSheetButtonSend]) {
        WDMessage *t = nil;        
        if ([message.state isEqualToString: kWDMessageStateText]) {
            t = [[WDMessage messageWithText:[[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding] autorelease]] retain];
        } else if ([message.state isEqualToString:kWDMessageStateFile]) {
            t = [[WDMessage messageWithFile:message.fileURL andState:kWDMessageStateReadyToSend] retain];
        }
        
        if (![self sendToSelectedServiceOfMessage:t]) {
            [t release];
            return;
        }
        [self storeMessage:t];
        [t release];
    } else if ([buttonTitle isEqualToString:kActionSheetButtonTransferTerminate]) {
        [self.bubble terminateTransfer];
        
        // DW: delete any unstable state files
        NSArray *arrayOriginalMessages = [NSArray arrayWithArray:_messages];
        for (WDMessage *m in arrayOriginalMessages) {
            if (!(([m.state isEqualToString:kWDMessageStateFile])
                  ||([m.state isEqualToString:kWDMessageStateText]))) {
                [self deleteDocumentAndMessageInURL:m.fileURL];
            }
        }
        [_messagesView reloadData];
    }
    
    [message release];
    [_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    DLog(@"VC actionSheetCancel");
    //[actionSheet release];
    //[_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
    //[_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissModalViewControllerAnimated:YES];
    //[_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [controller release];
    //[_messagesView deselectRowAtIndexPath:[_messagesView indexPathForSelectedRow] animated:YES];
}

#pragma mark - DirectoryWatcherDelegate

- (void)directoryDidChange:(DirectoryWatcher *)directoryWatcher {
    [_thumbnails removeAllObjects];
	[_documents removeAllObjects];    // clear out the old docs and start over
    
    [_documents addObjectsFromArray:[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL iOSDocumentsDirectoryURL] 
                                                                  includingPropertiesForKeys:nil 
                                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                                                       error:nil]];
    // DW: we need to skip folders here
    NSArray *originalDocuments = [NSArray arrayWithArray:_documents];
    for (NSURL *url in originalDocuments) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory]) {
            if (isDirectory) {
                [_documents removeObject:url];
            }
        }
    }
    
    [_documents sortUsingComparator:^(NSURL *obj1, NSURL * obj2) {
        // DW: give up sort by creation date since it's not recording what we do with it
        /*
         NSDictionary *dict1 = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1.path error:nil];
         NSDictionary *dict2 = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2.path error:nil];
         NSDate *creationDate1 = [dict1 objectForKey:NSFileCreationDate];
         NSDate *creationDate2 = [dict2 objectForKey:NSFileCreationDate];
         if ([creationDate1 compare:creationDate2] == NSOrderedAscending)
         return NSOrderedDescending;
         else if ([creationDate1 compare:creationDate2] == NSOrderedDescending)
         return NSOrderedAscending;
         else
         return NSOrderedSame;
         */
        return [obj1.path.lowercaseString compare:obj2.path.lowercaseString];
    }];
    
    [_messagesView reloadData];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [popoverController release];
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [_currentNavigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //self.masterPopoverController = popoverController;
    
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [_currentNavigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
}

#pragma mark - NC

- (void)servicesUpdated:(NSNotification *)notification {
    if (self.bubble.servicesFound.count > 1) {
        
        // DW: if we already have one service selected, we do not update the selection now
        if (_selectedServiceName) {
            for (NSNetService *s in self.bubble.servicesFound) {
                if ([_selectedServiceName isEqualToString:s.name]) {
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
        }
    } else {
        if (_selectedServiceName) {
            [_selectedServiceName release];
        }
        _selectedServiceName = nil;
    }
}

- (void)shouldLock:(NSNotification *)notification {
    [self lock];
}

@end
