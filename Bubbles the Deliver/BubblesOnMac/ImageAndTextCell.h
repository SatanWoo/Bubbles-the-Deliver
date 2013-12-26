//
//  ImageAndTextCell.h
//  Bubbles
//
//  Created by 吴 wuziqi on 12-2-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@protocol ImageAndTextCellDelegate <NSObject>
- (NSImage *)previewIconForCell:(NSObject *)data;
- (NSString *)primaryTextForCell:(NSObject *)data;
- (NSString *)auxiliaryTextForCell:(NSObject *)data;
- (NSURL *)URLForCell:(NSObject *)data;
@end

@interface ImageAndTextCell : NSTextFieldCell
{
    NSImage *_previewImage;
    NSString *_auxiliaryText;
    NSString *_primaryText;
    NSURL *_fileURL;
}
@property (nonatomic , retain) NSImage *previewImage;
@property (nonatomic , copy) NSString *auxiliaryText;
@property (nonatomic , copy) NSString *primaryText;
@property (nonatomic , retain) NSURL *fileURL;
@property (nonatomic , assign) id<ImageAndTextCellDelegate> delegate;

@end
