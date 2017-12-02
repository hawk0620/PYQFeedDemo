//
//  ZPLabelLayer.h
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/7/31.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@class ZPTextDrawer;

@interface ZPLabelLayer : CALayer

@property (nonatomic, strong, readonly) ZPTextDrawer *drawer;

- (void)fillContents:(NSArray *)array;

@end
