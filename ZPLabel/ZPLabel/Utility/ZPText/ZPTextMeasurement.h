//
//  ZPMeasurement.h
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/8/28.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZPTextMeasurement : NSObject

+ (CGSize)calculateSizeWithString:(NSAttributedString *)string
                            width:(CGFloat)width
                  useDefaultWidth:(BOOL)useDefaultWidth;

+ (CGRect)textRectWithAttributeString:(NSAttributedString *)attributeString maximumNumberOfRows:(NSInteger)maximumNumberOfRows bounds:(CGRect)bounds;

@end
