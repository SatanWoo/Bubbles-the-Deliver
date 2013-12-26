//
//  DragAndDropImageView.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-1-15.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSImage+QuickLook.h"

@protocol DragAndDropImageViewDelegate <NSObject>

- (void)dragDidFinished:(NSURL *)url;
- (NSURL *)dataDraggedToSave;

@end

@interface DragAndDropImageView : NSImageView <NSDraggingSource, NSDraggingDestination> {
    
}

@property(nonatomic ,assign) id<DragAndDropImageViewDelegate>delegate;
- (id)initWithCoder:(NSCoder *)coder;
@end
