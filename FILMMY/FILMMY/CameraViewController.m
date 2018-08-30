//
//  CameraViewController.m
//  FILMMY-beta
//
//  Created by 张云翥 on 2018/7/23.
//  Copyright © 2018年 张云翥. All rights reserved.
//

#import "CameraViewController.h"
#import "Preview.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <CoreMedia/CMMetadata.h>

#import "PhotoAlbumViewController.h"

#import "MotionManager.h"
#import "UIView+CCHUD.h"
#import "UIImage+Rotate.h"
#import "FilterProcess.h"
#import "UIButton+time.h"
#import <Photos/Photos.h>
dispatch_queue_t           _movieWritingQueue;

#define ISIOS9 __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

@interface CameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{

// 会话
AVCaptureSession          *_session;
// 输入
AVCaptureDeviceInput      *_deviceInput;
// 输出
AVCaptureConnection       *_videoConnection;
AVCaptureVideoDataOutput  *_videoOutput;
AVCaptureStillImageOutput *_imageOutput;

}

@property (strong, nonatomic) IBOutlet Preview *SBpreview;



@property(nonatomic, strong) MotionManager *motionManager;
@property(nonatomic, strong) AVCaptureDevice *activeCamera;     // 当前输入设备
@property(nonatomic, strong) AVCaptureDevice *inactiveCamera;  // 不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)
@property(nonatomic, assign) AVCaptureVideoOrientation    referenceOrientation; // 视频播放方向

//三个需要变化的按钮
@property (weak, nonatomic) IBOutlet UIButton *torchBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;
@property (weak, nonatomic) IBOutlet UIButton *AutoBtn;



@property(nonatomic, strong) UIView *focusView;    // 聚焦动画view
@property(nonatomic, strong) UIView *exposureView; // 曝光动画view


@property (nonatomic)UIImageView *imageView;//取景框背景


@end

@implementation CameraViewController



- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    if ( [self checkCameraPermission]) {
        
//        [self customCamera];
//        [self initSubViews];
        
        [self setupUI];
        _motionManager = [[MotionManager alloc] init];
        _referenceOrientation = AVCaptureVideoOrientationPortrait;
        
        [self focusAtPoint:CGPointMake(0.5, 0.5)];
    }
    
    //FIXME:preview背景
    [self.SBpreview setBackgroundColor:UIColor.clearColor];
    
        NSError *error;
    
        [self setupSession:&error];
        if (!error) {
            [self.SBpreview setCaptureSessionsion:_session];
            [_session setSessionPreset:AVCaptureSessionPresetPhoto];//FIXME:输出的图片分辨率与系统相机输出的分辨率保持一致
            [self startCaptureSession];
        }else{
            [self.view showError:error];
        }
}

-(void)setupUI{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.SBpreview addGestureRecognizer:tap];
//    NSLog(@"setupUI");
}

// 聚焦和曝光
-(void)tapAction:(UIGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.SBpreview];
    
    
    point = [self.SBpreview captureDevicePointForPoint:point];
    
    [self focusAtPoint:point];
    [self exposeAtPoint:point];
    
    self->_AutoBtn.selected = YES;

}


//设置对焦曝光图片
-(UIView *)focusView{
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor blueColor].CGColor;
        _focusView.layer.borderWidth = 5.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

-(UIView *)exposureView{
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = [UIColor purpleColor].CGColor;
        _exposureView.layer.borderWidth = 5.0f;
        _exposureView.hidden = YES;
    }
    return _exposureView;
}





#pragma mark - -相关配置
/// 会话
- (void)setupSession:(NSError **)error{
    _session = [[AVCaptureSession alloc]init];
    
        _session.sessionPreset = AVCaptureSessionPresetHigh;//（原来的）
//    _session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

/// 输入
- (void)setupSessionInputs:(NSError **)error{
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_session canAddInput:videoInput]){
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
    
}

/// 输出
- (void)setupSessionOutputs:(NSError **)error{
    
    //    dispatch_queue_t captureQueue = dispatch_queue_create("com.cc.captureQueue", DISPATCH_QUEUE_SERIAL);
    
    //静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
}

#pragma mark -- 会话控制
// 开启捕捉
- (void)startCaptureSession{
    if (!_movieWritingQueue) {
        _movieWritingQueue = dispatch_queue_create("Movie.Writing.Queue", DISPATCH_QUEUE_SERIAL);
    }
    if (!_session.isRunning){
        [_session startRunning];
    }
}

// 停止捕捉
- (void)stopCaptureSession{
    if (_session.isRunning){
        [_session stopRunning];
    }
}

#pragma mark - -输入设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera{
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera{
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}






