//
//  UIButton+time.h
//  LYZButtonEventTimeDemo
//
//  Created by artios on 2016/12/22.
//  Copyright © 2016年 artios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (time)

/* 防止button重复点击，设置间隔 */
@property (nonatomic, assign) NSTimeInterval mm_acceptEventInterval;

@end
