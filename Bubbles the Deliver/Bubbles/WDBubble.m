//
//  WDBubble.m
//  LearnBonjour
//
//  Created by 王 得希 on 12-1-5.
//  Copyright (c) 2012年 BMW Group ConnectedDrive Lab China. All rights reserved.
//

#import "WDBubble.h"
#include <ifaddrs.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation NSData (Bubbles)

- (int)port {
    int port;
    struct sockaddr *addr;
    
    addr = (struct sockaddr *)[self bytes];
    if (addr->sa_family == AF_INET)
        // IPv4 family
        port = ntohs(((struct sockaddr_in *)addr)->sin_port);
    else if (addr->sa_family == AF_INET6)
        // IPv6 family
        port = ntohs(((struct sockaddr_in6 *)addr)->sin6_port);
    else
        // The family is neither IPv4 nor IPv6. Can't handle.
        port = 0;
    
    return port;
}


- (NSString *)host {
    struct sockaddr *addr = (struct sockaddr *)[self bytes];
    if (addr->sa_family == AF_INET) {
        char *address = inet_ntoa(((struct sockaddr_in *)addr)->sin_addr);
        if (address)
            return [NSString stringWithCString:address encoding:NSUTF8StringEncoding];
    } else if (addr->sa_family == AF_INET6) {
        struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
        char straddr[INET6_ADDRSTRLEN];
        inet_ntop(AF_INET6, &(addr6->sin6_addr), straddr, sizeof(straddr));
        return [NSString stringWithCString:straddr encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end

// DW: when we do URL operations, we make sure that a folder's URL is always NOT ended with "/"
// of couse methods like NSURL::URLByDeletingLastPathComponent are exceptions, we treat them differently

@implementation NSURL (Bubbles)

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATO

+ (NSURL *)iOSDocumentsDirectoryURL {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)iOSDocumentsDirectoryPath {
    return [[NSURL iOSDocumentsDirectoryURL] path];
}

+ (NSURL *)iOSInboxDirectoryURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Inbox", [NSURL iOSDocumentsDirectoryURL].path]];
}

#elif TARGET_OS_MAC
#endif

+ (NSString *)formattedFileSize:(unsigned long long)size {
	NSString *formattedStr = nil;
    if (size == 0) 
		formattedStr = @"Empty";
	else 
		if (size > 0 && size < 1024) 
			formattedStr = [NSString stringWithFormat:@"%qu B", size];
        else 
            if (size >= 1024 && size < pow(1024, 2)) 
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            else 
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                else 
                    if (size >= pow(1024, 3)) 
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
	
	return formattedStr;
}

- (NSURL *)URLWithRemoteChangedToLocal {
    NSString *currentFileName = [[self URLByDeletingPathExtension].lastPathComponent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    NSURL *storeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.%@", 
                                            [[NSURL iOSDocumentsDirectoryURL] absoluteString], 
                                            currentFileName, 
                                            [[self pathExtension] lowercaseString]]];
#elif TARGET_OS_MAC
    NSURL *defaultURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultMacSavingPath]];
    
    // DW: Mac do not use ".xxx" files, remove the first "."
    if ([currentFileName hasPrefix:@"."]) {
        currentFileName = [currentFileName stringByReplacingCharactersInRange:NSRangeFromString(@"0 1") withString:@""];
    }
    
    NSURL *storeURL = [NSURL URLWithString:
                       [NSString stringWithFormat:@"%@/%@.%@", 
                        [defaultURL absoluteString], 
                        currentFileName, 
                        [[self pathExtension] lowercaseString]]];
    // DW: it is really overwhelming that the last "/" of a folder here exists in iOS, but not in Mac
#endif
    DLog(@"NSURL URLWithRemoteChangedToLocal %@", storeURL.path);
    return storeURL;
}

