//
//  AppDelegate.m
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "PeersViewController.h"

@implementation AppDelegate

@synthesize window = _window, bubble = _bubble;
@synthesize peersViewController = _peersViewController, viewController = _viewController, splitViewController = _splitViewController, navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // DW: we support opening files, check launchOptions here
    NSURL *newURL = nil;
    if (launchOptions) {
        // DW: move files in "Inbox" folder to "Documents"
        NSURL *fileURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        newURL = [fileURL URLByMovingToParentFolder];
        DLog(@"AppDelegate didFinishLaunchingWithOptions Old: %@; new: %@.", fileURL, newURL);
        [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newURL error:nil];
    }
    
    _bubble = [[WDBubble alloc] init];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        
        ViewController *detailViewController = self.viewController;//[[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
        //UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
        detailViewController.bubble = _bubble;
        detailViewController.launchFile = newURL;
        _bubble.delegate = detailViewController;
        
        
        // DW: 20130815, fix iPad no peers view issue
        if (!self.peersViewController) {
            self.peersViewController = [[PeersViewController alloc] initWithNibName:@"PeersViewController_iPad" bundle:nil];
        }
        
        PeersViewController *masterViewController = self.peersViewController;//[[[PeersViewController alloc] initWithNibName:@"PeersViewController_iPad" bundle:nil] autorelease];
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        masterViewController.bubble = _bubble;
        masterViewController.viewController = detailViewController;
        
        //self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailViewController, nil];
        
        self.window.rootViewController = self.splitViewController;
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        // Override point for customization after application launch.
        //self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
        if (self.viewController.bubble) {
            _bubble = self.viewController.bubble;
        } else {
            self.viewController.bubble = _bubble;
        }
        self.viewController.launchFile = newURL;
        _bubble.delegate = self.viewController;
        
        // DW: we use navigation controller now
        self.window.rootViewController = self.navigationController;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    //[_bubble stopService];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [_bubble terminateTransfer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    // DW: check if there is new file in Inbox
    NSArray *inboxFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL iOSInboxDirectoryURL]
                                                        includingPropertiesForKeys:nil
                                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                             error:nil];
    for (NSURL *url in inboxFiles) {
        [[NSFileManager defaultManager] moveItemAtURL:url toURL:[[url URLByMovingToParentFolder] URLWithoutNameConflict] error:nil];
    }
    
    BOOL usePassword = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsUsePassword];
    if (usePassword) {
        [self.viewController lock];
    } else {
        [_bubble stopService];
        [_bubble publishServiceWithPassword:@""];
        [_bubble browseServices];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    // DW: we do not delete all files now, :-)
    //[self scanDocuments];
}

@end
