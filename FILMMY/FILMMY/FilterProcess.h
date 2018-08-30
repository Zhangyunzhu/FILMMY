//
//  FilterProcess.h
//  相机部分
//
//  Created by 张云翥 on 2018/7/19.
//  Copyright © 2018年 张云翥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
@interface FilterProcess : NSObject

//拍立得的函数
//-(UIImage *)filterProcess:(UIImage *)inputImage;
//
////带日期的胶片函数
//-(UIImage *)filterProcess2:(UIImage *)inputImage andDateTime:(NSString*)dateTime;

//重做后的带日期的胶片函数
-(UIImage *)filterProcess3:(UIImage *)inputImage andDateTime:(NSString*)dateTime;
@end