// DW: a good convert from remot URL to local one
// or good convert from local to new local
- (NSURL *)URLWithoutNameConflict {
    NSString *originalFileName = [[self URLByDeletingPathExtension].lastPathComponent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *currentFileName = originalFileName;
    NSInteger currentFileNamePostfix = 2;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    NSURL *storeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.%@", 
                                            [NSURL iOSDocumentsDirectoryURL].absoluteString, 
                                            currentFileName, 
                                            [self pathExtension]]];
    while ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        currentFileName = [NSString stringWithFormat:@"%@%%20%i", originalFileName, currentFileNamePostfix++];
        storeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", currentFileName, [self pathExtension]] 
                          relativeToURL:[self URLByDeletingLastPathComponent]];
    }
#elif TARGET_OS_MAC
    NSURL *defaultURL = [self URLByDeletingLastPathComponent]; // DW: this causes a URL ends with "/"Ω
    NSURL *storeURL = [NSURL URLWithString:
                       [NSString stringWithFormat:@"%@%@.%@", 
                        [defaultURL absoluteString], 
                        currentFileName, 
                        [[self pathExtension] lowercaseString]]];
    while ([[NSFileManager defaultManager] fileExistsAtPath:storeURL.path]) {
        currentFileName = [NSString stringWithFormat:@"%@%%20%li", originalFileName, currentFileNamePostfix++];
        storeURL = [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@%@.%@", 
                     [defaultURL absoluteString], 
                     currentFileName, 
                     [[self pathExtension] lowercaseString]]];
    }
#endif
    DLog(@"NSURL URLWithoutNameConflict %@", storeURL.path);
    return storeURL;
}

- (NSURL *)URLByMovingToParentFolder {
    NSURL *newURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", 
                                            [[self URLByDeletingLastPathComponent] URLByDeletingLastPathComponent].path, 
                                            self.lastPathComponent]];
    return newURL;
}

@end

@implementation WDBubble
@synthesize service = _service;
@synthesize servicesFound = _servicesFound;
@synthesize delegate;
//@synthesize percentageIndicator = _percentageIndicator;

#pragma mark - Private Methods

- (void)dealloc {
    [_supportedNetServiceTypes release];
    [_browsers release];
    [_socketListen release];
    [_socketsConnect release];
    
    [super dealloc];
}

- (void)updateSupportedNetServiceTypesForPassword:(NSString *)pwd {
    if (_supportedNetServiceTypes) {
        [_supportedNetServiceTypes release];
    }
    
    _supportedNetServiceTypes = [[NSArray arrayWithObjects:
                                  [NSString stringWithFormat:@"%@%@._tcp.", kWDBubbleWebServiceTypePhone, pwd], 
                                  [NSString stringWithFormat:@"%@%@._tcp.", kWDBubbleWebServiceTypePad, pwd], 
                                  [NSString stringWithFormat:@"%@%@._tcp.", kWDBubbleWebServiceTypeMac, pwd], 
                                  nil] retain];
}

- (void)resolveService:(NSNetService *)s {
    s.delegate = self;
    [s resolveWithTimeout:0];
}

- (void)connectAddress:(NSData *)address {
    // 20120115 DW: isConnected is always not reliable, do not use it
    AsyncSocket *sc = [[AsyncSocket alloc] init];
    sc.delegate = self;
    [sc connectToHost:[address host] onPort:[address port] error:nil];
    [_socketsConnect addObject:sc];
    [sc release];
}

- (void)connectService:(NSNetService *)s {
    // DW: update sender's state on every transfer, command and state are same now
    _isReceiver = NO;
    
    if (s.addresses.count <= 0)
        return;
    [self connectAddress:[s.addresses objectAtIndex:0]];
}

- (void)connectToServiceNamed:(NSString *)name {
    for (NSNetService *s in self.servicesFound) {
        if ([s.name isEqualToString:name]&&[self isDifferentService:s]) {
            if (s.addresses.count > 0) {
                [self connectService:s];
            } else {
                [self resolveService:s];
            }
            break;
        }
    }
}

