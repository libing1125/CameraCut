//
//  CSJScanIDCardViewController.m
//  GoldenBullRace
//
//  Created by libing on 2019/8/19.
//  Copyright © 2019 CSJ Golden Bull (Beijing) Investment Consulting Co., Ltd. All rights reserved.
//

#import "CSJScanIDCardViewController.h"
#import "UIColor+UIColorFromRGB.h"
#import "CSJIDScanView.h"
#import <Photos/Photos.h>
#import "Masonry/Masonry/Masonry.h"
@interface CSJScanIDCardViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,CAAnimationDelegate,AVCapturePhotoCaptureDelegate>

@property(nonatomic,strong) CSJIDScanView *scanView;
@property (nonatomic,strong) UILabel *tipLabel;//提示label
@property (nonatomic,strong) UIImage *selectedImage;//裁剪好的image
@property (nonatomic,strong) UIImageView *takedImageView;
@property (nonatomic,strong) UIButton *takePictureBtn;//拍
@property (nonatomic,strong) UIButton *retakeBtn;//重拍
@property (nonatomic,strong) UIButton *nextBtn;//下一步

@property(nonatomic) AVCaptureDevice *device;
@property(nonatomic) AVCaptureDeviceInput *input;
//捕获输入
@property(nonatomic) AVCaptureMetadataOutput *output;
@property(nonatomic) AVCapturePhotoOutput *imageOutPut;
@property(nonatomic) AVCaptureSession *session;
//实时图层
@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;


@end

@implementation CSJScanIDCardViewController

-(void)dealloc
{
    NSLog(@"CSJScanIDCardViewController-dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    
    //自定义相机
    [self customCamera];
    [self customUI];
   
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    self.navigationController.navigationBarHidden = NO;
}
-(void)customUI
{
    self.scanView = [[CSJIDScanView alloc]init];
    self.scanView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scanView];
    [self.scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
    
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.font = [UIFont systemFontOfSize:15];
    _tipLabel.textColor = [UIColor colorWithRed:236 Green:236 Blue:236];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tipLabel];
    
    _tipLabel.frame = CGRectMake(100, 200, 200, 20);
    _tipLabel.center = CGPointMake(MAX(kScreenWidth, kScreenHeight)/2, scanBorderY+ scanBorderH+15);
    
    self.tipLabel.text = @"请把头像对准参考标识";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.frame = CGRectMake(getRectNavAndStatusHight, 20, 50, 50);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:btn];
    
    _takePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _takePictureBtn.frame = CGRectMake(0, 0, 60, 60);
    [_takePictureBtn setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
    [_takePictureBtn setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateHighlighted];
    _takePictureBtn.frame = CGRectMake(0, 0, 60, 60);
    _takePictureBtn.center = CGPointMake(scanBorderX+scanBorderW+40, scanBorderY+scanBorderH/2);
    [_takePictureBtn addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_takePictureBtn];
    
    _retakeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _retakeBtn.frame = CGRectMake(0, 0, 130, 32);
    _retakeBtn.center = CGPointMake(MAX(kScreenWidth, kScreenHeight)/2-85, scanBorderY+ scanBorderH+26);
    [_retakeBtn addTarget:self action:@selector(retakeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _retakeBtn.hidden = YES;
    [_retakeBtn setImage:[UIImage imageNamed:@"chongpai"] forState:UIControlStateNormal];
    [_retakeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_retakeBtn];
    
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextBtn.frame = CGRectMake(0, 0, 130, 32);
    _nextBtn.center = CGPointMake(MAX(kScreenWidth, kScreenHeight)/2+85, scanBorderY+ scanBorderH+26);
    [_nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _nextBtn.hidden = YES;
    [_nextBtn setImage:[UIImage imageNamed:@"sc_xia"] forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextBtn];
    
    
    self.takedImageView = [[UIImageView alloc]initWithFrame:CGRectMake(scanBorderX, scanBorderY, scanBorderW, scanBorderH)];
    [self.takedImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.takedImageView.hidden = YES;
    [self.view insertSubview:self.takedImageView belowSubview:self.scanView];
    
}
-(void)customCamera
{
    self.session = [[AVCaptureSession alloc]init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    self.imageOutPut = [[AVCapturePhotoOutput alloc]init];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    self.previewLayer.frame = CGRectMake(0, 0, MAX(kScreenWidth, kScreenHeight), MIN(kScreenWidth, kScreenHeight));
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutPut]) {
        [self.session addOutput:self.imageOutPut];
    }
    
    [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    //开始启动
    [self.session startRunning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark 强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)nextBtnClick
{
    self.imageBackBlock(self.selectedImage);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)retakeBtnClick
{
    _retakeBtn.hidden = YES;
    _nextBtn.hidden = YES;
    _tipLabel.hidden = NO;
    _takePictureBtn.hidden = NO;
    self.takedImageView.hidden = YES;
    [self.session startRunning];
    self.scanView.alph = 0.2;
    [self.scanView setNeedsDisplay];
}

- (void)popViewController
{
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 拍照
-(void)shutterCamera
{
    [self.imageOutPut capturePhotoWithSettings:[AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}] delegate:self];
    
}
#pragma mark AVCapturePhotoCaptureDelegate

-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(nonnull AVCapturePhoto *)photo error:(nullable NSError *)error
{
    NSData *data = photo.fileDataRepresentation;
    UIImage *image = [UIImage imageWithData:data];
//    UIImage *fixedImage = [self fixImage:image rotation:UIImageOrientationUp];
    
    self.takedImageView.hidden = NO;
    UIImage *originImage = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
    [self cropImage:originImage];
    
    
    [self.session stopRunning];
    self.scanView.alph = 1;
    [self.scanView setNeedsDisplay];
    
    _retakeBtn.hidden = NO;
    _nextBtn.hidden = NO;
    _tipLabel.hidden = YES;
    _takePictureBtn.hidden = YES;
    
}
- (void)cropImage:(UIImage *)image
{
    CGImageRef sourceImageRef = [image CGImage];
    CGFloat widthScale = image.size.width/kScreenWidth;
    CGFloat heightScale = image.size.height/kScreenHeight;
    
    CGRect clipedRect = CGRectMake(self.takedImageView.frame.origin.x*widthScale, self.takedImageView.frame.origin.y*heightScale, self.takedImageView.frame.size.width*widthScale, self.takedImageView.frame.size.height*heightScale);
    
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, clipedRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    NSLog(@"newImage=%@",NSStringFromCGSize(newImage.size));
    CGImageRelease(newImageRef);
    
    
    
    
    CGSize newSize = CGSizeMake(newImage.size.width*scanBorderH/newImage.size.height, scanBorderH);
    
    UIGraphicsBeginImageContext(newSize);
    [newImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *compressImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"newImage=%@",NSStringFromCGSize(compressImage.size));
    
    self.takedImageView.image = compressImage;
    
    self.selectedImage = compressImage;
    
    
}

#pragma mark 屏幕旋转
-(BOOL)shouldAutorotate
{
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return   UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}
@end
