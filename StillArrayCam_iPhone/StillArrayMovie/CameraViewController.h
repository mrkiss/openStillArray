//
//  CameraViewController.h
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 16..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraViewControllerDelegate;
@interface CameraViewController : UIViewController<AVCaptureFileOutputRecordingDelegate>{
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureSession *captureSession;
    
    BOOL isStart;
    BOOL isCancel;
    
    NSTimer *captureTimer;
}

@property (unsafe_unretained, nonatomic) IBOutlet UIView *cameraView;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *startButton;

@property (unsafe_unretained, nonatomic) id<CameraViewControllerDelegate> delegate;
@property (strong, nonatomic) NSURL *movieURL;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *stopDate;
@property (assign, nonatomic) BOOL enableAudio;

- (IBAction)closeAction:(id)sender;
- (IBAction)startAction:(id)sender;
- (void)startCaptureWithTime:(NSInteger)seconds;
- (void)stopCapture;
@end

@protocol CameraViewControllerDelegate <NSObject>
@optional
- (void)didFinishRecording:(CameraViewController*)cameraViewCtrl;
- (void)didStartRecording:(CameraViewController*)cameraViewCtrl;
- (void)readyForRecording:(CameraViewController*)cameraViewCtrl;
- (void)didCloseController:(CameraViewController*)cameraViewCtrl;
@end