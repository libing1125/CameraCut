//
//  CSJScanIDCardViewController.h
//  GoldenBullRace
//
//  Created by libing on 2019/8/19.
//  Copyright © 2019 CSJ Golden Bull (Beijing) Investment Consulting Co., Ltd. All rights reserved.
//

#import "CSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSJScanIDCardViewController : CSJBaseViewController
@property(nonatomic,copy) void(^imageBackBlock)(UIImage *image);
@end

NS_ASSUME_NONNULL_END
