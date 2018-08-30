//
//  FilterProcess.m
//  相机部分
//
//  Created by 张云翥 on 2018/7/19.
//  Copyright © 2018年 张云翥. All rights reserved.
//

#import "FilterProcess.h"
#import "UIImage+Rotate.h"
#import "GpUImageScaleFilter.h"
@implementation FilterProcess

//-(UIImage *)filterProcess:(UIImage *)inputImage{
//
//    long int num = (long)[inputImage imageOrientation];
//     NSLog(@"inputImage->%ld", num);
//    if (num == 0||num ==1|| num ==5|| num ==4) {
//
//        /*目前得到的照片都是我想要的样子，但是图片的imageOrientation不同*/
//        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
//        NSLog(@"fix-inputImage->%ld", (long)[inputImage imageOrientation]);
//        [self savedPhotostoAlbum:inputImage];
//
//        UIImage * afterLUTImage = [self addlookuptable:inputImage andLUT:@"T22.jpg"];//图片旋转在这里开始出错
//        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
//        [self savedPhotostoAlbum:afterLUTImage];
//
//        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"6.jpg"];
//
//        UIImage * afterBaseAdjust = [self addBaseAdjust:afterLightleak];
//
//        UIImage *afteraddFrame = [self addTwoImage:afterBaseAdjust withImage:@"宽幅拍立得相纸儿.png"];
//
//        return afteraddFrame;
//
//    }else{
////        NSLog(@"我是2367");
//        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
//        inputImage = [inputImage rotate:UIImageOrientationRight];//向右旋转
//
//        UIImage * afterLUTImage = [self addlookuptable:inputImage andLUT:@"T22.jpg"];//图片旋转在这里开始出错
//        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
//
//        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"6.jpg"];
//
//        UIImage * afterBaseAdjust = [self addBaseAdjust:afterLightleak];
//
//        UIImage *afteraddFrame = [self addTwoImage:afterBaseAdjust withImage:@"宽幅拍立得相纸儿.png"];
//
//        //恢复原状（竖着的）
////        afteraddFrame = [afteraddFrame rotate:UIImageOrientationLeft];
//        return afteraddFrame;
//    }
//
//}


////拍立得的函数
//-(UIImage *)filterProcess:(UIImage *)inputImage{
//
//    long int num = (long)[inputImage imageOrientation];
//    NSLog(@"inputImage->%ld", num);
//    if (num == 2||num ==3|| num ==6|| num ==7) {
//        //        NSLog(@"我是2367");
//        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
//        inputImage = [inputImage rotate:UIImageOrientationRight];//向右旋转
//
//        UIImage * afterLUTImage = [self addlookuptable:inputImage andLUT:@"T22.jpg"];//图片旋转在这里开始出错
//        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
//
//
//        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"leak6.jpg"];
//
//        UIImage * afterBaseAdjust = [self addBaseAdjust:afterLightleak];
//
//        UIImage *afteraddFrame = [self addTwoImage:afterBaseAdjust withImage:@"宽幅拍立得相纸last.png"];
//
//        //恢复原状（竖着的）
//        afteraddFrame = [afteraddFrame rotate:UIImageOrientationLeft];
//        return afteraddFrame;
//
//
//    }else{
//        /*目前得到的照片都是我想要的样子，但是图片的imageOrientation不同*/
//        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
//        NSLog(@"fix-inputImage->%ld", (long)[inputImage imageOrientation]);
//
//        UIImage * afterLUTImage = [self addlookuptable:inputImage andLUT:@"T22.jpg"];//图片旋转在这里开始出错
//        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
//
//        //FIXME: BUG
//        if ([afterLUTImage imageOrientation]==2) {
//            afterLUTImage = [afterLUTImage rotate:UIImageOrientationRight];//向右旋转
//        }
//        if ([afterLUTImage imageOrientation]==3) {
//            afterLUTImage = [afterLUTImage rotate:UIImageOrientationLeft];//向右旋转
//        }
//
//        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"leak6.jpg"];
//
//        UIImage * afterBaseAdjust = [self addBaseAdjust:afterLightleak];
//
//        UIImage *afteraddFrame = [self addTwoImage:afterBaseAdjust withImage:@"宽幅拍立得相纸last.png"];
//
//        return afteraddFrame;
//    }
//
//}

