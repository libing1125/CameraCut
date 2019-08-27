//
//  CSJScanIDCardViewController.h
//  GoldenBullRace
//
//  Created by libing on 2019/8/19.
//  Copyright © 2019 CSJ Golden Bull (Beijing) Investment Consulting Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSJScanIDCardViewController : UIViewController
@property(nonatomic,copy) void(^imageBackBlock)(UIImage *image);
@end

NS_ASSUME_NONNULL_END
