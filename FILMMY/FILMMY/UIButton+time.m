//
//  UIButton+time.m
//  LYZButtonEventTimeDemo
//
//  Created by artios on 2016/12/22.
//  Copyright © 2016年 artios. All rights reserved.
//

#import "UIButton+time.h"
#import <objc/runtime.h>

@implementation UIButton (time)


static const char *UIButton_acceptEventInterval = "UIButton_acceptEventInterval";
static const char *UIButton_acceptEventTime     = "UIButton_acceptEventTime";


- (NSTimeInterval )mm_acceptEventInterval{
    return [objc_getAssociatedObject(self, UIButton_acceptEventInterval) doubleValue];
}

- (void)setMm_acceptEventInterval:(NSTimeInterval)mm_acceptEventInterval{
    objc_setAssociatedObject(self, UIButton_acceptEventInterval, @(mm_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval )mm_acceptEventTime{
    return [objc_getAssociatedObject(self, UIButton_acceptEventTime) doubleValue];
}

- (void)setMm_acceptEventTime:(NSTimeInterval)mm_acceptEventTime{
    objc_setAssociatedObject(self, UIButton_acceptEventTime, @(mm_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


+ (void)load{
    //获取这两个方法
    Method systemMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    SEL sysSEL = @selector(sendAction:to:forEvent:);
    
    Method myMethod = class_getInstanceMethod(self, @selector(mm_sendAction:to:forEvent:));
    SEL mySEL = @selector(mm_sendAction:to:forEvent:);
    
    //添加方法进去
    BOOL didAddMethod = class_addMethod(self, sysSEL, method_getImplementation(myMethod), method_getTypeEncoding(myMethod));
    
    //如果方法已经存在
    if (didAddMethod) {
        class_replaceMethod(self, mySEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, myMethod);
        
    }
    
    /*-----以上主要是实现两个方法的互换,load是gcd的只shareinstance，果断保证执行一次-------*/
    
}

- (void)mm_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    if (NSDate.date.timeIntervalSince1970 - self.mm_acceptEventTime < self.mm_acceptEventInterval) {
        return;
    }
    
    if (self.mm_acceptEventInterval > 0) {
        self.mm_acceptEventTime = NSDate.date.timeIntervalSince1970;
    }
    
    [self mm_sendAction:action to:target forEvent:event];
}

@end
