//
//  SGPhotoBrowserViewController.m
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "SGPhotoBrowser.h"
#import "SGPhotoCollectionView.h"
#import "SGPhotoModel.h"
#import "SGPhotoCell.h"
#import "SGPhotoViewController.h"
#import "SGBrowserToolBar.h"
#import "SDWebImageManager.h"
#import "SGUIKit.h"
#import "SDWebImagePrefetcher.h"
#import "MBProgressHUD+SGExtension.h"
#import "UIImageView+SGExtension.h"

@interface SGPhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    CGFloat _margin, _gutter;
}

@property (nonatomic, weak) SGPhotoCollectionView *collectionView;
@property (nonatomic, assign) CGSize photoSize;
@property (nonatomic, weak) SGBrowserToolBar *toolBar;
@property (nonatomic, strong) NSMutableArray *selectModels;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@end

@implementation SGPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    SGPhotoCollectionView *collectionView = [[SGPhotoCollectionView alloc] initWithFrame:[self getCollectionViewFrame] collectionViewLayout:layout];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}




- (void)initParams {
    _margin = 5;
    _gutter = 3;
    self.numberOfPhotosPerRow = 4;
    [SDWebImagePrefetcher sharedImagePrefetcher].maxConcurrentDownloads = 6;
    self.currentOrientation = UIInterfaceOrientationUnknown;
}

- (void)setupViews {
    SGBrowserToolBar *toolBar = [[SGBrowserToolBar alloc] initWithFrame:[self getToobarFrame]];
    self.toolBar = toolBar;
    [self layoutViews];
    [self.view addSubview:toolBar];
    __weak typeof(toolBar) weakToolBar = self.toolBar;
    [toolBar.mainToolBar setButtonActionHandlerBlock:^(UIBarButtonItem *item) {
        switch (item.tag) {
            case SGBrowserToolButtonEdit:
                weakToolBar.isEditing = YES;
                break;
        }
    }];
    sg_ws();
    [toolBar.secondToolBar setButtonActionHandlerBlock:^(UIBarButtonItem *item) {
        switch (item.tag) {
            case SGBrowserToolButtonBack: {
                weakToolBar.isEditing = NO;
                for (NSUInteger i = 0; i < weakSelf.selectModels.count; i++) {
                    SGPhotoModel *model = weakSelf.selectModels[i];
                    model.isSelected = NO;
                    [weakSelf reloadData];
                }
                break;
            }
            case SGBrowserToolButtonAction: {
                [[[SGBlockActionSheet alloc] initWithTitle:@"Save To Where" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                    switch (buttonIndex) {
                        case 1:
                            [weakSelf handleBatchSave];
                            break;
                    }
                } cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitlesArray:@[@"Photo Library"]] showInView:self.view];
                break;
            }
            case SGBrowserToolButtonTrash: {
                [[[SGBlockActionSheet alloc] initWithTitle:@"Please Confirm Delete" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        [weakSelf handleBatchDelete];
                    }
                } cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitlesArray:nil] showInView:self.view];
                break;
            }
        }
    }];
}

#pragma mark - Layout
- (CGRect)getCollectionViewFrame {
    return CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44);
}

- (CGRect)getToobarFrame {
    CGFloat barW = self.view.bounds.size.width;
    CGFloat barH = 44;
    CGFloat barX = 0;
    CGFloat barY = self.view.bounds.size.height - barH;
    return CGRectMake(barX, barY, barW, barH);
}

- (void)layoutViewsIfNeeded {
    if (self.currentOrientation != [UIApplication sharedApplication].statusBarOrientation) {
        self.currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [self layoutViews];
    }
}

- (void)layoutViews {
    self.collectionView.frame = [self getCollectionViewFrame];
    self.toolBar.frame = [self getToobarFrame];
    [self.collectionView reloadData];
}

