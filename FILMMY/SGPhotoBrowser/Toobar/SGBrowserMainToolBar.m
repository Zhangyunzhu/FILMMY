//
//  SGBrowserMainToolBar.m
//  SGSecurityAlbum
//
//  Created by soulghost on 13/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGBrowserMainToolBar.h"

@implementation SGBrowserMainToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.translucent = YES;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UIBarButtonItem *editBtn = [self createBarButtomItemWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SGPhotoBrowser.bundle/EditButton@2x.png" ofType:nil]]];
    editBtn.tag = SGBrowserToolButtonEdit;
    self.items = @[editBtn,[self createSpring]];
}

@end
