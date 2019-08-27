//
//  ViewController.m
//  CameraCut
//
//  Created by libing on 2019/8/26.
//  Copyright © 2019 libing. All rights reserved.
//

#import "ViewController.h"
#import "CSJScanIDCardViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)takePicture:(UIButton *)sender {
    CSJScanIDCardViewController * scVC = [[CSJScanIDCardViewController alloc]init];
    scVC.imageBackBlock = ^(UIImage * _Nonnull image) {
        
        self.ImageView.image = image;
            
       
    };
    [self.navigationController pushViewController:scVC animated:YES];
}

@end