- (void)readDataFromFile {
    if(!_streamDataBufferReader) {
        _streamDataBufferReader = [[NSMutableData data] retain];
    }
    uint8_t buf[1024];
    NSUInteger len = 0;
    len = [_streamFileReader read:buf maxLength:1024];
    if(len) {
        [_streamDataBufferReader appendBytes:(const void *)buf length:len];
        // _streamBytesRead is an instance variable of type NSNumber.
        //[_streamBytesRead setIntValue:[_streamBytesRead intValue]+len];
        _streamBytesRead = _streamBytesRead+len;
        
        // DW: now we send these read data
        for (AsyncSocket *sock in _socketsConnect) {
            [sock writeData:_streamDataBufferReader withTimeout:kWDBubbleTimeOut tag:0];
            //DLog(@"WDBubble NSStreamEventHasBytesAvailable wrote %@ to sock", [NSNumber numberWithInteger:len]);
        }
    } else {
        DLog(@"WDBubble readDataFromFile will end with %@ sent", [NSNumber numberWithInteger:_streamBytesRead]);
        // DW: now we send these read data
        for (AsyncSocket *sock in _socketsConnect) {
            [sock disconnectAfterWriting];
        }
    }
}

- (void)writeDataToFile {
    NSUInteger bytesWrote = 0;
    while (bytesWrote < [_streamDataBufferWriter length]) {
        // DW: we are faced with mutable array storing mutable data here
        // we will use unique way to write the array of data to file
        uint8_t *readBytes = (uint8_t *)[_streamDataBufferWriter mutableBytes];
        readBytes += bytesWrote; // instance variable to move pointer
        NSInteger data_len = [_streamDataBufferWriter length];
        NSUInteger len = ((data_len - bytesWrote >= 1024) ?
                          1024 : (data_len-bytesWrote));
        uint8_t buf[len];
        (void)memcpy(buf, readBytes, len);
        len = [_streamFileWriter write:(const uint8_t *)buf maxLength:len];
        bytesWrote += len;
    }
    
    [_streamDataBufferWriter release];
    _streamDataBufferWriter = nil;
    
    _streamBytesWrote += bytesWrote;
    if (_streamBytesWrote >= _currentMessage.fileSize) {
        // DW: file receiving is complete, we will disconnect
        DLog(@"WDBubble writeDataToFile will end with %@ received", [NSNumber numberWithInteger:_streamBytesWrote]);
        //[_socketReceive disconnectAfterReading];
        
        // DW: clean stream
        if (_streamFileWriter) {
            [_streamFileWriter close];
            [_streamFileWriter removeFromRunLoop:[NSRunLoop currentRunLoop]
                                         forMode:NSDefaultRunLoopMode];
            [_streamFileWriter release];
            _streamFileWriter = nil; // oStream is instance variable
            
            // DW: receiver is complete
            DLog(@"WDBubble writeDataToFile _streamFileWriter released");
        }
    }
}