////带日期的胶片函数
//-(UIImage *)filterProcess2:(UIImage *)inputImage andDateTime:(NSString*)dateTime{
//
//    long int num = (long)[inputImage imageOrientation];
//    NSLog(@"inputImage->%ld", num);
//    //竖着的
//    if (num == 2||num ==3|| num ==6|| num ==7) {
//        //        NSLog(@"我是2367");
//        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
//        inputImage = [inputImage rotate:UIImageOrientationLeft];//向右旋转
//
//        UIImage * afterLUTImage = [self addlookuptable:inputImage andLUT:@"fushishan.jpg"];//图片旋转在这里开始出错 默认T22
//        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
//
//
//        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"leak6.jpg"];
//
//        UIImage * afterBaseAdjust = [self addBaseAdjust:afterLightleak];
//
////        UIImage *afteraddFrame = [self addTwoImage:afterBaseAdjust withImage:@"宽幅拍立得相纸last.png"];
//        UIImage *afterDateTimeVer = [self addDateTimeVer:afterBaseAdjust withDateTime:dateTime];
//        //恢复原状（竖着的）
//        afterDateTimeVer = [afterDateTimeVer rotate:UIImageOrientationRight];
//        return afterDateTimeVer;
//
//
//    }else{
//        //横着的
//        /*目前得到的照片都是我想要的样子，但是图片的imageOrientation不同*/
//        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
//        NSLog(@"fix-inputImage->%ld", (long)[inputImage imageOrientation]);
//
//        UIImage * afterLUTImage = [self addlookuptable:inputImage andLUT:@"fushishan.jpg"];//图片旋转在这里开始出错
//        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
//
//        //FIXME: BUG
//        if ([afterLUTImage imageOrientation]==2) {
//            afterLUTImage = [afterLUTImage rotate:UIImageOrientationRight];//向右旋转
//        }
//        if ([afterLUTImage imageOrientation]==3) {
//            afterLUTImage = [afterLUTImage rotate:UIImageOrientationLeft];//向右旋转
//        }
//
//        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"6.jpg"];
//
//        UIImage * afterBaseAdjust = [self addBaseAdjust:afterLightleak];
//
//        UIImage *afterDateTimeVer = [self addDateTimeVer:afterBaseAdjust withDateTime:dateTime];
//        return afterDateTimeVer;
//    }
//
//}


/**
 一、先裁剪
 二、加边缘模糊，边缘阴影，伽马，边缘色散
 三、加噪点函数
 四、加LUT滤镜
 五、加漏光
 五、锐化
 六、加日期
 */
-(UIImage *)filterProcess3:(UIImage *)inputImage andDateTime:(NSString*)dateTime{
    long int num = (long)[inputImage imageOrientation];
    NSLog(@"inputImage->%ld", num);
    //竖着的
    if (num == 2||num ==3|| num ==6|| num ==7) {
        
        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation
        inputImage = [inputImage rotate:UIImageOrientationLeft];//向右旋转
        
        UIImage *afterCutImage  = [self cutImage:inputImage];
        UIImage *afterTuningImage = [self tuningImage:afterCutImage];
        [afterTuningImage imageWithNoiseIntensity:0.4 gray:YES];
        
        
        UIImage * afterLUTImage = [self addlookuptable:afterTuningImage andLUT:@"wb.jpg"];//图片旋转在这里开始出错 默认T22
        
        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
        
        
        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"leak6.jpg"];
        
        UIImage *aftersharpen = [self changeValueForSharpenilter:4.0 image:afterLightleak];
        
        UIImage *afterDateTimeVer = [self addDateTimeVer:aftersharpen withDateTime:dateTime];
        //恢复原状（竖着的）
        afterDateTimeVer = [afterDateTimeVer rotate:UIImageOrientationRight];
        return afterDateTimeVer;
        
        
    }else{
        //横着的
        /*目前得到的照片都是我想要的样子，但是图片的imageOrientation不同*/
        inputImage =  [inputImage fixOrientation];//保留目前图像的样子，并且去除imageOrientation

        
        UIImage *afterCutImage  = [self cutImage:inputImage];
        UIImage *afterTuningImage = [self tuningImage:afterCutImage];
        [afterTuningImage imageWithNoiseIntensity:0.7 gray:YES];
        
        
        UIImage * afterLUTImage = [self addlookuptable:afterTuningImage andLUT:@"wb.jpg"];//图片旋转在这里开始出错 默认T22
        
        NSLog(@"afterLUTImage imageOrientation->%ld", (long)[afterLUTImage imageOrientation]);
        
        UIImage * afterLightleak =  [self addLightleak:afterLUTImage andisRandom:YES  andwhichleak:@"leak6.jpg"];
        
        UIImage *aftersharpen = [self changeValueForSharpenilter:4.0 image:afterLightleak];
        
        UIImage *afterDateTimeVer = [self addDateTimeVer:aftersharpen withDateTime:dateTime];

        return afterDateTimeVer;
    }
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————

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



