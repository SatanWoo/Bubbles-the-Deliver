//
//  WDLocalization.m
//  Bubbles
//
//  Created by 王 得希 on 12-3-18.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "WDLocalization.h"

@implementation WDLocalization

+ (NSString *)stringForKey:(NSString *)key {
    return NSLocalizedString(key, key);
}

@end
