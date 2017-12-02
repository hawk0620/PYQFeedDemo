//
//  ContentString.h
//  UU
//
//  Created by luoo on 16/6/15.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZPTextDrawer : NSObject

@property (nonatomic, strong) NSMutableArray *ranges;
@property (nonatomic, strong) NSMutableDictionary *framesDict;
@property (nonatomic, strong) NSMutableDictionary *relationDict;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *attachmentContentArray;

- (void)setText:(NSAttributedString *)attributedStr
        context:(CGContextRef)context
    contentSize:(CGSize)size
           font:(UIFont *)font
maximumNumberOfRows:(NSInteger)maximumNumberOfRows
     renderText:(NSAttributedString *)renderText
 truncationText:(NSAttributedString *)truncationText;

@end
