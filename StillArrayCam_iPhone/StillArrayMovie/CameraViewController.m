//
//  CameraViewController.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 16..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "CameraViewController.h"
#import "Utility.h"
#import "Common.h"

@interface CameraViewController ()

@end

@implementation CameraViewController
@synthesize cameraView;
@synthesize startButton;
@synthesize movieURL;
@synthesize startDate;
@synthesize stopDate;
@synthesize delegate;
@synthesize enableAudio;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:nil];
    
    if( [captureSession canAddInput:videoInput] )
        [captureSession addInput:videoInput];
    
    if( enableAudio ){
        AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:nil];
        if( [captureSession canAddInput:audioInput] )
            [captureSession addInput:audioInput];
    }
    
    movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [captureSession addOutput:movieFileOutput];
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:cameraView.bounds];
    [cameraView.layer addSublayer:previewLayer];
    [captureSession startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if( self.delegate && [self.delegate respondsToSelector:@selector(readyForRecording:)] )
        [self.delegate readyForRecording:self];
}

- (void)viewDidUnload
{
    [self setCameraView:nil];
    [self setStartButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - action method
- (void)captureStart
{
    NSDate *date = [NSDate date];
    NSString *savePath = [[Utility cacheFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d_%f.mov",[[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_SEATNUMBER],[date timeIntervalSince1970]]];
    self.movieURL = [NSURL fileURLWithPath:savePath];
    [movieFileOutput startRecordingToOutputFileURL:movieURL recordingDelegate:self];
    [startButton setTitle:@"Stop"];
    isCancel = NO;
    isStart = YES;
}

- (void)captureStop
{
    isCancel = NO;
    [movieFileOutput stopRecording];
    [startButton setTitle:@"Start"];
    isStart = NO;
}

- (IBAction)closeAction:(id)sender {
    if( isStart ){
        isCancel = YES;
        [movieFileOutput stopRecording];
    }
    if( self.delegate && [self.delegate respondsToSelector:@selector(didCloseController:)] )
        [self.delegate didCloseController:self];
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)startAction:(id)sender {
    if( isStart ){
        [self captureStop];
    }
    else{
        [self captureStart];
    }
}

- (void)captureTimerAction:(NSTimer*)theTimer
{
    [self stopCapture];
}

- (void)startCaptureWithTime:(NSInteger)seconds
{
    captureTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)seconds target:self selector:@selector(captureTimerAction:) userInfo:nil repeats:NO];
    [self captureStart];
}

- (void)stopCapture
{
    if( captureTimer )
    {
        [captureTimer invalidate];
        captureTimer = nil;
    }
    [self captureStop];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    self.startDate = [NSDate date];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    self.stopDate = [NSDate date];
    if( !isCancel ){
        if( self.delegate && [self.delegate respondsToSelector:@selector(didFinishRecording:)] )
            [self.delegate didFinishRecording:self];
    }
    
    isCancel = NO;
}

@end
