//
//  FTPUploader.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>

enum {
    kSendBufferSize = 32768
};

@protocol FTPUploaderDelegate;
@interface FTPUploader : NSObject<NSStreamDelegate>{
    NSOutputStream *_networkStream;
    NSInputStream *_fileStream;
    
    uint8_t                     buffer[kSendBufferSize];
    size_t                      bufferOffset;
    size_t                      bufferLimit;
    
    NSString *_filePath;
    NSString *_userName;
    NSString *_userPwd;
    NSString *_urlString;
}

@property (assign, nonatomic) id<FTPUploaderDelegate> delegate;
@property (retain, nonatomic) NSString *filePath;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *userPwd;
@property (retain, nonatomic) NSString *urlString;

- (id)initWithDelegate:(id<FTPUploaderDelegate>)dele url:(NSString*)urlString filePath:(NSString*)filePath;
- (id)initWithDelegate:(id<FTPUploaderDelegate>)dele url:(NSString*)urlString username:(NSString*)username password:(NSString*)password filePath:(NSString*)filePath;
- (void)startUploading;
- (void)stopUploading;

@end

@protocol FTPUploaderDelegate <NSObject>
@optional
- (void)ftpUploaderDidConnected:(FTPUploader*)ftpUploader;
- (void)ftpUploaderDidFinish:(FTPUploader*)ftpUploader;
- (void)ftpUploaderSending:(FTPUploader*)ftpUploader;
@end