#pragma mark - -按钮调用————————————————————————————————————————————————————————————
//拍照按钮
- (IBAction)takePhoto:(UIButton *)sender {
    [self takePictureImage];
    
    sender.mm_acceptEventInterval = 2.0f;
//    NSLog(@"拍照");
    
    
//    //加载动画
//    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(-kScreenWidth, 0, kScreenWidth, kScreenHeight)];
//    [self.view addSubview:_imageView];
//
//    self.imageView.layer.masksToBounds = YES;
//    self.imageView.image = [UIImage imageNamed:@"等待.png"];
//
//    [UIView animateWithDuration:0.5 animations:^{
//        CGRect frame = self.imageView.frame;
//        frame.origin.x += kScreenWidth;
//        self.imageView.frame = frame;
//    }];
//    [UIView animateWithDuration:0.5 delay:3 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
//        CGRect frame = self.imageView.frame;
//        frame.origin.x -= kScreenWidth;
//        self.imageView.frame = frame;
//
//    } completion:^(BOOL finished){
//        [self.imageView removeFromSuperview];
//        [self.session startRunning];
//    }];
//    NSLog(@"SBpreview宽和高:%f,%f",sender.width,sender.height);
    //加载动画
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CD_SCREEN_HEIGHT,CD_SCREEN_WIDTH, CD_SCREEN_HEIGHT)];
    [self.view addSubview:_imageView];
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.image = [UIImage imageNamed:@"快门背景"];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.imageView.frame;
        frame.origin.y -= CD_SCREEN_HEIGHT;
        self.imageView.frame = frame;
    }];
    [UIView animateWithDuration:0.5 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut  animations:^{
        CGRect frame = self.imageView.frame;
        frame.origin.y += CD_SCREEN_HEIGHT;
        self.imageView.frame = frame;
        
    } completion:^(BOOL finished){
        [self.imageView removeFromSuperview];
//        [self->_session startRunning];
    }];
    
    

    
}

//滤镜按钮
//- (IBAction)filterChose:(UIButton *)sender {
//}

//相册按钮
- (IBAction)photoAlbum:(UIButton *)sender {
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    // 设置代理
//    imagePickerController.delegate = self;
    // 是否允许编辑（默认为NO）
//    imagePickerController.allowsEditing= YES;
//    [self presentViewController:imagePickerController animated:YES completion:^{}];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[PhotoAlbumViewController new]] animated:YES completion:nil];
    
}

//代理方法：
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//
////    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
////    if ([type isEqualToString:@"public.image"]) {
////        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        //process image
////        [picker dismissViewControllerAnimated:YES completion:nil];
////    }
//    NSLog("选择了一张图片");
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//    CCImagePreviewController *vc = [[CCImagePreviewController alloc]initWithImage:image frame:CGRectMake(0, 0, image.size.width/3, image.size.height/3)];
//    [picker pushViewController:vc animated:YES];
//}
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}


//设置按钮
- (IBAction)setBtn:(UIButton *)sender {
}

//自动曝光按钮
- (IBAction)autoBtn:(UIButton *)sender {
    [sender setImage:[UIImage imageNamed:@"自动-按下"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self resetFocusAndExposureModes];
    self->_AutoBtn.selected = NO;
    
}

//闪光灯按钮
- (IBAction)flashLight:(UIButton *)sender {
    self->_flashBtn.selected = !self->_flashBtn.selected;
    [sender setImage:[UIImage imageNamed:@"闪光灯-按下"] forState:UIControlStateSelected | UIControlStateHighlighted];
        self->_torchBtn.selected = NO;//取消补光灯
        [self changeFlash:[self flashMode] == AVCaptureFlashModeOn?AVCaptureFlashModeOff:AVCaptureFlashModeOn];
    
}

//补光按钮
- (IBAction)lightBtn:(UIButton *)sender {
    self->_flashBtn.selected = NO;
    self->_torchBtn.selected = !self->_torchBtn.selected;
    [self changeTorch:[self torchMode] == AVCaptureTorchModeOn?AVCaptureTorchModeOff:AVCaptureTorchModeOn];
}

//切换前后按钮
- (IBAction)changeCamera:(UIButton *)sender {
    [self switchCameras];
}









#pragma mark - -拍摄照片

-(void)takePictureImage{
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    
    // 前置摄像头翻转
    AVCaptureDevicePosition currentPosition=[[_deviceInput device] position];
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        connection.videoMirrored = YES;
    } else {
        connection.videoMirrored = NO;
    }
    
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error) {
            [self.view showError:error];
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        //FIXME: 获取图片Exif信息————————————————————————————————————————————————————————————————————
        CGImageSourceRef imageRef=CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        
        NSDictionary *imageProperty=(NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageRef,0, NULL));
        
        //    NSDictionary *ExifDictionary=[imageProperty valueForKey:(NSString*)kCGImagePropertyExifDictionary];
            NSDictionary *tiffDictionary=[imageProperty valueForKey:(NSString*)kCGImagePropertyTIFFDictionary];
