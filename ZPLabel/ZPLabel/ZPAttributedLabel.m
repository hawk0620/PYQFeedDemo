//
//  ZPLabel.m
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/7/31.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "ZPAttributedLabel.h"
#import <CoreText/CoreText.h>
#import "ZPLabelLayer.h"
#import "ZPTextDrawer.h"
#import "NSAttributedString+ZPAttributedString.h"
#import "ZPTextMeasurement.h"

@interface ZPAttributedLabel ()

@property (nonatomic) CGPoint startLocation;
@property (nonatomic, copy) NSString *linkString;
@property(nullable, nonatomic, strong) NSMutableAttributedString *privateAttributedText;

@end

@implementation ZPAttributedLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textAttributes = [NSMutableDictionary dictionary];
        
        _lineBreakMode = NSLineBreakByWordWrapping;
        _textColor = [UIColor blackColor];
        _font = [UIFont systemFontOfSize:17];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

+ (Class)layerClass {
    return [ZPLabelLayer class];
}

- (void)setText:(NSString *)text {
    _text = text;
    
    self.attributedText = nil;
    self.privateAttributedText = nil;
    
    [self.layer setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if ([attributedText isKindOfClass:[NSMutableAttributedString class]]) {
        self.privateAttributedText = (NSMutableAttributedString *)attributedText;
    } else {
        self.privateAttributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    }
    
    [self.layer setNeedsDisplay];
}

- (NSAttributedString *)attributedText {
    return self.privateAttributedText;
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (self.privateAttributedText && self.privateAttributedText.length > 0) {
        [self.privateAttributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, self.privateAttributedText.length)];
    }
    
    self.textAttributes[NSFontAttributeName] = font;
    [self.layer setNeedsDisplay];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:lineBreakMode];
    
    if (self.privateAttributedText && self.privateAttributedText.length > 0) {
        [self.privateAttributedText enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, self.privateAttributedText.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if (!value) {
                [self.privateAttributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.privateAttributedText.length)];
            } else {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                [paragraphStyle setParagraphStyle:value];
                [paragraphStyle setLineBreakMode:lineBreakMode];
                
                [self.privateAttributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
            }
        }];
    }
    
    self.textAttributes[NSParagraphStyleAttributeName] = paragraphStyle;
    [self.layer setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (self.privateAttributedText && self.privateAttributedText.length > 0) {
        [self.privateAttributedText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, self.privateAttributedText.length)];
    }
    
    self.textAttributes[NSForegroundColorAttributeName] = textColor;
    [self.layer setNeedsDisplay];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    _numberOfLines = numberOfLines;
    
    if (numberOfLines > 0) {
        ZPTextLayout *layout = [ZPTextLayout new];
        layout.numberOfLines = numberOfLines;
        self.layout = layout;
    }
}

- (void)sizeToFit {
    NSAttributedString *attributedText;
    if (self.attributedText) {
        attributedText = self.attributedText;
    } else {
        attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:self.textAttributes];
    }
    
    CGRect tempRect = self.frame;
    
    if (self.layout) {
        [self.layout setupContainerSize:(CGSize){self.bounds.size.width, CGFLOAT_MAX} text:attributedText];
        self.layout.truncationText = self.truncationText;
        self.frame = (CGRect){tempRect.origin, self.layout.textBoundSize};
        
    } else {
        CGSize size = [ZPTextMeasurement calculateSizeWithString:attributedText width:CGFLOAT_MAX useDefaultWidth:NO];
        self.frame = (CGRect){tempRect.origin, size};
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.startLocation = [[touches anyObject] locationInView:self];
    ZPLabelLayer *zp_layer = (ZPLabelLayer *)self.layer;
    
    for (NSDictionary *attachmentInfo in zp_layer.drawer.attachmentContentArray) {
        CGRect rect = CGRectFromString(attachmentInfo[@"rect"]);
        if (CGRectContainsPoint(rect, self.startLocation)) {
            [self.nextResponder touchesBegan:touches withEvent:event];
            return;
        }
    }
    
    for (NSString *key in zp_layer.drawer.framesDict) {
        
        CGRect frame = [[zp_layer.drawer.framesDict valueForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, self.startLocation)) {
            NSRange tapRange = NSRangeFromString(key);
            
            for (NSString *rangeString in zp_layer.drawer.ranges) {
                NSRange myRange = NSRangeFromString(rangeString);
                if (NSLocationInRange(tapRange.location, myRange)) {
                    NSArray *rects = zp_layer.drawer.relationDict[rangeString];
                    NSString *text = self.text ?: self.privateAttributedText.string;
                    self.linkString = [text substringWithRange:myRange];
                    [zp_layer fillContents:rects];
                    
                    return;
                }
            }
        }
    }
    
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ZPLabelLayer *zp_layer = (ZPLabelLayer *)self.layer;
    
    self.linkString = nil;
    [zp_layer fillContents:nil];
    
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    CGPoint location = [[touches anyObject] locationInView:self];
    ZPLabelLayer *zp_layer = (ZPLabelLayer *)self.layer;
    
    if (self.linkString) {
        self.privateAttributedText.tapAction(self.linkString);
    }
    
    [zp_layer fillContents:nil];
    self.linkString = nil;
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end