- (void)closeStream:(NSStream *)stream {
    if (!stream) {
        return;
    }
    
    [stream close];
    [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    [stream release];
    stream = nil;
}

#pragma mark - Publice Methods

+ (NSString *)platformForNetService:(NSNetService *)netService {
    NSString *netServiceType = netService.type;
    if ([netServiceType rangeOfString:kWDBubbleWebServiceTypeMac].location != NSNotFound) {
        return kWDBubbleWebServiceTypeMac;
    } else if ([netServiceType rangeOfString:kWDBubbleWebServiceTypePad].location != NSNotFound) {
        return kWDBubbleWebServiceTypePad;
    } else if ([netServiceType rangeOfString:kWDBubbleWebServiceTypePhone].location != NSNotFound) {
        return kWDBubbleWebServiceTypePhone;
    } else {
        return @"";
    }
}

+ (BOOL)isLockedNetService:(NSNetService *)netService {
    NSString *netServiceType = netService.type;
    NSArray *normalArray = [[NSString stringWithFormat:@"%@._tcp.", kWDBubbleWebServiceTypeMac] componentsSeparatedByString:@"_"];
    NSArray *currentArray = [netServiceType componentsSeparatedByString:@"_"];
    // DW: a normal _mac_bubbles_._tcp. is different to _mac_bubbles_XXX._tcp., has shorter components such as "." compared to "XXX."
    if ([[currentArray objectAtIndex:2] length] > [[normalArray objectAtIndex:2] length]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)init {
    if (self = [super init]) {
        DLog(@"WDBubble initSocket");
        
        _currentMessage = nil;
        _dataBuffer = nil;
        
        // DW: accepts connections, creates new sockets to connect incoming sockets.
        _socketListen = [[AsyncSocket alloc] init];
        _socketListen.delegate = self;
        [_socketListen acceptOnPort:0 error:nil];
        
        // DW: connect to remote sockets (which are created by remote's "socketListen") and send them data.
        // Following sockets like it will become temp vars
        //self.socketConnect = [[AsyncSocket alloc] init];
        //self.socketConnect.delegate = self;
        _socketsConnect = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)publishServiceWithPassword:(NSString *)pwd {
    DLog(@"WDBubble publishService <%@>%@ port %i", _service.name, _socketListen, _socketListen.localPort);
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _netServiceType = [NSString stringWithFormat:@"%@%@._tcp.", kWDBubbleWebServiceTypePhone, pwd];
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _netServiceType = [NSString stringWithFormat:@"%@%@._tcp.", kWDBubbleWebServiceTypePad, pwd];
    }
    
    _service = [[NSNetService alloc] initWithDomain:@""
                                               type:_netServiceType
                                               name:[[UIDevice currentDevice] name]
                                               port:_socketListen.localPort];
#elif TARGET_OS_MAC
    _netServiceType = [NSString stringWithFormat:@"%@%@._tcp.", kWDBubbleWebServiceTypeMac, pwd];
    _service = [[NSNetService alloc] initWithDomain:@""
                                               type:_netServiceType
                                               name:[[NSHost currentHost] localizedName]
                                               port:_socketListen.localPort];
#endif
    [self updateSupportedNetServiceTypesForPassword:pwd];
    
    _service.delegate = self;
    [_service publish];
}

- (void)browseServices {
    _servicesFound = [[NSMutableArray alloc] init];
    DLog(@"WDBubble browseServices");
    //_browser = [[NSNetServiceBrowser alloc] init];
    //_browser.delegate = self;
    
    // DW: we browse all supported services now
    //[_browser searchForServicesOfType:_netServiceType inDomain:kWDBubbleInitialDomain];
    
    // DW: set up browsers
    _browsers = [[NSMutableArray arrayWithCapacity:kWDBubbleWebServiceTypeCount] retain];
    for (int i = 0; i < kWDBubbleWebServiceTypeCount; i++) {
        NSNetServiceBrowser *browser = [[[NSNetServiceBrowser alloc] init] autorelease];
        browser.delegate = self;
        [_browsers addObject:browser];
    }
    
    for (int i = 0; i < _supportedNetServiceTypes.count; i++) {
        [[_browsers objectAtIndex:i] searchForServicesOfType:[_supportedNetServiceTypes objectAtIndex:i] 
                                                    inDomain:kWDBubbleInitialDomain];
    }
    
    // 20120116 DW: it's not possible to find extra domains, give up
    //[_browser searchForBrowsableDomains];
}

- (void)broadcastMessage:(WDMessage *)message {
    _currentMessage = [message retain];
    
    for (NSNetService *s in self.servicesFound) {
        if ([s.name isEqualToString:_service.name]) {
            continue;
        }
        
        if (s.addresses.count > 0) {
            [self connectService:s];
        } else {
            [self resolveService:s];
        }
    }
}

- (void)sendMessage:(WDMessage *)message toServiceNamed:(NSString *)name {
    _currentMessage = [message retain];
    [self connectToServiceNamed:name];
}

- (void)stopService {
    if (_browsers) {
        [_browsers release];
        _browsers = nil;
    }
    
    
    [_servicesFound release];
    
    [_service stop];
    [_service release];
    _service = nil;
    
    _netServiceType = nil;
}

- (BOOL)isBusy {
    // DW: is busy sending and receiving
    return ([_currentMessage.state isEqualToString:kWDMessageStateSending]
            ||[_currentMessage.state isEqualToString:kWDMessageStateReceiving]);
}

- (float)percentTransfered {
    float total = _currentMessage.fileSize;
    if (_isReceiver) {
        return _streamBytesWrote/total;
    } else {
        return _streamBytesRead/total;
    }
}

- (NSUInteger)bytesTransfered {
    if (_isReceiver) {
        return _streamBytesWrote;
    } else {
        return _streamBytesRead;
    }
}

- (void)terminateTransfer {
    DLog(@"WDBubble terminateTransfer");
    if (_isReceiver) {
        //[self closeStream:_streamFileWriter];
        [_socketReceive disconnect];
    } else {
        //[self closeStream:_streamFileReader];
        for (AsyncSocket *sock in _socketsConnect) {
            [sock disconnect];
        }
    }
}

- (BOOL)isIdenticalService:(NSNetService *)netService {
    return [self.service.name isEqualToString:netService.name]&&[[WDBubble platformForNetService:self.service] isEqualToString:[WDBubble platformForNetService:netService]];
}

- (BOOL)isDifferentService:(NSNetService *)netService {
    return ![self isIdenticalService:netService];
}

#pragma mark - NSNetServiceDelegate

// Publish

- (void)netServiceWillPublish:(NSNetService *)sender {
    //DLog(@"NSNetServiceDelegate netServiceWillPublish");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    DLog(@"NSNetServiceDelegate netServiceDidPublish %@", sender);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    DLog(@"NSNetServiceDelegate netService didNotPublish code: %@, domain: %@.", 
         [errorDict objectForKey:NSNetServicesErrorCode], 
         [errorDict objectForKey:NSNetServicesErrorDomain]);
}

// Resolve

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    //[self connectService:sender];
    [self connectService:sender];
}