- (void)handleBatchSave {
    NSInteger count = self.selectModels.count;
    if (count == 0) {
        [MBProgressHUD showError:@"Select Images Before Save"];
        return;
    }
    __block NSInteger currentCount = 0;
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    NSBlockOperation *lastOp = nil;
    NSMutableArray<NSBlockOperation *> *ops = @[].mutableCopy;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = [NSString stringWithFormat:@"Saving %@/%@",@(currentCount),@(count)];
    [hud showAnimated:YES];
    [self.navigationController.view addSubview:hud];
    void (^opCompletionBlock)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            currentCount++;
            hud.progress = (double)currentCount / count;
            hud.label.text = [NSString stringWithFormat:@"Saving %@/%@",@(currentCount),@(count)];
            if (currentCount == count) {
                [hud hideAnimated:YES afterDelay:0.25f];
            }
        });
    };
    for (NSUInteger i = 0; i < count; i++) {
        SGPhotoModel *model = self.selectModels[i];
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            __block BOOL finish = NO;
            NSURL *url = model.photoURL;
            if (![url isFileURL]) {
                [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageDownloaderHighPriority|SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                        opCompletionBlock();
                        finish = YES;
                    }];
                }];
            } else {
                UIImage *image = [UIImage imageWithContentsOfFile:url.path];
                [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    opCompletionBlock();
                    finish = YES;
                }];
            }
            while (!finish);
        }];
        if (lastOp != nil) {
            [op addDependency:lastOp];
        }
        lastOp = op;
        [ops addObject:op];
    }
    NSOperationQueue *queue = [NSOperationQueue new];
    for (NSUInteger i = 0; i < ops.count; i++) {
        [queue addOperation:ops[i]];
    }
}

- (void)handleBatchDelete {
    NSInteger count = self.selectModels.count;
    if (count == 0) {
        [MBProgressHUD showError:@"Select Images Before Delete"];
        return;
    }
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < count; i++) {
        SGPhotoModel *model = self.selectModels[i];
        
        NSLog(@"删除了%@附加%@",model.photoURL,model.thumbURL);
        [self deleteFile:[model.photoURL lastPathComponent]];
        NSLog("%@",[model.photoURL lastPathComponent]);
        
        [SGPhotoBrowser deleteImageWithURL:model.photoURL];
        [SGPhotoBrowser deleteImageWithURL:model.thumbURL];
        
        [indexSet addIndex:model.index];
    }
    if (self.deleteHandler) {
        self.deleteHandler(indexSet);
    }
}

// 删除沙盒里的文件
-(void)deleteFile:(NSString*)fileName {
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *folder = [document stringByAppendingPathComponent:@"folder"];
    
    NSString *uniquePath = [folder stringByAppendingPathComponent:fileName];
    
    //加上文件名
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    
    if (!blHave) {
        
        NSLog(@"no  have");
        
        return ;
        
    }else {
        
        NSLog(@" have");
        
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        
        if (blDele) {
            
            NSLog(@"dele success");
            
        }else {
            
            NSLog(@"dele fail");
            
        }
        
    }
    
}
- (void)checkImplementation {
    if (self.photoAtIndexHandler && self.numberOfPhotosHandler) {
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView reloadData];
    }
}

- (void)setphotoAtIndexHandlerBlock:(SGPhotoBrowserDataSourcePhotoBlock)handler {
    _photoAtIndexHandler = handler;
    [self checkImplementation];
}

- (void)setNumberOfPhotosHandlerBlock:(SGPhotoBrowserDataSourceNumberBlock)handler {
    _numberOfPhotosHandler = handler;
    [self checkImplementation];
}

- (void)setReloadHandlerBlock:(SGPhotoBrowserReloadRequestBlock)handler {
    _reloadHandler = handler;
}

- (void)setDeleteHandlerBlock:(SGPhotoBrowserDeletePhotoAtIndexBlock)handler {
    _deleteHandler = handler;
}

