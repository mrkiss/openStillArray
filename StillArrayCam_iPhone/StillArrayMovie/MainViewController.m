//
//  MainViewController.m
//  StillArrayMovie
//
//  Created by YoungTaeck Oh on 12. 5. 12..
//  Copyright (c) 2012년 Joy2x. All rights reserved.
//

#import "MainViewController.h"
#import "SelectViewController.h"
#import "FTPSetupViewController.h"
#import "ServerViewController.h"
#import "Utility.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    self.navigationItem.title = @"Still Array";
    
    typeArray = [NSArray arrayWithObjects:MSGTYPE_READY,MSGTYPE_END,MSGTYPE_UPLOAD,MSGTYPE_START, nil];
    typeDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:Msg_Ready],MSGTYPE_READY,[NSNumber numberWithInt:Msg_EndCapture],MSGTYPE_END,[NSNumber numberWithInt:Msg_UploadDone],MSGTYPE_UPLOAD,[NSNumber numberWithInt:Msg_StartCapture],MSGTYPE_START, nil];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    recvData = [NSMutableData data];
    
    hudProgress = [[ATMHud alloc] initWithDelegate:self];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - action method
- (IBAction)setupSeatAction:(id)sender {
    SelectViewController *viewCtrl = [[SelectViewController alloc] initWithNibName:@"SelectViewController" bundle:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)prepareAction:(id)sender {
    if( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
        [Utility alertMessage:@"카메라가 지원되지 않는 기기입니다.\n촬영이 불가능합니다."];
        return;
    }
    
    [self connectToControlServer];
    
    captureViewCtrl = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    captureViewCtrl.delegate = self;
    captureViewCtrl.enableAudio = NO;
    [self presentModalViewController:captureViewCtrl animated:YES];
}

- (IBAction)setupFTPAction:(id)sender {
    FTPSetupViewController *viewCtrl = [[FTPSetupViewController alloc] initWithNibName:@"FTPSetupViewController" bundle:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (IBAction)setupControlServerAction:(id)sender {
    ServerViewController *viewCtrl = [[ServerViewController alloc] initWithNibName:@"ServerViewController" bundle:nil];
    [self.navigationController pushViewController:viewCtrl animated:YES];

}

#pragma mark - CameraViewControllerDelegate
- (void)didStartRecording:(CameraViewController *)cameraViewCtrl
{
    NSLog(@"%s",__FUNCTION__);
}

// 동영상 캡춰 완료 처리
- (void)didFinishRecording:(CameraViewController *)cameraViewCtrl
{
    NSURL *fileURL = [NSURL fileURLWithPath:[cameraViewCtrl.movieURL path]];
//    [cameraViewCtrl dismissModalViewControllerAnimated:YES];
    // 촬영완료 메세지 전송
    NSInteger cameraNumber = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_SEATNUMBER];
    [self sendMessage:Msg_EndCapture params:[NSArray arrayWithObject:[NSString stringWithFormat:@"%07d",cameraNumber]]];
    
    // 파일이름을 만든다.
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:cameraViewCtrl.startDate];

    NSTimeInterval time = [cameraViewCtrl.startDate timeIntervalSince1970];
    NSInteger milisecond = (NSInteger)fmod(floor( (time-floor(time)) * 100.0  ),100.0);
    NSString *timeStr = [NSString stringWithFormat:@"%02d%02d%02d%02d",[comp hour],[comp minute],[comp second],milisecond];
    NSString *newPath = [NSString stringWithFormat:@"S%06d_%@_C%06d.mov",sequenceNumber,timeStr,cameraNumber];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]] ){
        uploadFileURL = [NSURL fileURLWithPath:[[Utility cacheFolder] stringByAppendingPathComponent:newPath]];
        [[NSFileManager defaultManager] moveItemAtPath:[fileURL path] toPath:[uploadFileURL path] error:nil];
        [self startUploadFile:uploadFileURL];
    }
    
    
}

- (void)readyForRecording:(CameraViewController *)cameraViewCtrl
{
}

- (void)didCloseController:(CameraViewController *)cameraViewCtrl
{
    [cameraViewCtrl dismissModalViewControllerAnimated:YES];
    cameraViewCtrl = nil;
}

