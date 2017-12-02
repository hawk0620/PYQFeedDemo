//
//  BaseFeedCell.m
//  PYQFeedDemo
//
//  Created by 陈浩 on 2017/8/26.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "BaseFeedCell.h"
#import "SDLayer.h"
#import "VideoDownloadManager.h"
#import "ZPFileManager.h"
#import "VideoPlayerManager.h"
#import "ZPAttributedLabel.h"
#import "NSAttributedString+ZPAttributedString.h"

@interface BaseFeedCell ()

@property (nonatomic, weak) SDLayer *headImgLayer;

@property (nonatomic, assign) CGRect nicknameRect;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *contentString;

@property (nonatomic, strong) CALayer *separatorLayer;

@property (nonatomic, strong) ZPAttributedLabel *nameLabel;
@property (nonatomic, strong) ZPAttributedLabel *contentLabel;

@end

@implementation BaseFeedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CALayer *separatorLayer = [[CALayer alloc] init];
        separatorLayer.backgroundColor = UIColorFromRGB(0xe6e6e6).CGColor;
        [self.contentView.layer addSublayer:separatorLayer];
        _separatorLayer = separatorLayer;
        
        _nameLabel = [[ZPAttributedLabel alloc] initWithFrame:(CGRect){0, 0, 0, 0}];
        _nameLabel.font = kNicknameFont;
        _nameLabel.textColor = UIColorFromRGB(0x556c95);
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_nameLabel];
        
        _contentLabel = [[ZPAttributedLabel alloc] initWithFrame:(CGRect){0, 0, 0, 0}];
        _contentLabel.font = kContentTextFont;
        _contentLabel.textColor = [UIColor blackColor];
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self.contentView addSubview:_contentLabel];
        
    }
    return self;
}

- (void)configWithData:(NSDictionary *)data {
    self.sources = [NSMutableArray array];
    
    self.nickname = data[@"nickname"];
    self.contentString = data[@"content"];
    
    self.nameLabel.text = self.nickname;
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = (CGRect){{kTextXOffset, kSpec}, self.nameLabel.frame.size};
    
    self.resourcesSize = [BaseFeedCell resourcesHeight:data[@"resources"]];
    
    SDLayer *headImgLayer = [[SDLayer alloc] initWithType:@"img"];
    headImgLayer.frame = CGRectMake(kSpec, kSpec, kAvatar, kAvatar);
    [self.contentView.layer addSublayer:headImgLayer];
    self.headImgLayer = headImgLayer;
    [self.headImgLayer setContentsWithURLString:data[@"avatar"]];
    
    
    NSDictionary *attributes = [BaseFeedCell attributeWithFont:kContentTextFont andTextColor:[UIColor blackColor] lineBreakMode:NSLineBreakByCharWrapping lineSpacing:3];
    
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithString:self.contentString attributes:attributes];
    
    NSRange range = NSMakeRange(0, [contentText length]);
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [linkDetector matchesInString:contentText.string options:0 range:range];
    
    for(NSTextCheckingResult* match in matches) {
        [contentText zp_highlightColor:UIColorFromRGB(0x297bc1) backgroundColor:UIColorFromRGB(0xe5e5e5) highlightRange:match.range tapAction:^(NSString *string) {
            NSLog(@"%@", string);
        }];
    }
    
    NSMutableAttributedString *moreText = [[NSMutableAttributedString alloc] initWithString:@"\u2026查看更多" attributes:attributes];
    ZPAttributedLabel *seeMore = [ZPAttributedLabel new];
    seeMore.attributedText = moreText;
    [seeMore sizeToFit];
    
    NSAttributedString *truncationText = [NSAttributedString zp_attachmentWithContent:seeMore contentMode:UIViewContentModeCenter attachmentSize:seeMore.size alignToFont:kContentTextFont alignment:ZPTextVerticalAlignmentCenter];
    
    self.contentLabel.attributedText = contentText;
    self.contentLabel.truncationText = truncationText;
    self.contentLabel.frame = (CGRect){kTextXOffset, kSpec * 2 + self.nameLabel.frame.size.height, kContentTextWidth, 0};
    
    ZPTextLayout *layout = [ZPTextLayout layoutWithContainerSize:(CGSize){kContentTextWidth, CGFLOAT_MAX} text:contentText];
    layout.numberOfLines = 5;
    layout.truncationText = truncationText;
    self.contentLabel.layout = layout;
    self.contentLabel.size = layout.textBoundSize;
    
    CGFloat allHeight = layout.textBoundSize.height + self.nameLabel.frame.size.height + kSpec * 4 + self.resourcesSize.height;
    self.separatorLayer.frame = (CGRect){0, allHeight - 1, ScreenWidth, 1};
    
    self.baseHeight = ceil(layout.textBoundSize.height + kSpec * 3 +
                           self.nameLabel.frame.size.height);
}

