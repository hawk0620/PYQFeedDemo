//
//  ZPAttributedLabel.h
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/7/31.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZPTextLayout.h"

@interface ZPAttributedLabel : UIView

@property (nullable, nonatomic, copy) NSString *text;

@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic) NSUInteger numberOfLines;

@property (null_resettable, nonatomic, strong) UIFont *font;

@property (null_resettable, nonatomic, strong) UIColor *textColor;

@property (nullable, nonatomic, copy) NSAttributedString *attributedText;

@property (nullable, nonatomic, copy) NSAttributedString *truncationText;

@property (nonatomic, strong, readonly) NSMutableDictionary * _Nonnull textAttributes;

@property (nonatomic, strong) ZPTextLayout * _Nullable layout;

@end