#pragma mark - AsyncSocketDelegate

// DW: it's always a receiver
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    //DLog(@"AsyncSocketDelegate didAcceptNewSocket %@: %@", sock, newSocket);
    
    // DW: we filter some unwanted sockets here, such as sockets that try to connect when current sender is sending
    // or current receiver is receiving
    
    if (_currentMessage) {
        // DW: of course at least current message is not nil for filtering
        // we only want to filter kWDMessageStateSending and 
        
        if ([_currentMessage.state isEqualToString:kWDMessageStateSending]) {
            return;
        } else if ([_currentMessage.state isEqualToString:kWDMessageStateReceiving]) {
            return;
        }
    }
    
    // DW: this "newSocket" is connected to remote's "socketSender", use it to read data then.
    // It is the very first place to read data.
    _isReceiver = YES;
    _socketReceive = [newSocket retain];
    [_socketReceive readDataWithTimeout:kWDBubbleTimeOut tag:0];
    
#ifdef TEMP_USE_OLD_WDBUBBLE
#else
    // DW: _currentMessage.state is always updated if it's transfering file
    if ([_currentMessage.state isEqualToString:kWDMessageStateReadyToReceive]) {
        _currentMessage.state = kWDMessageStateReceiving;
        
        _currentMessage.fileURL = [[_currentMessage.fileURL URLWithRemoteChangedToLocal] URLWithoutNameConflict];
        DLog(@"WDBubble _streamFileWriter will be assigned path %@", _currentMessage.fileURL.path);
        // 20120507 DW: to make Deliver ready for the Mac App Store, we should use SavePanel to let the user specify
        // the location he wants, not a URL by default
        //_streamFileWriter = [[NSOutputStream alloc] initToFileAtPath:_currentMessage.fileURL.path  append:YES];
        NSURL *saveURL = _currentMessage.fileURL;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_MAC
        [saveURL startAccessingSecurityScopedResource];
#endif
        if(saveURL != NULL)
        {
            _streamFileWriter = [[NSOutputStream alloc] initToFileAtPath:saveURL.path  append:YES];
            [_streamFileWriter setDelegate:self];
            [_streamFileWriter scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                         forMode:NSDefaultRunLoopMode];
            [_streamFileWriter open];
            
            _streamBytesWrote = 0;
        }
    } else {
        _dataBuffer = [[NSMutableData alloc] init];
    }
#endif
    //_timer = [[NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(timerCheckProgress:) userInfo:nil repeats:YES] retain];
    // [_timer fire];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //DLog(@"AsyncSocketDelegate didReadData %@: %@", sock, data);
    