- (void)setNumberOfPhotosPerRow:(NSInteger)numberOfPhotosPerRow {
    _numberOfPhotosPerRow = numberOfPhotosPerRow;
    [self.collectionView setNeedsLayout];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

+ (void)deleteImageWithURL:(NSURL *)url {
    if ([url isFileURL]) {
        [[NSFileManager defaultManager] removeItemAtPath:url.path error:nil];
    } else {
        SDImageCache *cache = [SDImageCache sharedImageCache];
        [cache removeImageForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:url] fromDisk:YES];
    }
}

#pragma mark - Lazyload
- (NSMutableArray *)selectModels {
    if (_selectModels == nil) {
        _selectModels = @[].mutableCopy;
    }
    return _selectModels;
}

#pragma mark - Rotate
- (void)orientationDidChanged {
    if (self.currentOrientation != UIDeviceOrientationUnknown) {
        [self layoutViews];
    }
    self.currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(self.numberOfPhotosHandler != nil, @"you must implement 'numberOfPhotosHandler' block to tell the browser how many photos are here");
    return self.numberOfPhotosHandler();
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(self.photoAtIndexHandler != nil, @"you must implement 'photoAtIndexHandler' block to provide photos for the browser.");
    SGPhotoModel *model = self.photoAtIndexHandler(indexPath.row);
    model.index = indexPath.row;
    SGPhotoCell *cell = [SGPhotoCell cellWithCollectionView:collectionView forIndexPaht:indexPath];
    cell.model = model;
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(_margin, _margin, _margin, _margin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat value = (self.view.bounds.size.width - (self.numberOfPhotosPerRow - 1) * _gutter - 2 * _margin) / self.numberOfPhotosPerRow;
    return CGSizeMake(value, value*1.5);//FIXME: 修改
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return _gutter;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return _gutter;
}

#pragma mark - UICollectionView Delegate (FlowLayout)
// 选中操作
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __FUNCTION__);
    SGPhotoCell *cell = (SGPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.toolBar.isEditing) {
        SGPhotoModel *model = self.photoAtIndexHandler(indexPath.row);
        model.isSelected = !model.isSelected;
        NSLog(@"%d",model.isSelected);
        if (model.isSelected) {
            [self.selectModels addObject:model];
        } else {
            [self.selectModels removeObject:model];
        }
        
        cell.model = model;
        return;
    }
    
    // if the thumb image is downloading, pretend users from look at the origin image.
//    if (cell.imageView.hud) return;
    
    SGPhotoViewController *vc = [SGPhotoViewController new];
    vc.browser = self;
    vc.index = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

// 允许选中时，高亮
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
//    return YES;
//}

// 高亮完成后回调
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
//}
//
//// 由高亮转成非高亮完成时的回调
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
//}
//
//// 取消选中操作
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s", __FUNCTION__);
//}

//// 由高亮转成非高亮完成时的回调
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    SGPhotoCell *cell = (SGPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
//
//
//    if (self.toolBar.isEditing) {
//        SGPhotoModel *model = self.photoAtIndexHandler(indexPath.row);
//        model.isSelected = !model.isSelected;
//        if (model.isSelected) {
//            [self.selectModels addObject:model];
//        } else {
//            [self.selectModels removeObject:model];
//        }
//        cell.model = model;
//        return;
//    }
//    // if the thumb image is downloading, pretend users from look at the origin image.
//    if (cell.imageView.hud) return;
//
//    SGPhotoViewController *vc = [SGPhotoViewController new];
//    vc.browser = self;
//    vc.index = indexPath.row;
//    [self.navigationController pushViewController:vc animated:YES];
//}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    self.collectionView.allowsSelection = NO;
//    NSLog(@"滚动了");
//}

//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSLog(@"要减速了");
//    self.collectionView.allowsSelection = NO;
//}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"停止了");
//    self.collectionView.allowsSelection = YES;
//}


//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"？？？");
//}

//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"开始减速了");
//    self.collectionView.allowsSelection = NO;
//}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