#pragma mark - ftp
- (void)startUploadFile:(NSURL*)url
{
    NSString *ftpAddress = [@"ftp://" stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_FTPADDRESS]];
    uploader = [[FTPUploader alloc] initWithDelegate:self url:ftpAddress username:[[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_FTPUSER] password:[[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_FTPPASSWORD] filePath:[url path]];

    //  송준근 수정하다 jun@ delay for avoiding collision
    [NSThread sleepForTimeInterval: [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_SEATNUMBER]];
    //--- 송준근 수정하다 끝  2012.6.4.
    [uploader startUploading];
}

- (void)stopUploding
{
    [uploader stopUploading];
}

#pragma mark - FTPUploaderDelegate
- (void)ftpUploaderDidConnected:(FTPUploader *)ftpUploader
{
    NSLog(@"%s",__FUNCTION__);
    if( captureViewCtrl )
        [captureViewCtrl.view addSubview:hudProgress.view];
    [hudProgress setActivity:YES];
    [hudProgress setCaption:@"Uploading..."];
    [hudProgress show];
}

- (void)ftpUploaderDidFinish:(FTPUploader *)ftpUploader
{
    NSLog(@"%s",__FUNCTION__);
    [hudProgress hide];
    [hudProgress.view removeFromSuperview];
    
    // ftp 업로드 완료 메세지 전송
    [self sendMessage:Msg_UploadDone params:[NSArray arrayWithObject:[NSString stringWithFormat:@"%07d",[[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_SEATNUMBER]]]];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[uploadFileURL path]] )
        [[NSFileManager defaultManager] removeItemAtPath:[uploadFileURL path] error:nil];
}

- (void)ftpUploaderSending:(FTPUploader *)ftpUploader
{
    
}

#pragma mark - GCDAsyncSocketDelegate
// 소켓을 이용하여 메세지를 전송하는 메소드
- (void)sendMessage:(NSInteger)type params:(NSArray*)params
{
    NSString *msgStr = [NSString stringWithFormat:@"%@",[typeArray objectAtIndex:type]];
    for(NSString *str in params)
    {
        msgStr = [msgStr stringByAppendingString:str];
        if( str != [params lastObject] )
            msgStr = [msgStr stringByAppendingString:@"_"];
    }
    
    if( [msgStr length] < MESSAGE_LENGTH )
    {
        NSInteger total = MESSAGE_LENGTH - [msgStr length];
        for(int i=0; i < total; i++)
            [msgStr stringByAppendingString:@" "];
    }
    
    [asyncSocket writeData:[msgStr dataUsingEncoding:NSASCIIStringEncoding] withTimeout:WRITETIMEOUT tag:DataTag_Write];
//    NSLog(@"%s %d",__FUNCTION__,sizeof(time_t));
}

- (void)messageProcess:(NSString*)msg
{
    NSNumber *typeItem = [typeDict objectForKey:[msg substringToIndex:1]];
    if( typeItem == nil )
        return;
    NSLog(@"%s %@",__FUNCTION__,msg);
    NSInteger type = [typeItem integerValue];
    NSArray *params = [[msg substringFromIndex:1] componentsSeparatedByString:@"_"];
    switch (type) {
        case Msg_StartCapture:
            // 캡춰 시작 메세지 처리
            sequenceNumber = [[params objectAtIndex:0] integerValue];
            captureSeconds = [[params objectAtIndex:1] integerValue];
            [captureViewCtrl startCaptureWithTime:captureSeconds];
            break;
            
        default:
            NSLog(@"%s msg %@ not allowed",__FUNCTION__,msg);
            break;
    }
}

- (void)connectToControlServer
{
    if( ![asyncSocket isConnected] ){
        [asyncSocket connectToHost:[[NSUserDefaults standardUserDefaults] stringForKey:USERDEFKEY_CONTROLADDRESS] onPort:[[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_CONTROLPORT] error:nil];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"%s %@:%d",__FUNCTION__,host,port);
    if( !isReadySended ){
        [self sendMessage:Msg_Ready params:[NSArray arrayWithObject:[NSString stringWithFormat:@"%07d",[[NSUserDefaults standardUserDefaults] integerForKey:USERDEFKEY_SEATNUMBER]]]];
        isReadySended = YES;
    }
    else {
        [sock readDataWithTimeout:READTIMEOUT tag:DataTag_Read];
    }
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"%s %@",__FUNCTION__,[err localizedDescription]);
    isReadySended = NO;
//    [self performSelector:@selector(connectToControlServer) withObject:nil afterDelay:1.0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData :(NSData *)data withTag:(long)tag
{
    // 데이터 수신 부분
    NSLog(@"%s %d",__FUNCTION__,[data length]);
    [recvData appendData:data];
    if( [recvData length] >= MESSAGE_LENGTH )
    {
        // 수신된 데이터를 처리하고 버퍼를 재정리
        NSString *msg = [[[NSString alloc] initWithData:[recvData subdataWithRange:NSMakeRange(0, MESSAGE_LENGTH)] encoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        recvData = [NSMutableData dataWithData:[recvData subdataWithRange:NSMakeRange(MESSAGE_LENGTH, [recvData length]-MESSAGE_LENGTH)]];
        NSLog(@"msg: %@",msg);
        [self messageProcess:msg];
    }
    // 수신 대기
    [sock readDataWithTimeout:READTIMEOUT tag:DataTag_Read];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%s %ld",__FUNCTION__,tag);
    [sock readDataWithTimeout:READTIMEOUT tag:DataTag_Read];
}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"%s %d",__FUNCTION__,partialLength);
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    return READTIMEOUT;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    return WRITETIMEOUT;
}

@end
