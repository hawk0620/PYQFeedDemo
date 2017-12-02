//
//  ZPTextLayout.m
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/8/14.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "ZPTextLayout.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+ZPAttributedString.h"
#import "ZPTextMeasurement.h"

@interface ZPTextLayout ()

@property (nonatomic) CGSize size;

@property (nonatomic, copy) NSAttributedString *text;
@property (nonatomic, copy) NSAttributedString *renderText;

@end

@implementation ZPTextLayout

+ (ZPTextLayout *)layoutWithContainerSize:(CGSize)size text:(NSAttributedString *)text {
    return [[self alloc] initWithContainerSize:size text:text];
}

- (instancetype)initWithContainerSize:(CGSize)size text:(NSAttributedString *)text {
    if (self = [super init]) {
        _size = size;
        _text = text;
    }
    return self;
}

- (void)setupContainerSize:(CGSize)size text:(NSAttributedString *)text {
    self.size = size;
    self.text = text;
}

- (CGSize)textBoundSize {
    if (self.text && self.text.length > 0) {
        
        self.renderText = [self.text zp_joinWithTruncationText:self.truncationText textRect:(CGRect){0, 0, self.size} maximumNumberOfRows:self.numberOfLines];
        
        CGRect rect = [ZPTextMeasurement textRectWithAttributeString:self.renderText maximumNumberOfRows:self.numberOfLines bounds:(CGRect){0, 0, self.size}];
        return rect.size;
    } else {
        return CGSizeMake(0, 0);
    }
    
}

- (NSInteger)numberOfLines {
    if (_numberOfLines < 0) {
        return 0;
    }
    return _numberOfLines;
}

@end
