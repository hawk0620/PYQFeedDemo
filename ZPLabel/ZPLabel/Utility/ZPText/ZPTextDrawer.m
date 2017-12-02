//
//  ContentString.m
//  UU
//
//  Created by luoo on 16/6/15.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "ZPTextDrawer.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+ZPAttributedString.h"
#import "ZPTextRunDelegate.h"

@interface ZPTextDrawer ()

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;

@property (nullable, nonatomic, strong) NSMutableAttributedString *truncationText;

@end

@implementation ZPTextDrawer

- (instancetype)init {
    if (self = [super init]) {
        _ranges = [NSMutableArray array];
        _framesDict = [NSMutableDictionary dictionary];
        _relationDict = [NSMutableDictionary dictionary];
        _attachmentContentArray = [NSMutableArray array];
    }
    return self;
}

- (void)setText:(NSAttributedString *)attributedStr
        context:(CGContextRef)context
    contentSize:(CGSize)size
           font:(UIFont *)font
maximumNumberOfRows:(NSInteger)maximumNumberOfRows
     renderText:(NSAttributedString *)renderText
 truncationText:(NSAttributedString *)truncationText {
    self.ranges = attributedStr.highlightRangeArray;
    
    if (context == NULL) {
        return;
    }
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = (CGRect){0, 0, size};
    
    NSAttributedString *drawText = renderText ?: [attributedStr zp_joinWithTruncationText:truncationText textRect:rect maximumNumberOfRows:maximumNumberOfRows];
    
    [self drawAttributedString:drawText inRect:rect maximumNumberOfRows:maximumNumberOfRows context:context font:font];
}

- (void)drawAttributedString:(NSAttributedString *)attributedString
                      inRect:(CGRect)rect
         maximumNumberOfRows:(NSInteger)maximumNumberOfRows
                     context:(CGContextRef)context
                        font:(UIFont *)font {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedString.length), path, NULL);
    
    CGFloat ContentHeight = CGRectGetHeight(rect);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    if (maximumNumberOfRows > 0 && maximumNumberOfRows < numberOfLines) {
        numberOfLines = maximumNumberOfRows;
    }
    CGRect cgPathBox = CGRectZero;
    if (path) {
        cgPathBox = CGPathGetPathBoundingBox(path);
    }
    
    // 遍历每一行
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat lineDescent = 0.0f, lineAscent = 0.0f, lineLeading = 0.0f;
        CTLineGetTypographicBounds((CTLineRef)line, &lineAscent, &lineDescent, &lineLeading);
        
        CGRect bounds = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds);
        
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, NSTextAlignmentLeft, rect.size.width);
        // 设置每一行位置
        CGContextSetTextPosition(context, penOffset, lineOrigin.y);
        CTLineDraw(line, context);
        
        // CTRunRef同一行中文本的不同样式，包括颜色、字体等，此处用途为处理链接高亮
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *runAttributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            ZPTextRunDelegate *runDelegate;
            if (delegate) {
                runDelegate = CTRunDelegateGetRefCon(delegate);
                if ([runDelegate isKindOfClass:[ZPTextRunDelegate class]]) {
                    id attachmentContent = runDelegate.attachmentContent;
                    if (attachmentContent) {
                        CGPoint runPosition = CGPointZero;
                        CTRunGetPositions(run, CFRangeMake(0, 1), &runPosition);
                        
                        CGRect runBounds;
                        CGFloat runAscent;
                        CGFloat runDescent;
                        CGFloat runLeading;
                        runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, &runLeading);
                        runBounds.size.height = runDelegate.ascent + runDelegate.descent;
                        
                        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                        runBounds.origin.x = lineOrigin.x + xOffset;
//                        runBounds.origin.y = lineOrigin.y;
//                        runBounds.origin.y -= runDelegate.descent;
                        runBounds.origin.y = bounds.size.height - runLeading - runAscent;
                        
                        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, ContentHeight);
                        transform = CGAffineTransformScale(transform, 1.f, -1.f);
                        CGRect flipRect = CGRectApplyAffineTransform(runBounds, transform);
                        
                        [self.attachmentContentArray addObject:@{@"content": attachmentContent, @"rect": NSStringFromCGRect(flipRect), @"contentMode": @(runDelegate.contentMode)}];
                    }
                }
            }
            
            CFRange range = CTRunGetStringRange(run);
            
            for (NSString *rangeString in self.ranges) {
                
                CGFloat runAscent, runDescent, runLeading;
                
                NSRange hightlightRange = NSRangeFromString(rangeString);
                NSRange lineRange = NSMakeRange(range.location, range.length);
                
                if (NSIntersectionRange(hightlightRange, lineRange).length > 0) {
                    
                    float offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                    
                    // 得到链接的CGRect
                    CGRect runRect;
                    runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, &runLeading);
                    runRect.size.height = font.lineHeight;
                    runRect.origin.x = lineOrigin.x + offset;
                    runRect.origin.y = lineOrigin.y;
                    runRect.origin.y -= ceil(runDescent);
                    
                    // 因为坐标系被翻转，链接正常的坐标需要通过CGAffineTransform计算得到
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, ContentHeight);
                    transform = CGAffineTransformScale(transform, 1.f, -1.f);
                    CGRect flipRect = CGRectApplyAffineTransform(runRect, transform);
                    
                    // 保存是链接的CGRect
                    NSRange nRange = NSMakeRange(range.location, range.length);
                    self.framesDict[NSStringFromRange(nRange)] = [NSValue valueWithCGRect:flipRect];
                    
                    // 保存同一条链接的不同CGRect，用于点击时背景色处理
                    for (NSString *rangeString in self.ranges) {
                        NSRange range = NSRangeFromString(rangeString);
                        if (NSLocationInRange(nRange.location, range)) {
                            NSMutableArray *array = self.relationDict[rangeString];
                            if (array) {
                                [array addObject:NSStringFromCGRect(flipRect)];
                                self.relationDict[rangeString] = array;
                            } else {
                                self.relationDict[rangeString] = [NSMutableArray arrayWithObject:NSStringFromCGRect(flipRect)];
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end

