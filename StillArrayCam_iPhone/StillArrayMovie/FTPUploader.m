//
//  FTPUploader.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "FTPUploader.h"

@interface FTPUploader()
@property (retain, nonatomic) NSOutputStream *networkStream;
@property (retain, nonatomic) NSInputStream *fileStream;
@end

@implementation FTPUploader
@synthesize networkStream = _networkStream;
@synthesize fileStream = _fileStream;
@synthesize delegate = _delegate;
@synthesize filePath = _filePath;
@synthesize userName = _userName;
@synthesize userPwd = _userPwd;
@synthesize urlString = _urlString;

- (id)initWithDelegate:(id<FTPUploaderDelegate>)dele url:(NSString*)urlString filePath:(NSString*)filePath
{
    return [self initWithDelegate:dele url:urlString username:nil password:nil filePath:filePath];
}

- (id)initWithDelegate:(id<FTPUploaderDelegate>)dele url:(NSString*)urlString username:(NSString*)username password:(NSString*)password filePath:(NSString*)filePath
{
    self = [super init];
    if( self )
    {
        self.filePath = filePath;
        self.userName = username;
        self.userPwd = password;
        self.urlString = urlString;
        self.delegate = dele;
    }
    
    return self;
}

- (void)dealloc
{
    self.filePath = nil;
    self.userName = nil;
    self.userPwd = nil;
    self.urlString = nil;
    self.delegate = nil;
    [self stopUploading];
    [super dealloc];
}

- (void)startUploading
{
    BOOL                    success;
    NSURL *                 url;
    CFWriteStreamRef        ftpStream;
    
    assert(self.filePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]);
    
    assert(self.networkStream == nil);      // don't tap send twice in a row!
    assert(self.fileStream == nil);         // ditto
    
    // First get and check the URL.
    
    url = [NSURL URLWithString:_urlString];
    success = (url != nil);
    
    if (success) {
        // Add the last part of the file name to the end of the URL to form the final 
        // URL that we're going to put to.
        
        url = [NSMakeCollectable(CFURLCreateCopyAppendingPathComponent(NULL, (CFURLRef) url, (CFStringRef) [self.filePath lastPathComponent], false)
                                 ) autorelease];
        success = (url != nil);
    }
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        NSLog(@"%s invalid url: %@",__FUNCTION__,[url absoluteString]);
    } else {
        
        // Open a stream for the file we're going to send.  We do not open this stream; 
        // NSURLConnection will do it for us.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:self.filePath];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a CFFTPStream for the URL.
        
        ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (CFURLRef) url);
        assert(ftpStream != NULL);
        
        self.networkStream = (NSOutputStream *) ftpStream;
        
        if ( [_userName length] > 0 ) {
#pragma unused (success) //Adding this to appease the static analyzer.
            success = [self.networkStream setProperty:_userName forKey:(id)kCFStreamPropertyFTPUserName];
            assert(success);
            success = [self.networkStream setProperty:_userPwd forKey:(id)kCFStreamPropertyFTPPassword];
            assert(success);
        }
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Have to release ftpStream to balance out the create.  self.networkStream 
        // has retained this for our persistent use.
        
        CFRelease(ftpStream);
    }
}

- (void)stopUploading
{
    if( self.delegate && [self.delegate respondsToSelector:@selector(ftpUploaderDidFinish:)] )
        [self.delegate ftpUploaderDidFinish:self];
    
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            if( self.delegate && [self.delegate respondsToSelector:@selector(ftpUploaderDidConnected:)] )
                [self.delegate ftpUploaderDidConnected:self];
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (bufferOffset == bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self stopUploading];
                } else if (bytesRead == 0) {
                    [self stopUploading];
                } else {
                    bufferOffset = 0;
                    bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (bufferOffset != bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&buffer[bufferOffset] maxLength:bufferLimit - bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self stopUploading];
                } else {
                    bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopUploading];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

@end
