//
//  WDLocalization.h
//  Bubbles
//
//  Created by 王 得希 on 12-3-18.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#ifndef Bubbles_WDLocalization_h
#define Bubbles_WDLocalizationr_h

#import <Foundation/Foundation.h>

// DW: normal actions
#define kActionSheetButtonCopy      [WDLocalization stringForKey:@"kActionSheetButtonCopy"]
#define kActionSheetButtonEmail     [WDLocalization stringForKey:@"kActionSheetButtonEmail"]
#define kActionSheetButtonSend      [WDLocalization stringForKey:@"kActionSheetButtonSend"]
#define kActionSheetButtonMessage   [WDLocalization stringForKey:@"kActionSheetButtonMessage"]
#define kActionSheetButtonPreview   [WDLocalization stringForKey:@"kActionSheetButtonPreview"]
#define kActionSheetButtonSave      [WDLocalization stringForKey:@"kActionSheetButtonSave"]
// DW: help actions
#define kActionSheetButtonHelpEmail     [WDLocalization stringForKey:@"kActionSheetButtonHelpEmail"]
#define kActionSheetButtonHelpRate      [WDLocalization stringForKey:@"kActionSheetButtonHelpRate"]
#define kActionSheetButtonHelpPDF       [WDLocalization stringForKey:@"kActionSheetButtonHelpPDF"]
#define kActionSheetButtonHelpSplash    [WDLocalization stringForKey:@"kActionSheetButtonHelpSplash"]
#define kActionSheetButtonMacApp        [WDLocalization stringForKey:@"kActionSheetButtonMacApp"]
// DW: transfer actions
#define kActionSheetButtonTransferTerminate [WDLocalization stringForKey:@"kActionSheetButtonTransferTerminate"]
// DW: edit actions
#define kActionSheetButtonCancel    [WDLocalization stringForKey:@"kActionSheetButtonCancel"]
#define kActionSheetButtonDeleteAll [WDLocalization stringForKey:@"kActionSheetButtonDeleteAll"]

// DW: main view
#define kMainViewText       [WDLocalization stringForKey:@"kMainViewText"]
#define kMainViewPeers      [WDLocalization stringForKey:@"kMainViewPeers"]
#define kMainViewVersion    [WDLocalization stringForKey:@"kMainViewVersion"]
#define kMainViewLocal      [WDLocalization stringForKey:@"kMainViewLocal"]

// DW: error messages
#define kWDBubbleErrorMessageTitle                  [WDLocalization stringForKey:@"kWDBubbleErrorMessageTitle"]
#define kWDBubbleErrorMessageTerminatedBySender     [WDLocalization stringForKey:@"kWDBubbleErrorMessageTerminatedBySender"]
#define kWDBubbleErrorMessageDisconnectWithError    [WDLocalization stringForKey:@"kWDBubbleErrorMessageDisconnectWithError"]
#define kWDBubbleErrorMessageDoNotSupportMultiple   [WDLocalization stringForKey:@"kWDBubbleErrorMessageDoNotSupportMultiple"]
#define kWDBubbleErrorMessageNoDeviceSelected       [WDLocalization stringForKey:@"kWDBubbleErrorMessageNoDeviceSelected"]

// DW: OS X, Others...
#define kWDBubblePreferenceOther    [WDLocalization stringForKey:@"kWDBubblePreferenceOther"]

// DW: lock
#define kLockTitle      [WDLocalization stringForKey:@"kLockTitle"]
#define kLockContent    [WDLocalization stringForKey:@"kLockContent"]

// DW: alert view
#define kAlertViewOK        [WDLocalization stringForKey:@"kAlertViewOK"]
#define kAlertViewCancel    [WDLocalization stringForKey:@"kAlertViewCancel"]

// DW: to developer email
#define kEmailToDeveloperSubject    [WDLocalization stringForKey:@"kEmailToDeveloperSubject"]
#define kEmailToDeveloperBody       [WDLocalization stringForKey:@"kEmailToDeveloperBody"]

@interface WDLocalization : NSObject

+ (NSString *)stringForKey:(NSString *)key;

@end

#endif
