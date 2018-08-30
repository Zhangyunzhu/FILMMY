//
//  ViewController.m
//  相册部分
//
//  Created by 张云翥 on 2018/8/13.
//  Copyright © 2018年 张云翥. All rights reserved.
//

#import "PhotoAlbumViewController.h"

@interface PhotoAlbumViewController ()

@property (nonatomic, strong) NSMutableArray<SGPhotoModel *> *photoModels;

@end

@implementation PhotoAlbumViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self loadData];
    [self setupBrowser];
    
    
    
}


- (void)setupBrowser {
    UIBarButtonItem *leftCloseBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"关闭"] style:UIBarButtonItemStylePlain target:self action:@selector(closePhotoAlbum)];
    
    self.navigationItem.rightBarButtonItems = @[leftCloseBarButtonItem];
    
    
    self.numberOfPhotosPerRow = 2;
    self.title = @"FILMMY";
    sg_ws();
    [self setNumberOfPhotosHandlerBlock:^NSInteger{
        return weakSelf.photoModels.count;
    }];
    [self setphotoAtIndexHandlerBlock:^SGPhotoModel *(NSInteger index) {
        return weakSelf.photoModels[index];
    }];
    [self setReloadHandlerBlock:^{
        // add reload data code here
    }];
    [self setDeleteHandlerBlock:^(NSIndexSet *indexSet) {
        [weakSelf.photoModels removeObjectsAtIndexes:indexSet];
        [weakSelf reloadData];
    }];
}

-(void)closePhotoAlbum{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)loadData {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSMutableArray *photoModels = @[].mutableCopy;
//
//
//        // local images
//        for (NSUInteger i = 1; i <= 8; i++) {
//            NSURL *photoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"photo%@",@(i)] ofType:@"jpg"]];
//            //            NSURL *thumbURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"photo%@t",@(i)] ofType:@"jpg"]];
//            SGPhotoModel *model = [SGPhotoModel new];
//            model.photoURL = photoURL;
//            model.thumbURL = photoURL;
//            [photoModels insertObject:model atIndex:0];
//        }
//
//
//
//        self.photoModels = photoModels;
//        [self reloadData];
//    });
//}

- (void)loadData {
    
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        NSMutableArray *photoModels = @[].mutableCopy;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *document=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *folder =[document stringByAppendingPathComponent:@"folder"];
        
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:folder error:NULL];/*取得文件列表*/
        
        
        NSArray *sortedPaths = [fileList sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath) {
            
            NSString *firstUrl = [folder stringByAppendingPathComponent:firstPath];/*获取前一个文件完整路径*/
            
            NSString *secondUrl = [folder stringByAppendingPathComponent:secondPath];/*获取后一个文件完整路径*/
            
            NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];/*获取前一个文件信息*/
            
            NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondUrl error:nil];/*获取后一个文件信息*/
            
            id firstData = [firstFileInfo objectForKey:NSFileCreationDate];/*获取前一个文件创建时间*/
            
            id secondData = [secondFileInfo objectForKey:NSFileCreationDate];/*获取后一个文件创建时间*/
            
            return [firstData compare:secondData];//升序
            
            //                 return [secondData compare:firstData];//降序
            
        }];
        
        
        
        for (NSString *file in sortedPaths) {
            
            NSLog(@"file=%@",file);
            
            NSString *path =[folder stringByAppendingPathComponent:file];
            NSLog(@"显示%@",path);
            NSURL *photoURL = [NSURL fileURLWithPath:path];
            
            
            SGPhotoModel *model = [SGPhotoModel new];
            model.photoURL = photoURL;
            model.thumbURL = photoURL;
            [photoModels insertObject:model atIndex:0];
            //            [photoModels addObject:model];
        }
        
        
        
        
        self.photoModels = photoModels;
        [self reloadData];
//    });
}



//-(void)getAllSandBoxImage{
//    //得到沙盒文件夹 下的所有文件
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    NSString *document=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//
//    NSString *folder =[document stringByAppendingPathComponent:@"folder"];
//
//    NSArray *fileList ;
//
//    fileList =[fileManager contentsOfDirectoryAtPath:folder error:NULL];
//
//    for (NSString *file in fileList) {
//
//        NSLog(@"file=%@",file);
//
//        NSString *path =[folder stringByAppendingPathComponent:file];
//
//        NSLog(@"得到的路径=%@",path);
//
//        UIImage *imagepre = [[UIImage alloc]initWithContentsOfFile:path];
//
//        UIImageView *imageview = [[UIImageView alloc]initWithImage:imagepre];
//        imageview.frame = CGRectMake(0, 100, 100, 100);
//        [self.view addSubview:imageview];
//    }
//
//}

////得到按照创建顺序排序下的所有文件
//-(void)makeFileCreationDate{
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    NSString *document=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//
//    NSString *folder =[document stringByAppendingPathComponent:@"folder"];
//
//    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:folder error:NULL];/*取得文件列表*/
//
//
//    NSArray *sortedPaths = [fileList sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath) {
//
//        NSString *firstUrl = [folder stringByAppendingPathComponent:firstPath];/*获取前一个文件完整路径*/
//
//        NSString *secondUrl = [folder stringByAppendingPathComponent:secondPath];/*获取后一个文件完整路径*/
//
//        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstUrl error:nil];/*获取前一个文件信息*/
//
//        NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondUrl error:nil];/*获取后一个文件信息*/
//
//        id firstData = [firstFileInfo objectForKey:NSFileCreationDate];/*获取前一个文件创建时间*/
//
//        id secondData = [secondFileInfo objectForKey:NSFileCreationDate];/*获取后一个文件创建时间*/
//
//        return [firstData compare:secondData];//升序
//
//        // return [secondData compare:firstData];//降序
//
//    }];
//
//
//    for (NSString *file in sortedPaths) {
//
//        NSLog(@"file=%@",file);
//
//        NSString *path =[folder stringByAppendingPathComponent:file];
//
//        NSLog(@"得到的路径=%@",path);
//
//        UIImage *imagepre = [[UIImage alloc]initWithContentsOfFile:path];
//
//        UIImageView *imageview = [[UIImageView alloc]initWithImage:imagepre];
//        imageview.frame = CGRectMake(0, 100, 100, 100);
//        [self.view addSubview:imageview];
//
//    }
//}


@end
