//
//  Preview.h
//  FILMMY-beta
//
//  Created by 张云翥 on 2018/7/24.
//  Copyright © 2018年 张云翥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface Preview : UIView

@property (strong, nonatomic) AVCaptureSession *captureSessionsion;

- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

@end
