//
//  WDMessage.m
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-6.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "WDMessage.h"

#define kWDMessageSender    @"kWDMessageSender"
#define kWDMessageTime      @"kWDMessageTime"
#define kWDMessageState     @"kWDMessageState"
#define kWDMessageFileURL   @"kWDMessageFileURL"
#define kWDMessageContent   @"kWDMessageContent"
#define kWDMessageType      @"kWDMessageType"

@implementation WDMessage
@synthesize sender = _sender, time = _time, state = _state, fileURL = _fileURL, content = _content;

+ (BOOL)isImageURL:(NSURL *)url {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    return [[[UIImage alloc] initWithContentsOfFile:url.path] autorelease] != nil;
#elif TARGET_OS_MAC
    return [[[NSImage alloc] initWithContentsOfURL:url] autorelease] != nil;
#endif
}

+ (id)messageWithText:(NSString *)text {
    WDMessage *m = [[[WDMessage alloc] init] autorelease];
    m.state = kWDMessageStateText;
    m.content = [text dataUsingEncoding:NSUTF8StringEncoding];
    return m;
}

+ (id)messageWithFile:(NSURL *)url andState:(NSString *)state {
    WDMessage *m = [[[WDMessage alloc] init] autorelease];
    m.fileURL = url;
    m.state = state;
    // DW: content will be file size
    NSUInteger fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:m.fileURL.path error:nil] fileSize]; 
    m.content = [NSData dataWithBytes:&fileSize length:sizeof(fileSize)];
    return m;
}

+ (id)messageInfoFromMessage:(WDMessage *)message {
    WDMessage *m = [[[WDMessage alloc] init] autorelease];
    m.sender = message.sender;
    m.time = message.time;
    m.fileURL = message.fileURL;
    return m;
}

#pragma mark - Private Methods

- (NSUInteger)fileSize {
    NSUInteger fileSize = 0;
    if ([self.state isEqualToString:kWDMessageStateText]) {
        fileSize = [self.content length];
    } else {
        [self.content getBytes:&fileSize length:sizeof(fileSize)];
    }
    return fileSize;
}

- (void)setFileSize:(NSUInteger)fileSize {
    self.content = [NSData dataWithBytes:&fileSize length:sizeof(fileSize)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"WDMessage %p, %@, %@, %@, %@, %@", 
            self, 
            self.sender, 
            self.time, 
            self.state, 
            self.fileURL, 
            self.content];
}

- (id)init {
    if (self = [super init]) {
        _time = [[NSDate date] retain];
        _state = kWDMessageStateText;
        
        // DW: in WDBubble we publish services with this name
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        _sender = [[[UIDevice currentDevice] name] retain];
#elif TARGET_OS_MAC
        _sender = [[[NSHost currentHost] localizedName] retain];
#endif
    }
    return self;
}

- (void)dealloc {
    [_sender release];
    [_time release];
    [_state release];
    if (_fileURL) {
        [_fileURL release];
    }
    if (_content) {
        [_content release];
    }
    
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_sender forKey:kWDMessageSender];
    [encoder encodeObject:_time forKey:kWDMessageTime];
    [encoder encodeObject:_state forKey:kWDMessageState];
    [encoder encodeObject:_fileURL forKey:kWDMessageFileURL];
    [encoder encodeObject:_content forKey:kWDMessageContent];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _sender = [[decoder decodeObjectForKey:kWDMessageSender] retain];
    _time = [[decoder decodeObjectForKey:kWDMessageTime] retain];
    _state = [[decoder decodeObjectForKey:kWDMessageState] retain];
    _fileURL = [[decoder decodeObjectForKey:kWDMessageFileURL] retain];
    _content = [[decoder decodeObjectForKey:kWDMessageContent] retain];
    return self;
}

#pragma mark - NSCopy

- (id)initWithCopyMessage:(NSString *)aSender 
                 withTime:(NSDate *)aTime 
                withState:(NSString *)aState 
                  withUrl:(NSURL *)aURL 
              withContent:(NSData *)aContent {
    if (self = [super init]) {
        _sender = [aSender retain];
        _time = [aTime retain];
        _state = [aState retain];
        _fileURL = [aURL retain];
        _content = [aContent retain];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    WDMessage *copy = [[[self class] allocWithZone: zone] initWithCopyMessage:_sender 
                                                                     withTime:_time
                                                                    withState:_state
                                                                      withUrl:_fileURL 
                                                                  withContent:_content];
    return copy;
}

@end
