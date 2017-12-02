//
//  NSAttributedString+ZPAttributedString.m
//  ZPLabel
//
//  Created by 陈浩 on 2017/12/2.
//

#import "NSAttributedString+ZPAttributedString.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import "ZPTextRunDelegate.h"

//static void * const kZPHighlightColorKey = (void*)&kZPHighlightColorKey;
static void * const kZPBackgroundColorKey = (void*)&kZPBackgroundColorKey;
static void * const kZPHighlightRangeKey = (void*)&kZPHighlightRangeKey;
static void * const kZPTapActionKey = (void*)&kZPTapActionKey;

static void zp_deallocCallback(void *ref) {
    ZPTextRunDelegate *delegate = (__bridge_transfer ZPTextRunDelegate *)(ref);
    delegate = nil;
}

static CGFloat zp_ascentCallback(void *ref) {
    ZPTextRunDelegate *delegate = (__bridge ZPTextRunDelegate *)(ref);
    return delegate.ascent;
}

static CGFloat zp_descentCallback(void *ref) {
    ZPTextRunDelegate *delegate = (__bridge ZPTextRunDelegate *)(ref);
    return delegate.descent;
}

static CGFloat zp_widthCallback(void *ref) {
    ZPTextRunDelegate *delegate = (__bridge ZPTextRunDelegate *)(ref);
    return delegate.width;
}

@implementation NSAttributedString (ZPAttributedString)

- (UIColor *)backgroundColor {
    return objc_getAssociatedObject(self, kZPBackgroundColorKey);
}

- (NSMutableArray *)highlightRangeArray {
    NSMutableArray *rangeArray = objc_getAssociatedObject(self, kZPHighlightRangeKey);
    return rangeArray;
}

- (ZPTapHightlightBlock)tapAction {
    return objc_getAssociatedObject(self, kZPTapActionKey);
}

+ (NSAttributedString *)zp_attachmentWithContent:(nullable id)content
                                     contentMode:(UIViewContentMode)contentMode
                                  attachmentSize:(CGSize)attachmentSize
                                     alignToFont:(UIFont *)font
                                       alignment:(ZPTextVerticalAlignment)alignment {
    if (!content) {
        return nil;
    }
    
    ZPTextRunDelegate *delegate = [[ZPTextRunDelegate alloc] init];
    delegate.attachmentContent = content;
    delegate.contentMode = contentMode;
    delegate.width = attachmentSize.width;
    delegate.verticalAlignment = alignment;
    
    switch (alignment) {
        case ZPTextVerticalAlignmentTop:
        {
            delegate.ascent = font.ascender;
            delegate.descent = attachmentSize.height - font.ascender;
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        }
            break;
        case ZPTextVerticalAlignmentCenter:
        {
            CGFloat fontHeight = font.ascender - font.descender;
            CGFloat yOffset = font.ascender - fontHeight * 0.5;
            delegate.ascent = attachmentSize.height * 0.5 + yOffset;
            delegate.descent = attachmentSize.height - delegate.ascent;
            
            if (delegate.descent < 0) {
                delegate.descent = 0;
                delegate.ascent = attachmentSize.height;
            }
        }
            break;
        case ZPTextVerticalAlignmentBottom:
        {
            delegate.ascent = attachmentSize.height + font.descender;
            delegate.descent = -font.descender;
            if (delegate.ascent < 0) {
                delegate.ascent = 0;
                delegate.descent = attachmentSize.height;
            }
        }
            break;
        default:
        {
            delegate.ascent = attachmentSize.height;
            delegate.descent = 0;
        }
            break;
    }
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = zp_deallocCallback;
    callbacks.getAscent = zp_ascentCallback;
    callbacks.getDescent = zp_descentCallback;
    callbacks.getWidth = zp_widthCallback;
    
    CTRunDelegateRef delegateRef = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(delegate));
    
    NSMutableAttributedString *spaceString = [[NSMutableAttributedString alloc] initWithString:@"\uFFFC"];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)spaceString, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegateRef);
    CFRelease(delegateRef);
    
    return spaceString;
}

- (NSAttributedString *)zp_joinWithTruncationText:(NSAttributedString *)truncationText textRect:(CGRect)textRect maximumNumberOfRows:(NSInteger)maximumNumberOfRows {
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self length]), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    if (maximumNumberOfRows <= 0) {
        maximumNumberOfRows = numberOfLines;
    }
    
    if (numberOfLines > maximumNumberOfRows) {
        numberOfLines = maximumNumberOfRows;
        
        NSInteger lastLineIndex = numberOfLines - 1 < 0 ? 0 : numberOfLines - 1;
        CTLineRef line = CFArrayGetValueAtIndex(lines, lastLineIndex);
        CFRange lastLineRange = CTLineGetStringRange(line);
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        NSMutableAttributedString *cutAttributedString = [[self attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        
        NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        
        
        if (!truncationText) {
            CFArrayRef runs = CTLineGetGlyphRuns(line);
            CTRunRef run = CFArrayGetValueAtIndex(runs, CFArrayGetCount(runs) - 1);
            NSDictionary *attributes = (__bridge NSDictionary*)CTRunGetAttributes(run);
            NSString *kEllipsesCharacter = @"\u2026";
            truncationText = [[NSAttributedString alloc] initWithString:kEllipsesCharacter attributes:attributes];
        }
        
        [lastLineAttributeString appendAttributedString:truncationText];
        
        NSAttributedString *cutLastLineAttributeString = [self cutLastLineAttributeString:lastLineAttributeString withTruncationText:truncationText width:CGRectGetWidth(textRect)];
        
        cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
        [cutAttributedString appendAttributedString:cutLastLineAttributeString];
        
        CFRelease(path);
        CFRelease(frame);
        CFRelease(framesetter);
        
        return cutAttributedString;
    } else {
        return self;
    }
}

- (NSAttributedString *)cutLastLineAttributeString:(NSMutableAttributedString *)attributeString withTruncationText:(NSAttributedString *)truncationText width:(CGFloat)width {
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(truncationToken, nil, nil,nil);
    CFRelease(truncationToken);
    
    if (lastLineWidth > width) {
        NSString *lastLineString = attributeString.string;
        
        NSRange r = [lastLineString rangeOfComposedCharacterSequencesForRange:NSMakeRange(lastLineString.length - truncationText.string.length - 1, 1)];
        
        [attributeString deleteCharactersInRange:r];
        
        return [self cutLastLineAttributeString:attributeString withTruncationText:truncationText width:width];
    } else {
        return attributeString;
    }
}

@end

@implementation NSMutableAttributedString (ZPAttributedString)

- (void)zp_highlightColor:(UIColor *)highlightColor backgroundColor:(UIColor *)backgroundColor highlightRange:(NSRange)highlightRange tapAction:(ZPTapHightlightBlock)tapAction {
    
    objc_setAssociatedObject(self, kZPBackgroundColorKey, backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, kZPTapActionKey, tapAction, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSMutableArray *storeRangeArray = objc_getAssociatedObject(self, kZPHighlightRangeKey);
    NSString *rangeString = NSStringFromRange(highlightRange);
    
    if (storeRangeArray && storeRangeArray.count > 0) {
        [storeRangeArray addObject:rangeString];
        objc_setAssociatedObject(self, kZPHighlightRangeKey, storeRangeArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        
        NSMutableArray *rangeArray = [NSMutableArray arrayWithObject:rangeString];
        objc_setAssociatedObject(self, kZPHighlightRangeKey, rangeArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    
    [self addAttribute:(NSString*)kCTForegroundColorAttributeName
                 value:(id)highlightColor.CGColor range:highlightRange];
}

@end
