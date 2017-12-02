//
//  ZPMeasurement.m
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/8/28.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "ZPTextMeasurement.h"
#import <CoreText/CoreText.h>

@implementation ZPTextMeasurement

+ (CGSize)calculateSizeWithString:(NSAttributedString *)string
                            width:(CGFloat)width
                  useDefaultWidth:(BOOL)useDefaultWidth {
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)string;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [string length]), NULL, CGSizeMake(width, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    
    CGSize finalResult = CGSizeMake(useDefaultWidth ? width : ceil(result.width), ceil(result.height));
    return finalResult;
}

+ (CGRect)textRectWithAttributeString:(NSAttributedString *)attributeString maximumNumberOfRows:(NSInteger)maximumNumberOfRows bounds:(CGRect)bounds {
    CGFloat textHeight = 0;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bounds);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributeString length]), path, NULL);
    
    //获得显示行数的高度
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CFIndex count = CFArrayGetCount(lines);
    
    //根据numberOfLines显示的行数判断，如果等于0，就默认suggestSize
    if (maximumNumberOfRows > 0) {
        if (count == 0) {
            CFRelease(framesetter);
            CFRelease(textFrame);
            CFRelease(path);
            return bounds;
        }
        //判断numberOfLines和默认计算出来的行数的最小值，作为可以显示的行数
        NSInteger linenum = MIN(maximumNumberOfRows, count);
        CTLineRef line = CFArrayGetValueAtIndex(lines, linenum - 1);
        CFRange lastLineRange = CTLineGetStringRange(line);
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        NSMutableAttributedString *maxAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        
        CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)maxAttributedString);
        CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, maxAttributedString.length), NULL, CGSizeMake(ceil(CGRectGetWidth(bounds)), CGFLOAT_MAX), NULL);
        
        textHeight = MIN(ceil(suggestSize.height), ceil(CGRectGetHeight(bounds)));
        
        CFRelease(framesetterRef);
    } else {
        CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attributeString.length), NULL, CGSizeMake(ceil(CGRectGetWidth(bounds)), CGFLOAT_MAX), NULL);
        
        textHeight = MIN(ceil(suggestSize.height), ceil(CGRectGetHeight(bounds)));
    }
    CFRelease(framesetter);
    CFRelease(textFrame);
    CFRelease(path);
    
    return CGRectMake(0, (CGRectGetHeight(bounds) - textHeight)/2, CGRectGetWidth(bounds), textHeight);
}

@end