#ifdef TEMP_USE_OLD_WDBUBBLE
    // DW: we append and write data to file
    [_dataBuffer appendData:data];
#else
    if ([_currentMessage.state isEqualToString:kWDMessageStateReceiving]) {
        [self.delegate percentUpdated];
        //_currentMessage.state = kWDMessageStateSending;
        // DW: we are receiving file now
        if (!_streamDataBufferWriter) {
            _streamDataBufferWriter = [[NSMutableData data] retain];
        }
        [_streamDataBufferWriter appendData:data];
        
        // DW: no error in stream writer, write data to file
        if (_streamDataBufferWriter) {
            [self writeDataToFile];
        } else {
            [self terminateTransfer];
        }
    } else {
        [_dataBuffer appendData:data];
    }
#endif
    
    // DW: this line of code commented below can be seen as the chief reason that causes sending file with loss of data!
    // Holy damn lord!
    //[sock readDataToLength:[data length] withTimeout:-1 buffer:nil bufferOffset:0 tag:20];
    
    [sock readDataWithTimeout:kWDBubbleTimeOut tag:0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    if (err) {
        DLog(@"AsyncSocketDelegate willDisconnectWithError %@: %@", _currentMessage.state, err);
        [self.delegate errorOccured:err];
    }
    [sock readDataWithTimeout:kWDBubbleTimeOut tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    // DW: after connected, "socketSender" will send data.
    
    if (_isReceiver) {
        // DW: a receiver
    } else {
        // DW: a sender
        
#ifdef TEMP_USE_OLD_WDBUBBLE
        NSData *t = [NSKeyedArchiver archivedDataWithRootObject:_currentMessage];
        [sock writeData:t withTimeout:kWDBubbleTimeOut tag:0];
        //DLog(@"AsyncSocketDelegate didConnectToHost writing %@", t);
#else   
        if ([_currentMessage.state isEqualToString:kWDMessageStateSending]) {
            _streamFileReader = [[NSInputStream alloc] initWithFileAtPath:_currentMessage.fileURL.path];
            [_streamFileReader setDelegate:self];
            [_streamFileReader scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                         forMode:NSDefaultRunLoopMode];
            [_streamFileReader open];
            
            // DW: we reade and send instantly
            [self readDataFromFile];
        } else {
            // DW: kWDMessageStateReadyToSend, kWDMessageStateReadyToReceive, kWDMessageStateText
            NSData *t = [NSKeyedArchiver archivedDataWithRootObject:_currentMessage];
            [sock writeData:t withTimeout:kWDBubbleTimeOut tag:0];
        }
#endif
    }
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //DLog(@"AsyncSocketDelegate didWriteDataWithTag %@", sock);
    
    // DW: anyone of the two connected sockets call "disconnect" will disconnect the connection. XD
    if ([_currentMessage.state isEqualToString:kWDMessageStateSending]) {
        [self.delegate percentUpdated];
        
        // DW: when wrote, release buffer and read data from file again
        [_streamDataBufferReader release];
        _streamDataBufferReader = nil;
        [self readDataFromFile];
    } else {
        [sock disconnectAfterWriting];
    }
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    //DLog(@"AsyncSocketDelegate onSocketDidDisconnect %@", sock);
    if (_isReceiver) {
        // DW: a receive socket
        
        // DW: file receiving end
        if ([_currentMessage.state isEqualToString:kWDMessageStateReceiving]) {
            
            // DW: check if it's the user terminates the transfering
            if (_streamBytesWrote < _currentMessage.fileSize) {
                DLog(@"WDBubble terminated receiver %@ received", [NSNumber numberWithInteger:_streamBytesWrote]);
                _streamBytesWrote = 0;
                [self closeStream:_streamFileWriter];
                [self.delegate didTerminateReceiveMessage:_currentMessage];
                
                [_currentMessage release];
                _currentMessage = nil;
                return;
            }
            
            // DW: clean socket, "onDisconnect" is not reliable on file transfer
            [self.delegate didReceiveMessage:[WDMessage messageWithFile:_currentMessage.fileURL andState:kWDMessageStateFile]];
            
            [_currentMessage release];
            _currentMessage = nil;
            return;
        } else {
            WDMessage *t = [NSKeyedUnarchiver unarchiveObjectWithData:_dataBuffer];
            if ([t.state isEqualToString: kWDMessageStateText]) {
                [self.delegate didReceiveMessage:t];
            } else if ([t.state isEqualToString:kWDMessageStateReadyToSend]) {
                DLog(@"WDBubble onSocketDidDisconnect %@ received kWDMessageStateReadyToSend", _currentMessage.state);
                // DW: begin of a file transfer
                _streamBytesWrote = 0;
                _currentMessage = [[WDMessage messageWithFile:t.fileURL andState:kWDMessageStateReadyToReceive] retain];
                _currentMessage.fileSize = t.fileSize;
                [self connectToServiceNamed:t.sender];
                
                // DW; notify VC
                [self.delegate willReceiveMessage:_currentMessage];
            } else if ([t.state isEqualToString:kWDMessageStateReadyToReceive]) {
                DLog(@"WDBubble onSocketDidDisconnect %@ received kWDMessageStateReadyToReceive", _currentMessage.state);
                // DW: receiver is readly for the file, send it then
                _streamBytesRead = 0;
                _currentMessage.state = kWDMessageStateSending;
                [self connectToServiceNamed:t.sender];
            }
            
            // DW: clean up
            //[t release];
            [_dataBuffer release];
            _dataBuffer = nil;
        }
    } else {
        [_socketsConnect removeObject:sock];
        
        // DW: a sending socket
        if ([_currentMessage.state isEqualToString:kWDMessageStateSending]) {
            // DW: check if it's the user terminates the transfering
            if (_streamBytesRead >= _currentMessage.fileSize) {
                [self.delegate didSendMessage:_currentMessage];
            } else {
                DLog(@"WDBubble terminated sender %@ sent", [NSNumber numberWithInteger:_streamBytesRead]);
                _streamBytesRead = 0;
                [self closeStream:_streamFileReader];
                [self.delegate didTerminateSendMessage:_currentMessage];
            }
            
            [_currentMessage release];
            _currentMessage = nil;
        } else if ([_currentMessage.state isEqualToString:kWDMessageStateText]) {
            
            // DW: releases _currentMessage
            [_currentMessage release];
            _currentMessage = nil;
        }
    }
    
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    if (![netService.domain isEqualToString:@"local."]) {
        return;
    }
    
    if ([_servicesFound indexOfObject:netService] != NSNotFound) {
        return;
    }
    
    // DW: "_servicesFound" always contains "self"'s service, this helps to show a list of all peers.
    [_servicesFound addObject:netService];
    DLog(@"NSNetServiceBrowserDelegate didFindService %@", self.servicesFound);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWDBubbleNotificationServiceUpdated object:nil];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)netService moreComing:(BOOL)moreComing {
	[_servicesFound removeObject:netService];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWDBubbleNotificationServiceUpdated object:nil];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
    DLog(@"NSNetServiceBrowserDelegate didFindDomain %@", domainName);
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    // DW: we do not include cases like NSStreamEventHasBytesAvailable or NSStreamEventHasSpaceAvailable here since we do not need them
    switch(streamEvent) {
        case NSStreamEventEndEncountered: {
            if (_streamFileReader) {
                // DW: sender is complete
                [self closeStream:_streamFileReader];
                DLog(@"WDBubble NSStreamEventEndEncountered _streamFileReader");
            }
            
            if (_streamFileWriter) {
                // DW: receiver is complete
                [self closeStream:_streamFileWriter];
                DLog(@"WDBubble NSStreamEventEndEncountered _streamFileWriter %@", theStream);
            }
            break;
        } case NSStreamEventErrorOccurred: {
            DLog(@"WDBubble steam %@ NSStreamEventErrorOccurred %@", theStream, [theStream streamError]);
            [self closeStream:theStream];
            [self.delegate errorOccured:[theStream streamError]];
            break;
        } default: {
            
            break;
        }
    }
}

@end
