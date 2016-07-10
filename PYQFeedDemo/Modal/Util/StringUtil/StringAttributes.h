//
//  StringAttributes.h
//  UU
//
//  Created by 陈浩 on 16/6/9.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringAttributes : NSObject

+ (NSMutableDictionary *)attributeFont:(UIFont *)font andTextColor:(UIColor *)color lineBreakMode:(CTLineBreakMode)lineBreakMode;

@end
