//
//  AppDelegate.h
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PeersViewController;
@class ViewController;
@class WDBubble;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) WDBubble *bubble;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PeersViewController *peersViewController;

@property (nonatomic, retain) IBOutlet ViewController *viewController;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