/**
 1.lookuptable滤镜方法
 
 @param inputImage 输入一张UIImage图片
 @param LUTImageName 输入颜色查找表的名称
 
 @return 返回一张经过LUT染色过的图片
 */
-(UIImage *)addlookuptable:(UIImage *)inputImage andLUT:(NSString *)LUTImageName{
    NSLog(@"1-addlookuptable inputImage->%ld", (long)[inputImage imageOrientation]);
    
    //定义GPUImageLookupFilter
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    //设置要渲染的区域
    [lookupFilter forceProcessingAtSize:inputImage.size];
    [lookupFilter useNextFrameForImageCapture];//持续图片呈现(必须要加这句不然会生成nil)
    
    //获取数据源
    GPUImagePicture *imageSource = [[GPUImagePicture alloc]initWithImage:inputImage];
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:LUTImageName]];
    
    //使用addTarget:方法为处理链路添加每个环节的对象
    [imageSource addTarget:lookupFilter];
    [lookupImageSource addTarget:lookupFilter];
    
    //呈现图像
    [imageSource processImage];
    [lookupImageSource processImage];
    
    //获取渲染后的图片(生成图片)
    [lookupFilter useNextFrameForImageCapture];
    UIImage *newImage = [lookupFilter imageFromCurrentFramebuffer];
//    NSLog(@"2-addlookuptable inputImage->%ld", (long)[newImage imageOrientation]);
    
    return newImage;
}



/**
 2.加漏光素材
 注意：最多支持两张图片混合
 @param inputImage 输入一张UIImage图片
 @param random BOOL值判断
 @param leakImageName 如果不是随机的，那么用那张漏光素材
 @return 返回一张带漏光的素材
 */
-(UIImage *)addLightleak:(UIImage *)inputImage andisRandom:(BOOL)random andwhichleak:(NSString *)leakImageName{
    
    UIImage *leakImage = [[UIImage alloc]init];
    //1.加载一个UIImage对象(注意图片名的后缀名)
    if(random == YES){
        //        //获取一个随机整数范围在：[0,100)包括0，不包括100
        int num =  arc4random() % 60;
        NSLog(@"随机数%d",num);
        if (num <= 22) {
            leakImage = [UIImage imageNamed:[NSString stringWithFormat:@"leak%d.jpg",num]];
        }else{
            leakImage = [UIImage imageNamed:@"leak16.jpg"];
        }
        
    }else{
        leakImage = [UIImage imageNamed:leakImageName];
    }
    
    
    //2.素材导入
    GPUImagePicture *ImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    GPUImagePicture *leakImageSource = [[GPUImagePicture alloc] initWithImage:leakImage];
    
    //3.图片叠加
    GPUImageLightenBlendFilter *blendFilter = [[GPUImageLightenBlendFilter alloc]init];//变亮混合
    //    GPUImageNormalBlendFilter *blendFilter = [[GPUImageNormalBlendFilter alloc]init];//正常混合
    //   GPUImageSoftLightBlendFilter *blendFilter = [[GPUImageSoftLightBlendFilter alloc]init];//柔光混合
    
    [ImageSource addTarget:blendFilter];
    [leakImageSource addTarget:blendFilter];
    
    [ImageSource  processImage];
    [leakImageSource processImage];
    
    //持续图片呈现
    [blendFilter useNextFrameForImageCapture];
    UIImage *filteredImage = [blendFilter imageFromCurrentFramebuffer];
    return filteredImage;
}


/**
 3.加基础滤镜
 
 @param inputImage 输入一张图片
 @return 输出一张图片
 */
