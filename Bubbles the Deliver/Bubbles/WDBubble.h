//
//  WDBubbleService.h
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "WDMessage.h"
#import "WDHeader.h"

@interface NSURL (Bubbles)

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
+ (NSURL *)iOSDocumentsDirectoryURL;
+ (NSString *)iOSDocumentsDirectoryPath;
+ (NSURL *)iOSInboxDirectoryURL;
#elif TARGET_OS_MAC
#endif
+ (NSString *)formattedFileSize:(unsigned long long)size;

- (NSURL *)URLByMovingToParentFolder;
- (NSURL *)URLWithRemoteChangedToLocal;
- (NSURL *)URLWithoutNameConflict;

@end

@protocol WDBubbleDelegate
- (void)percentUpdated;
- (void)errorOccured:(NSError *)error;

- (void)willReceiveMessage:(WDMessage *)message;
- (void)didReceiveMessage:(WDMessage *)message;
- (void)didSendMessage:(WDMessage *)message;
- (void)didTerminateReceiveMessage:(WDMessage *)message;
- (void)didTerminateSendMessage:(WDMessage *)message;
@end

@interface WDBubble : NSObject <AsyncSocketDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate> {
    // DW: Bonjour
    NSNetService *_service;
    NSMutableArray *_servicesFound;
    NSString *_netServiceType;
    NSArray *_supportedNetServiceTypes;
    NSMutableArray *_browsers;
    
    // DW: sockets
	AsyncSocket *_socketListen;
    AsyncSocket *_socketReceive;
    NSMutableArray *_socketsConnect;
    
    // DW: Message
    WDMessage *_currentMessage;
    NSMutableData *_dataBuffer;
    
    // DW: stating system
    BOOL _isReceiver;
    // DW: whether it's a receiver or sender during a socket connection
    
    // DW: streamed file read and write
    // sender side stream
    NSInteger _streamBytesRead;
    NSInputStream *_streamFileReader;
    NSMutableData *_streamDataBufferReader;
    // receiver side stream
    NSInteger _streamBytesWrote;
    NSOutputStream *_streamFileWriter;
    NSMutableData *_streamDataBufferWriter;
}

@property (nonatomic, retain) NSNetService *service;
@property (nonatomic, retain) NSArray *servicesFound;
@property (nonatomic, retain) id<WDBubbleDelegate> delegate;

+ (NSString *)platformForNetService:(NSNetService *)netService;
+ (BOOL)isLockedNetService:(NSNetService *)netService;

- (void)publishServiceWithPassword:(NSString *)pwd;
- (void)browseServices;
- (void)stopService;

- (void)broadcastMessage:(WDMessage *)message;
- (void)sendMessage:(WDMessage *)message toServiceNamed:(NSString *)name;

// DW: transfer control
- (BOOL)isBusy;
- (float)percentTransfered;
- (NSUInteger)bytesTransfered;
- (void)terminateTransfer;

// DW: determines identical bubble
- (BOOL)isIdenticalService:(NSNetService *)netService;
- (BOOL)isDifferentService:(NSNetService *)netService;

@end
