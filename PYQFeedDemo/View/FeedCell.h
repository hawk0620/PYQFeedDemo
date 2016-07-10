//
//  FeedCell.h
//  UU
//
//  Created by luoo on 16/5/24.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *linkString;

- (void)configWithData:(NSDictionary *)data;

@end