-(UIImage *)addBaseAdjust:(UIImage *)inputImage{
    
    /*
     *GPUImageFilterPipeline的方式混合滤镜
     */
    
    //------------------------------滤镜列表--------------------------------
    //伽马线滤镜
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc]init];
    gammaFilter.gamma = 0.8;//拍立得1.2
    
    //径向运动模糊
    GPUImageZoomBlurFilter *zoomBlurFilter = [[GPUImageZoomBlurFilter alloc]init];
    zoomBlurFilter.blurSize = 0.2;
    
    /*边缘阴影
     Vignette效果，根据图像点与选定的 Vignette 中心的距离d
     vignetteStart， vignetteEnd 为渐变区起始和终结距离
     vignetteColor为 Vignette 效果的颜色*/
    GPUImageVignetteFilter *vignetteFilte = [[GPUImageVignetteFilter alloc] init];
    vignetteFilte.vignetteStart = 0.4;
    vignetteFilte.vignetteEnd = 1.3;
    
    //用不了不知道为啥
    //    GPUImageGaussianSelectiveBlurFilter *gaussianSelectiveBlurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
    
    //    gaussianSelectiveBlurFilter.excludeCircleRadius = 0.3f;
    //    gaussianSelectiveBlurFilter.excludeCirclePoint = CGPointMake(0,0);
    
    //把多个滤镜对象放到数组中
    NSMutableArray *filterArr = [NSMutableArray array];
    [filterArr addObject:gammaFilter];
    [filterArr addObject:zoomBlurFilter];
    //    [filterArr addObject:gaussianSelectiveBlurFilter];
    [filterArr addObject:vignetteFilte];
    
    //---------------------------------------------------------------------
    
    //MARK: -可以不用了，因为不需要GPUImageFilterPipeline去输出到容器
    //    //初始化UIImageView
    //    UIImageView *myUIImageView = [[UIImageView alloc]init];
    //    //初始化GpuImageView
    //    GPUImageView *myGPUImageView = [[GPUImageView alloc] initWithFrame:myUIImageView.bounds];
    //    [myUIImageView addSubview:myGPUImageView];
    
    //初始化GPUImagePicture数据源
    GPUImagePicture * imageSource= [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
    //创建GPUImageFilterPipeline对象
    //参数1：滤镜数组
    //参数2：被渲染的输入源，可以是GPUImagePicture、GPUImageVideoCamera等
    //参数3：渲染后的输出容器，一般是显示的视图，如：GPUImageView
    GPUImageFilterPipeline *filterPipline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArr input:imageSource output:nil];
    
    //处理图片
    [imageSource processImage];
    [vignetteFilte useNextFrameForImageCapture];//必须是最后加入的那个滤镜
    
    //拿到处理后的图片
    UIImage *dealedImage = [filterPipline currentFilteredFrame];
    return dealedImage;
    
}


/**
 4.加水印
 
 @param inputImage 输入一张图片
 @return 返回一张图片
 */
//-(UIImage *)addWatermark:(UIImage *)inputImage{
//
//}


/**
 5.重叠两张图片
 
 @param inputImage 图片1
 @param imageName2 图片2名字
 @return 返回一张图片
 */
- (UIImage *)addTwoImage:(UIImage *)inputImage withImage:(NSString *)imageName2 {
    
    //    UIImage *image1 = [UIImage imageNamed:imageName1];
    UIImage *image2 = [UIImage imageNamed:imageName2];
    
    UIGraphicsBeginImageContext(CGSizeMake(5650, 4100));
    
    //相片（1920*1080）
    //    [inputImage drawInRect:CGRectMake(0, 0, inputImage.size.width, inputImage.size.height)];
    [inputImage drawInRect:CGRectMake(140,255, 5300, 2980)];
//    NSLog(@"%f",inputImage.size.width);
//    NSLog(@"%f",inputImage.size.height);
    
    //相纸
    //    [image2 drawInRect:CGRectMake(0,0, image2.size.width, image2.size.height)];
//    [image2 drawInRect:CGRectMake(0,0, 5500, 4200)];
    [image2 drawInRect:CGRectMake(0,0, 5630, 4050)];
    //可以drawInRect很多在上面！！！
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}



/**
 添加日期

 @param inputImage 输入一张图片
 @param DateTime 输入图片的日期
 @return 返回一张带日期的图片
 */