+ (CGFloat)cellHeightWithData:(NSDictionary *)data {
    NSDictionary* attributes = [BaseFeedCell attributeWithFont:kContentTextFont andTextColor:[UIColor blackColor] lineBreakMode:NSLineBreakByCharWrapping lineSpacing:3];
    
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithString:data[@"content"] attributes:attributes];
    
    NSMutableAttributedString *moreText = [[NSMutableAttributedString alloc] initWithString:@"\u2026查看更多" attributes:attributes];
    ZPAttributedLabel *seeMore = [ZPAttributedLabel new];
    seeMore.attributedText = moreText;
    [seeMore sizeToFit];
    
    NSAttributedString *truncationText = [NSAttributedString zp_attachmentWithContent:seeMore contentMode:UIViewContentModeCenter attachmentSize:seeMore.size alignToFont:kContentTextFont alignment:ZPTextVerticalAlignmentCenter];
    
    ZPTextLayout *layout = [ZPTextLayout layoutWithContainerSize:(CGSize){kContentTextWidth, CGFLOAT_MAX} text:contentText];
    layout.numberOfLines = 5;
    layout.truncationText = truncationText;
    
    NSDictionary* attributes2 = @{NSFontAttributeName: kNicknameFont, NSForegroundColorAttributeName: [UIColor blackColor]};
    NSMutableAttributedString *contentText2 = [[NSMutableAttributedString alloc] initWithString:data[@"nickname"] attributes:attributes2];
    
    ZPTextLayout *layout2 = [ZPTextLayout layoutWithContainerSize:(CGSize){ScreenWidth * (1.0 / 2.0), CGFLOAT_MAX} text:contentText2];
    layout2.numberOfLines = 1;
    
    CGFloat cellHeight = layout.textBoundSize.height + layout2.textBoundSize.height + kSpec * 4 + [self resourcesHeight:data[@"resources"]].height;
    return cellHeight;
}

+ (CGSize)resourcesHeight:(NSArray *)resources {
    NSNumber *resourcesHeight;
    NSNumber *resourcesWidth;
    if (resources.count > 0) {
        
        if (resources.count == 1) {
            NSDictionary *resource = resources.firstObject;
            if (resource) {
                CGFloat width = [resource[@"width"] floatValue];
                CGFloat height = [resource[@"height"] floatValue];
                if (width > height) {
                    
                    if (width > kMaxContentImageSide) {
                        CGFloat scale = kMaxContentImageSide / width;
                        resourcesHeight = @((scale * height) / 2.0);
                        resourcesWidth = @(kMaxContentImageSide / 2.0);
                    } else {
                        resourcesHeight = @(width / 2.0);
                        resourcesWidth = @(height / 2.0);
                    }
                } else {
                    
                    if (height > kMaxContentImageSide) {
                        CGFloat scale = kMaxContentImageSide / height;
                        resourcesHeight = @(kMaxContentImageSide / 2.0);
                        resourcesWidth = @((scale * width) / 2.0);
                    } else {
                        resourcesHeight = @(width / 2.0);
                        resourcesWidth = @(height / 2.0);
                    }
                }
            }
        } else {
            NSInteger row = (resources.count - 1) / 3 + 1;
            resourcesHeight = @(row  * kContentImageWidth + (row - 1) * kImageGap);
            resourcesWidth = @(kContentImageWidth);
        }
    }
    
    return CGSizeMake([resourcesWidth floatValue], [resourcesHeight floatValue]);
}

- (void)removeHeaderLayer {
    [self.headImgLayer removeFromSuperlayer];
}

+ (NSMutableDictionary *)attributeWithFont:(UIFont *)font andTextColor:(UIColor *)color lineBreakMode:(NSLineBreakMode)lineBreakMode lineSpacing:(CGFloat)lineSpacing {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:lineBreakMode];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineSpacing:lineSpacing];
    
    NSDictionary *dictionary = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: paragraphStyle};
    return [NSMutableDictionary dictionaryWithDictionary:dictionary];
}

@end

