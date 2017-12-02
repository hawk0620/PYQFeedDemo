//
//  ZPTextLayout.h
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/8/14.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZPTextLayout : NSObject

@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic, readonly) CGSize size;

@property (nonatomic, copy, readonly) NSAttributedString *text;

@property (nonatomic, readonly) CGSize textBoundSize;

@property (nonatomic, copy) NSAttributedString *truncationText;

@property (nonatomic, copy, readonly) NSAttributedString *renderText;

+ (ZPTextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text;

- (instancetype)initWithContainerSize:(CGSize)size text:(NSAttributedString *)text;

- (void)setupContainerSize:(CGSize)size text:(NSAttributedString *)text;

@end
