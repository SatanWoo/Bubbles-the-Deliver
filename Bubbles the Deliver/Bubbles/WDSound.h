//
//  WDSound.h
//  Bubbles
//
//  Created by 王 得希 on 12-2-28.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kWDSoundFileSent        @"kWDSoundFileSent"
#define kWDSoundFileReceived    kWDSoundFileSent

@interface WDSound : NSObject {
    SystemSoundID _soundID;
    CFURLRef _soundFileURLRef;
}

- (void)playSoundForKey:(NSString *)key;

@end
