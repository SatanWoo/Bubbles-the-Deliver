//
//  NSView+NSView_Fade_.m
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-9.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "NSView+NSView_Fade_.h"

@implementation NSView (NSView_Fade_)
- (void)setHidden:(BOOL)hidden withFade:(BOOL)fade
{
    if(!fade) {
    // The easy way out.  Nothing to do here...
        [self setHidden:hidden];
    } else {
        if(!hidden) {
            // If we're unhiding, make sure we queue an unhide before the animation
            [self setHidden:NO];
        }
        NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [animDict setObject:self forKey:NSViewAnimationTargetKey];
        [animDict setObject:(hidden ? NSViewAnimationFadeOutEffect : NSViewAnimationFadeInEffect) forKey:NSViewAnimationEffectKey];
        NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animDict]];
        [anim setDuration:0.5];
        [anim startAnimation];
        [anim autorelease];
    }
}
@end
