//
//  ContentString.m
//  UU
//
//  Created by luoo on 16/6/15.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "ContentTextManager.h"
#import "StringAttributes.h"
#import <CoreText/CoreText.h>

@interface ContentTextManager ()

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat xOffset;
@property (nonatomic, assign) CGFloat yOffset;

@end

@implementation ContentTextManager

- (instancetype)init {
    if (self = [super init]) {
        _ranges = [NSMutableArray array];
        _framesDict = [NSMutableDictionary dictionary];
        _relationDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableAttributedString *)highlightText:(NSMutableAttributedString *)coloredString{
    // 创建带高亮的AttributedString
    NSString* string = coloredString.string;
    NSRange range = NSMakeRange(0,[string length]);
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:string options:0 range:range];
    
    for(NSTextCheckingResult* match in matches) {
        [self.ranges addObject:NSStringFromRange(match.range)];
        UIColor *highlightColor = UIColorFromRGB(0x297bc1);
        [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName
                              value:(id)highlightColor.CGColor range:match.range];
    }
    
    return coloredString;
}

- (void)setText:(NSString *)text
        context:(CGContextRef)context
    contentSize:(CGSize)size
backgroundColor:(UIColor *)backgroundColor
           font:(UIFont *)font
      textColor:(UIColor *)textColor
          block:(contentBlock)block
        xOffset:(CGFloat)x
        yOffset:(CGFloat)y {
    NSString *temp = text;
    self.font = font;
    self.textColor = textColor;
    self.xOffset = x;
    self.yOffset = y;
    
    if (context == NULL) {
        return;
    }
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0,size.height);
    CGContextScaleCTM(context,1.0,-1.0);
    
    NSDictionary* attributes = [StringAttributes attributeFont:font andTextColor:textColor lineBreakMode:kCTLineBreakByWordWrapping];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)[self highlightText:attributedStr];
    
    //Draw the frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGRect rect = (CGRect){0,0, size};
    
    if ([temp isEqualToString:text]) {
        [self drawFramesetter:framesetter attributedString:attributedStr textRange:CFRangeMake(0, text.length) inRect:rect context:context];
        CGContextSetTextMatrix(context,CGAffineTransformIdentity);
        CGContextTranslateCTM(context,0,size.height);
        CGContextScaleCTM(context,1.0,-1.0);
    }
}

- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    CGFloat ContentHeight = CGRectGetHeight(rect);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    // 遍历每一行
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat descent = 0.0f, ascent = 0.0f, lineLeading = 0.0f;
        CTLineGetTypographicBounds((CTLineRef)line, &ascent, &descent, &lineLeading);
        
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, NSTextAlignmentLeft, rect.size.width);
        CGFloat y = lineOrigin.y - descent - self.font.descender;
        
        // 设置每一行位置
        CGContextSetTextPosition(c, penOffset + self.xOffset, y - self.yOffset);
        CTLineDraw(line, c);
        
        // CTRunRef同一行中文本的不同样式，包括颜色、字体等，此处用途为处理链接高亮
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent, runDescent, lineLeading1;
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            // 判断是不是链接
            if (!CGColorEqualToColor((__bridge CGColorRef)([attributes valueForKey:@"CTForegroundColor"]), self.textColor.CGColor)) {
                CFRange range = CTRunGetStringRange(run);
                float offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
                
                // 得到链接的CGRect
                CGRect runRect;
                runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, &lineLeading1);
                runRect.size.height = self.font.lineHeight;
                runRect.origin.x = lineOrigin.x + offset+ self.xOffset;
                runRect.origin.y = lineOrigin.y;
                runRect.origin.y -= descent + self.yOffset;
                
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
    
    CFRelease(frame);
    CFRelease(path);
}

@end