-(UIImage*)addDateTimeVer:(UIImage*)inputImage withDateTime:(NSString*)DateTime{
    //    UIGraphicsBeginImageContext(CGSizeMake(1280, 720));
    //    [inputImage drawInRect:CGRectMake(0,0,1280,720)];
    UIGraphicsBeginImageContext(CGSizeMake(4032, 2688));
    [inputImage drawInRect:CGRectMake(0,0,4032, 2688)];//会直接裁掉上下阴影，不推荐
    
    NSString *temp = nil;
    UIImage *image = [[UIImage alloc]init];
    int pointx = 3142;
    //把用到的字符串参数放到一个数组里
    NSArray *arry = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@":", nil];
    //    NSLog(@"%lu",index);
    for(int i =0; i < [DateTime length]; i++)
    {
        
        
        
        temp = [DateTime substringWithRange:NSMakeRange(i, 1)];
        //        NSLog(@"第%d个字是:%@",i,temp);
        //比如我们要把@"1"作为switch的参数，则取到它在数组中的下标，然后在switch中根据下标来进行处理。
        unsigned long index = [arry  indexOfObject:temp];
        
        switch (index) {
            case 0:
                NSLog(@"时间是0");
                image = [UIImage imageNamed:@"0"];
                break;
            case 1:
                NSLog(@"时间是1");
                image = [UIImage imageNamed:@"1"];
                break;
            case 2:
                NSLog(@"时间是2");
                image = [UIImage imageNamed:@"2"];
                break;
            case 3:
                NSLog(@"时间是3");
                image = [UIImage imageNamed:@"3"];
                break;
            case 4:
                NSLog(@"时间是4");
                image = [UIImage imageNamed:@"4"];
                break;
            case 5:
                NSLog(@"时间是5");
                image = [UIImage imageNamed:@"5"];
                break;
            case 6:
                NSLog(@"时间是6");
                image = [UIImage imageNamed:@"6"];
                break;
            case 7:
                NSLog(@"时间是7");
                image = [UIImage imageNamed:@"7"];
                break;
            case 8:
                NSLog(@"时间是8");
                image = [UIImage imageNamed:@"8"];
                break;
            case 9:
                NSLog(@"时间是9");
                image = [UIImage imageNamed:@"9"];
                break;
            case 10:
                NSLog(@"时间是:");
                image = [UIImage imageNamed:@"点"];
                break;
                
            default:
                NSLog(@"无");
                break;
        }
        
        [image drawInRect:CGRectMake(pointx, 2392, 72, 100)];
        pointx = pointx + 70;
    }
    
    
    
    //可以drawInRect很多在上面！！！
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}


/**
 裁剪图片

 @param inputImage 输入一张图片
 @return 输出一张裁剪好的图片
 */
-(UIImage*)cutImage:(UIImage*)inputImage{
    UIGraphicsBeginImageContext(CGSizeMake(4032, 2688));
    [inputImage drawInRect:CGRectMake(0,-168,4032,3024)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
}


/**
 加边缘模糊，边缘阴影，伽马，边缘色散

 @param inputImage 输入一张图片
 @return 输出一张调整过的图片
 */
-(UIImage*)tuningImage:(UIImage*)inputImage{
    /*
     *GPUImageFilterPipeline的方式混合滤镜
     */
    
    //------------------------------滤镜列表--------------------------------
    //伽马线滤镜
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc]init];
    gammaFilter.gamma = 1.1;//拍立得1.2
    
    //径向运动模糊
    GPUImageZoomBlurFilter *zoomBlurFilter = [[GPUImageZoomBlurFilter alloc]init];
    zoomBlurFilter.blurSize = 0.1;
    
    /*边缘阴影
     Vignette效果，根据图像点与选定的 Vignette 中心的距离d
     vignetteStart， vignetteEnd 为渐变区起始和终结距离
     vignetteColor为 Vignette 效果的颜色*/
    GPUImageVignetteFilter *vignetteFilte = [[GPUImageVignetteFilter alloc] init];
    vignetteFilte.vignetteStart = 0.4;
    vignetteFilte.vignetteEnd = 1.3;
    
    
//    //边缘色散
    GpUImageScaleFilter *scaleFilter = [[GpUImageScaleFilter alloc] init];
    scaleFilter.scale = 1.02;

    
    //把多个滤镜对象放到数组中
    NSMutableArray *filterArr = [NSMutableArray array];
    [filterArr addObject:gammaFilter];
    [filterArr addObject:zoomBlurFilter];
    [filterArr addObject:vignetteFilte];
    [filterArr addObject:scaleFilter];
   
    //初始化GPUImagePicture数据源
    GPUImagePicture * imageSource= [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
    
    //创建GPUImageFilterPipeline对象
    //参数1：滤镜数组
    //参数2：被渲染的输入源，可以是GPUImagePicture、GPUImageVideoCamera等
    //参数3：渲染后的输出容器，一般是显示的视图，如：GPUImageView
    GPUImageFilterPipeline *filterPipline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:filterArr input:imageSource output:nil];
    
    //处理图片
    [imageSource processImage];
    [scaleFilter useNextFrameForImageCapture];//必须是最后加入的那个滤镜
    
    //拿到处理后的图片
    UIImage *dealedImage = [filterPipline currentFilteredFrame];
    return dealedImage;
    
}


- (UIImage *)changeValueForSharpenilter:(float)value image:(UIImage *)image
{
    GPUImageSharpenFilter *filter = [[GPUImageSharpenFilter alloc] init];
    filter.sharpness = value;
    [filter forceProcessingAtSize:image.size];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:filter];
    
    [pic processImage];
    [filter useNextFrameForImageCapture];
    return [filter imageFromCurrentFramebuffer];
}
@end

