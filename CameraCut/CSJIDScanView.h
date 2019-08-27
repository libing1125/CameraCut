//
//  CSJIDScanView.h
//  GoldenBullRace
//
//  Created by libing on 2019/8/19.
//  Copyright © 2019 CSJ Golden Bull (Beijing) Investment Consulting Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/** 扫描内容的 W 值 */
#define scanBorderW (kIPHONE6?0.5:0.4) * MAX(kScreenWidth, kScreenHeight)
#define scanBorderH scanBorderW*0.64
/** 扫描内容的 x 值 */
#define scanBorderX 0.5 * (1 - (kIPHONE6?0.5:0.4)) * MAX(kScreenWidth, kScreenHeight)
/** 扫描内容的 Y 值 */
#define scanBorderY  (MIN(kScreenWidth, kScreenHeight)-scanBorderH)/2

typedef enum : NSInteger
{
    CSJScanStyleDefault,
    CSJScanStyleGrid
    
}CSJScanStyle;
@interface CSJIDScanView : UIView
@property (nonatomic,assign) CSJScanStyle scanStyle;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,strong) UIColor *conerColor;
@property (nonatomic,assign) double alph;



@end

NS_ASSUME_NONNULL_END