//        NSLog(@"获取tiff信息%@",tiffDictionary);
        
        NSString * str  = [tiffDictionary objectForKey:@"DateTime"];
        
        
        //从第三个字符开始，截取长度为4的字符串
        NSString *dateTime = [str substringWithRange:NSMakeRange(2,8)];
        NSLog(@"%@",dateTime);

        //——————————————————————————————————————————————————————————————————————————————————————————
        
        UIImage *image = [[UIImage alloc]initWithData:imageData];
        
        if (image!=nil) {
            //滤镜处理
            [self imageProcess3:image andDateTime:dateTime];
        } else {
            NSLog(@"没有image");
        }
//        NSLog(@"%ld",(long)image.imageOrientation);
        
        
        
    }];
}


#pragma mark - -转换摄像头
- (id)switchCameras{
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        AVCaptureFlashMode flashMode = [self flashMode];
        
        // 转换摄像头
        [_session beginConfiguration];
        [_session removeInput:_deviceInput];
        if ([_session canAddInput:videoInput]) {
            CATransition *animation = [CATransition animation];
            animation.type = @"oglFlip";
            animation.subtype = kCATransitionFromLeft;
            animation.duration = 0.5;
            [self.SBpreview.layer addAnimation:animation forKey:@"flip"];
            [_session addInput:videoInput];
            _deviceInput = videoInput;
        } else {
            [_session addInput:_deviceInput];
        }
        [_session commitConfiguration];
        
        // 完成后需要重新设置视频输出链接
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // 如果后置转前置，系统会自动关闭手电筒，如果之前打开的，需要更新UI
        if (videoDevice.position == AVCaptureDevicePositionFront) {
            [self changeTorch:NO];
        }
        
        // 前后摄像头的闪光灯不是同步的，所以在转换摄像头后需要重新设置闪光灯
        [self changeFlash:flashMode];
        
        return nil;
    }
    return error;
}

#pragma mark - -聚焦
- (id)focusAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    BOOL supported = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus];
    if (supported){
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"设备不支持聚焦" code:407];
}

#pragma mark - -曝光
static const NSString *CameraAdjustingExposureContext;
- (id)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"设备不支持曝光" code:405];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == &CameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    [self.view showError:error];
                }
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - -自动聚焦、曝光
- (id)resetFocusAndExposureModes{
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        [device unlockForConfiguration];
    }
    return error;
}

#pragma mark --闪光灯
- (BOOL)cameraHasFlash{
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode{
    return [[self activeCamera] flashMode];
}

- (id)changeFlash:(AVCaptureFlashMode)flashMode{
    if (![self cameraHasFlash]) {
        return [self errorWithMessage:@"不支持闪光灯" code:401];
    }
    // 如果手电筒打开，先关闭手电筒
    if ([self torchMode] == AVCaptureTorchModeOn) {
        [self setTorchMode:AVCaptureTorchModeOff];
    }
    return [self setFlashMode:flashMode];
}

- (id)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"不支持闪光灯" code:401];
}

#pragma mark - -手电筒
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (id)changeTorch:(AVCaptureTorchMode)torchMode{
    if (![self cameraHasTorch]) {
        return [self errorWithMessage:@"不支持手电筒" code:403];
    }
    // 如果闪光灯打开，先关闭闪光灯
    if ([self flashMode] == AVCaptureFlashModeOn) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    return [self setTorchMode:torchMode];
}

- (id)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return [self errorWithMessage:@"不支持手电筒" code:403];
}

#pragma mark - -Private methods
- (NSError *)errorWithMessage:(NSString *)text code:(NSInteger)code  {
    NSDictionary *desc = @{NSLocalizedDescriptionKey: text};
    NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:code userInfo:desc];
    return error;
}




// 当前设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}


//FIXME: 滤镜处理

//-(void)imageProcess:(UIImage *)inputImage{
//    FilterProcess *filterProcess = [[FilterProcess alloc]init];
//    UIImage *afterProcessimage = [filterProcess filterProcess:inputImage];
//    [self savedPhotostoAlbum:afterProcessimage];
//}
//
//-(void)imageProcess2:(UIImage *)inputImage andDateTime:(NSString*)dateTime{
//    FilterProcess *filterProcess = [[FilterProcess alloc]init];
//    UIImage *afterProcessimage2 = [filterProcess filterProcess2:inputImage andDateTime:dateTime];
////    [self savedPhotostoAlbum:afterProcessimage2];
//    [self savePhoto:afterProcessimage2];
//    [self saveToSandBox:afterProcessimage2];
//}

