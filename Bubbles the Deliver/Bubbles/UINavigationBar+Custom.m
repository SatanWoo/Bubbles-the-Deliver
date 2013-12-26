//
//  UINavigationBar+Custom.m
//  Bubbles
//
//  Created by 王 得希 on 12-2-1.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "UINavigationBar+Custom.h"

@implementation UINavigationBar (Custom)

- (void)drawRect:(CGRect)rect {
	UIImage* navigationBarBackgroundImage = [UIImage imageNamed:@"tile_bg"];
	if (navigationBarBackgroundImage)
		[navigationBarBackgroundImage drawInRect:rect];
	else
		[super drawRect:rect];	
}

@end
