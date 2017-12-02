//
//  ZPLabelLayer.m
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/7/31.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "ZPLabelLayer.h"
#import "ZPTextDrawer.h"
#import "ZPAttributedLabel.h"
#import "NSAttributedString+ZPAttributedString.h"
#import "ZPTextMeasurement.h"
#import "ZPTextRunDelegate.h"

@interface ZPLabelLayer ()

@property (nonatomic, strong) ZPTextDrawer *drawer;

@end

@implementation ZPLabelLayer

- (void)display {
    [super display];
    
    [self fillContents:nil];
}

- (void)fillContents:(NSArray *)array {
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        return;
    }
    
    ZPAttributedLabel *label = (ZPAttributedLabel *)self.delegate;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), self.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.backgroundColor);
    
    if (array) {
        if (label.attributedText.backgroundColor) {
            for (NSString *string in array) {
                CGRect rect = CGRectFromString(string);
                [label.attributedText.backgroundColor set];
                CGContextFillRect(context, rect);
            }
        }
    }
    
    self.drawer = [ZPTextDrawer new];
    
    NSAttributedString *attributedText;
    if (label.attributedText) {
        attributedText = label.attributedText;
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithString:label.text attributes:label.textAttributes];
    }
    
    CGSize containerSize = CGSizeMake(ceil(self.frame.size.width), ceil(self.frame.size.height));
    ZPTextLayout *layout = label.layout;
    NSInteger maximumNumberOfRows = 0;
    if (layout) {
        maximumNumberOfRows = layout.numberOfLines;
    } else {
        containerSize = [ZPTextMeasurement calculateSizeWithString:attributedText width:containerSize.width useDefaultWidth:YES];
    }
    
    [self.drawer setText:attributedText context:context contentSize:containerSize font:label.font maximumNumberOfRows:maximumNumberOfRows renderText:layout.renderText truncationText:label.truncationText];
    
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    
    self.contents = (__bridge id _Nullable)(temp.CGImage);
    //    });
    
    for (UIView *subView in label.subviews) {
        [subView removeFromSuperview];
    }
    
    for (NSDictionary *dictionary in self.drawer.attachmentContentArray) {
        UIView *contentAttachment = (UIView *)dictionary[@"content"];
        CGRect rect = CGRectFromString(dictionary[@"rect"]);
        UIViewContentMode contentMode = [dictionary[@"contentMode"] integerValue];
        
        contentAttachment.frame = rect;
        contentAttachment.contentMode = contentMode;
        [label addSubview:contentAttachment];
        
    }
}

@end

