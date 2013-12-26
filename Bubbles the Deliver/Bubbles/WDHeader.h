//
//  WDHeader.h
//  Bubbles
//
//  Created by 王 得希 on 12-1-31.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#ifndef Bubbles_WDHeader_h
#define Bubbles_WDHeader_h

//#define TEMP_USE_OLD_WDBUBBLE

// DW: user defaults
#define kUserDefaultMacSavingPath       @"kNewUserDefaultMacSavingPath"
#define kUserDefaultsUsePassword        @"kUserDefaultsUsePassword"
#define kUserDefaultsShouldShowHelp     @"kUserDefaultsShouldShowHelp"

// DW: network
#define kWDBubbleInitialDomain  @""
#define kWDBubbleTimeOut        -1

// DW: different platforms have different web service type
#define kWDBubbleWebServiceTypeCount   3
#define kWDBubbleWebServiceTypePhone    @"_phone_bubbles"
#define kWDBubbleWebServiceTypePad      @"_pad_bubbles"
#define kWDBubbleWebServiceTypeMac      @"_mac_bubbles"
// DW: these types are always followed by "._tcp."

// DW: notifications
#define kWDBubbleNotificationServiceUpdated @"kWDBubbleNotificationServiceUpdated"
#define kWDBubbleNotificationShouldLock     @"kWDBubbleNotificationShouldLock"
#define kWDBubbleNotificationDidEndLock     @"kWDBubbleNotificationDidEndLock"

#endif
