//
//  MainViewController.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CameraViewController.h"
#import "FTPUploader.h"
#import "GCDAsyncSocket.h"
#import "Common.h"
#import "ATMHud.h"

enum DataTagEnum {
    DataTag_Read    = 1000,
    DataTag_Write,
};

@interface MainViewController : UIViewController<FTPUploaderDelegate,CameraViewControllerDelegate,GCDAsyncSocketDelegate>{
    FTPUploader *uploader;
    CameraViewController *captureViewCtrl;
    GCDAsyncSocket *asyncSocket;
    NSMutableData *recvData;
    
    NSInteger sequenceNumber;
    NSInteger captureSeconds;
    
    NSArray *typeArray;
    NSDictionary *typeDict;
    
    ATMHud *hudProgress;
    NSURL *uploadFileURL;
    
    BOOL isReadySended;
}

- (IBAction)setupSeatAction:(id)sender;
- (IBAction)prepareAction:(id)sender;
- (IBAction)setupFTPAction:(id)sender;
- (IBAction)setupControlServerAction:(id)sender;

- (void)startUploadFile:(NSURL*)url;
- (void)stopUploding;
- (void)sendMessage:(NSInteger)type params:(NSArray*)params;
- (void)messageProcess:(NSString*)msg;
- (void)connectToControlServer;
@end