-(void)imageProcess3:(UIImage *)inputImage andDateTime:(NSString*)dateTime{
    FilterProcess *filterProcess = [[FilterProcess alloc]init];
    UIImage *afterProcessimage3 = [filterProcess filterProcess3:inputImage andDateTime:dateTime];
    //    [self savedPhotostoAlbum:afterProcessimage2];
    NSLog(@"宽%f,高%f",afterProcessimage3.size.width,afterProcessimage3.size.height);
    
    if(afterProcessimage3.size.width < afterProcessimage3.size.height){
        [self savePhoto:afterProcessimage3];
        [self saveToSandBox:afterProcessimage3];
    }else{
        [self savePhoto:afterProcessimage3];
        [self saveToSandBox:[afterProcessimage3 rotate:UIImageOrientationRight]];
    }
    
}

//向沙盒里写入文件夹，并向文件夹里写入东西
-(void)saveToSandBox:(UIImage*)inputImage{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *folder = [document stringByAppendingPathComponent:@"folder"];
    
    int num = [self getScopeInsideRandomValue:100000 To:999999];
    NSLog(@"%d", num);
    NSString *filePathName = [NSString stringWithFormat:@"IMG_%d.jpg",num];
    NSString *filePath = [folder stringByAppendingPathComponent:filePathName];
    
    if (![fileManager fileExistsAtPath:folder]) {
        
        BOOL blCreateFolder= [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:NULL];
        
        if (blCreateFolder) {
            
            NSLog(@" folder success");
            
        }else {
            
            NSLog(@" folder fial");
            
        }
        
    }else {
        
        NSLog(@" 沙盒文件夹已经存在，不再创建文件夹");
        
    }
    
    if (![fileManager fileExistsAtPath:filePath]) {
        
        //        NSString *strPathOld = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"png"];
        //        NSData *data = [NSData dataWithContentsOfFile:strPathOld];
        BOOL result = [UIImageJPEGRepresentation(inputImage, 1) writeToFile:filePath atomically:YES];;
        
        if (result) {
            
            NSLog(@"file success");
            
        }else {
            
            NSLog(@"file not success");
            
        }
        
    }else {
        
        NSLog(@" 沙盒文件已经存在，不再创建该文件");
    }
}

// 获取一个随机整数，范围在[from,to），包括from，不包括to
-(int)getScopeInsideRandomValue:(int)num1 To:(int)num2 {
    
    return (int)(num1 + (arc4random() % (num2 - num1 + 1)));
}

//保存图片到相册
-(void)savedPhotostoAlbum:(UIImage *)inputImage{
    UIImageWriteToSavedPhotosAlbum(inputImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}
//保存图片的回调
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message = @"";
    if (!error) {
        message = @"成功保存到相册";
    }else{
        message = [error description];
    }
    NSLog(@"message is %@",message);
}

// 添加图片到自己相册
- (void)savePhoto:(UIImage* )inputImage
{
    //异步保存
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 1.创建图片请求类(创建系统相册中新的图片)PHAssetCreationRequest
        // 把图片放在系统相册
        if (@available(iOS 9.0, *)) {
            PHAssetCreationRequest *assetCreationRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:inputImage];
            
            // 2.创建相册请求类(修改相册)PHAssetCollectionChangeRequest
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = nil;
            
            // 获取之前相册
            PHAssetCollection *assetCollection = [self fetchAssetCollection:@"Filmmy胶卷盒"];
            
            // 判断是否已有相册
            if (assetCollection) {
                // 如果存在已有同名相册   指定这个相册,创建相册请求修改类
                assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            } else {  //不存在,创建新的相册
                assetCollectionChangeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Filmmy胶卷盒"];
            }
            // 3.把图片添加到相册中
            // NSFastEnumeration:以后只要看到这个,就可以表示数组
            //assetCreationRequest.placeholderForCreatedAsset 图片请求类占位符(相当于一个内存地址)
            //因为creationRequestForAssetFromImage方法是异步实行的,在这里不能保证 assetCreationRequest有值
            
            [assetCollectionChangeRequest addAssets:@[assetCreationRequest.placeholderForCreatedAsset]];
        } else {
            // Fallback on earlier versions
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"保存到自己相册成功");
        } else {

            NSLog(@"保存到自己相册失败");
        }
        
    }];
}

// 指定相册名称,获取相册
- (PHAssetCollection *)fetchAssetCollection:(NSString *)title
{
    // 获取相簿中所有自定义相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //遍历相册,判断是否存在同名的相册
    for (PHAssetCollection *assetCollection in result) {
        if ([title isEqualToString:assetCollection.localizedTitle]) {  //存在,就返回这个相册
            return assetCollection;
        }
    }
    return nil;
}



#pragma mark- 检测相机权限
- (BOOL)checkCameraPermission
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限" message:@"设置-隐私-相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        
        
        // 1.创建UIAlertController
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请打开相机权限"
            message:@"设置-隐私-相机"
            preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alertController animated:YES completion:nil];

        return NO;
    }
    else{
        return YES;
    }
    return YES;
}



@end
