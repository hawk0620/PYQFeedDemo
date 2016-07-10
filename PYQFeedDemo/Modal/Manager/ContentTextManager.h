//
//  ContentString.h
//  UU
//
//  Created by luoo on 16/6/15.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^contentBlock)(UIImage *image);

@interface ContentTextManager : NSObject

@property (nonatomic, strong) NSMutableArray *ranges;
@property (nonatomic, strong) NSMutableDictionary *framesDict;
@property (nonatomic, strong) NSMutableDictionary *relationDict;

- (void)setText:(NSString *)text
        context:(CGContextRef)context
    contentSize:(CGSize)size
backgroundColor:(UIColor *)backgroundColor
           font:(UIFont *)font
      textColor:(UIColor *)textColor
          block:(contentBlock)block
        xOffset:(CGFloat)x
        yOffset:(CGFloat)y;

@end
