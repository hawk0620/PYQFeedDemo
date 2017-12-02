//
//  BaseFeedCell.h
//  PYQFeedDemo
//
//  Created by 陈浩 on 2017/8/26.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseFeedCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *linkString;

@property (nonatomic, strong) NSArray *resources;
@property (nonatomic) CGFloat baseHeight;
@property (nonatomic) CGSize resourcesSize;

- (void)configWithData:(NSDictionary *)data;
- (void)removeHeaderLayer;

+ (CGFloat)cellHeightWithData:(NSDictionary *)data;

@end
