//
//  WDSound.m
//  Bubbles
//
//  Created by 王 得希 on 12-2-28.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "WDSound.h"

@implementation WDSound

- (void)dealloc {
    AudioServicesDisposeSystemSoundID (_soundID);
    CFRelease (_soundFileURLRef);
    
    [super dealloc];
}

- (void)prepareEffects {
    // kWDSoundFileReceived
    NSURL * tapSound = [[NSBundle mainBundle] URLForResource:kWDSoundFileSent withExtension: @"aif"];
    _soundFileURLRef = (CFURLRef)[tapSound retain];
	AudioServicesCreateSystemSoundID(_soundFileURLRef, &_soundID);
}

- (id)init {
    if (self = [super init]) {
        [self prepareEffects];
    }
    return self;
}

#pragma mark - Public Methods

- (void)playSoundForKey:(NSString *)key {
    AudioServicesPlaySystemSound(_soundID);
}

@end
