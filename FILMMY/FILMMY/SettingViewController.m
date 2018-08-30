//
//  SettingViewController.m
//  FILMMY
//
//  Created by 张云翥 on 2018/8/20.
//  Copyright © 2018年 张云翥. All rights reserved.
//

#import "SettingViewController.h"
#import "SGBlockActionSheet.h"
#define APPID @"com.topus.FILMMY"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)closeSetting:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearMemory:(UIButton *)sender {
    [[[SGBlockActionSheet alloc] initWithTitle:@"确定要删除所有缓存照片吗" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self deleteAllSandBoxFile];
            
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitlesArray:nil] showInView:self.view];

}
-(void)deleteAllSandBoxFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *document=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *folder =[document stringByAppendingPathComponent:@"folder"];
    
    NSArray *fileList ;
    
    fileList =[fileManager contentsOfDirectoryAtPath:folder error:NULL];
    
    for (NSString *file in fileList) {
        
        NSLog(@"删除文件=>%@",file);
        
        NSString *path =[folder stringByAppendingPathComponent:file];
        
        NSLog(@"删除的路径=%@",path);
        [fileManager removeItemAtPath:path error:nil];
    }
}
- (IBAction)gotoAppstore:(UIButton *)sender {
    //1.itms-apps:// 开头
    NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APPID];
    
    //打开链接地址
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

@end
