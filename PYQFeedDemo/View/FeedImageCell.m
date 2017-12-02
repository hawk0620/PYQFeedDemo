//
//  FeedCell.m
//  UU
//
//  Created by luoo on 16/5/24.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "FeedImageCell.h"
#import "SDLayer.h"

@implementation FeedImageCell

- (void)configWithData:(NSDictionary *)data {
    [super configWithData:data];
    
    NSString *type = data[@"type"];
    self.resources = data[@"resources"];
    if (self.resources.count > 0) {
        if (self.resources.count == 1) {
            NSDictionary *resource = self.resources.firstObject;
            SDLayer *layer = [[SDLayer alloc] initWithType:type];
            layer.frame = CGRectMake(kTextXOffset, self.baseHeight, self.resourcesSize.width, self.resourcesSize.height);
            [layer setContentsWithURLString:resource[@"image_url"]];
            [self.contentView.layer addSublayer:layer];
            [self.sources addObject:layer];
            
        } else {
            for (NSInteger i = 0; i < self.resources.count; i++) {
                NSDictionary *resource = self.resources[i];
                NSInteger row = i / 3;
                
                SDLayer *layer = [[SDLayer alloc] initWithType:type];
                layer.frame = CGRectMake(kTextXOffset + (i % 3) * (kImageGap + kContentImageWidth), self.baseHeight
                                         + row * (kImageGap + kContentImageWidth), kContentImageWidth, kContentImageWidth);
                layer.contentsGravity = kCAGravityResizeAspectFill;
                layer.masksToBounds = YES;
                [layer setContentsWithURLString:resource[@"image_url"]];
                [self.contentView.layer addSublayer:layer];
                
                [self.sources addObject:layer];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
