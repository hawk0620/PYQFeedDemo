//
//  NSAttributedString+ZPAttributedString.h
//  ZPLabel
//
//  Created by 陈浩 on 2017/12/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZPTextRunDelegate.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^ZPTapHightlightBlock)(NSString *string);

@interface NSAttributedString (ZPAttributedString)

@property (nonatomic, strong, readonly) UIColor *backgroundColor;
@property (nonatomic, strong, readonly) NSMutableArray *highlightRangeArray;
@property (nonatomic, strong, readonly) ZPTapHightlightBlock tapAction;

+ (NSAttributedString *)zp_attachmentWithContent:(nullable id)content
                                     contentMode:(UIViewContentMode)contentMode
                                  attachmentSize:(CGSize)attachmentSize
                                     alignToFont:(UIFont *)font
                                       alignment:(ZPTextVerticalAlignment)alignment;

- (NSAttributedString *)zp_joinWithTruncationText:(NSAttributedString *)truncationText textRect:(CGRect)textRect maximumNumberOfRows:(NSInteger)maximumNumberOfRows;

@end

@interface NSMutableAttributedString (ZPAttributedString)

- (void)zp_highlightColor:(UIColor *)highlightColor backgroundColor:(UIColor *)backgroundColor highlightRange:(NSRange)highlightRange tapAction:(ZPTapHightlightBlock)tapAction;

@end

NS_ASSUME_NONNULL_END
