//
//  PeersViewController.h
//  Bubbles
//
//  Created by 王 得希 on 12-1-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDBubble.h"

@class ViewController;

@interface PeersViewController : UITableViewController

// DW: dimiss button is on iPhone
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissButton;

// DW: lock button is on iPad
@property (nonatomic, retain) IBOutlet UIBarButtonItem *lockButton;

@property (nonatomic, retain) WDBubble *bubble;

@property (nonatomic, retain) ViewController *viewController;

@end
