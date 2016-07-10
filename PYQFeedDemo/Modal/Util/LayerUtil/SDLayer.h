//
//  SDLayer.h
//  UU
//
//  Created by 陈浩 on 16/6/22.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SDLayer : CALayer

@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIImage *highlightImage;

- (instancetype)initWithType:(NSString *)type;
- (void)setContentsWithURLString:(NSString *)urlString;
- (void)highlightedImage;
- (void)unhighlightedImage;
- (BOOL)touchBeginPoint:(CGPoint)point;
- (void)touchCancelPoint;
- (BOOL)touchEndPoint:(CGPoint)point action:(VoidResultBlock)block;
- (void)_clearPendingListObserver;

@end
