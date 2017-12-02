//
//  ZPTextRunDelegate.h
//  Pods
//
//  Created by gzHawk on 2017/9/12.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ZPTextVerticalAlignmentTop = 0,
    ZPTextVerticalAlignmentCenter = 1,
    ZPTextVerticalAlignmentBottom = 2,
} ZPTextVerticalAlignment;

@interface ZPTextRunDelegate : NSObject

@property (nonatomic) CGFloat ascent;
@property (nonatomic) CGFloat descent;
@property (nonatomic) CGFloat width;
@property (nonatomic) UIViewContentMode contentMode;
@property (nonatomic) ZPTextVerticalAlignment verticalAlignment;

@property (nonatomic, strong) id attachmentContent;

@end

