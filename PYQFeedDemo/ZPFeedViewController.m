//
//  ZPFeedViewController.m
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/9/26.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "ZPFeedViewController.h"
#import "FeedImageCell.h"
#import "YYFPSLabel.h"
#import "VideoPlayerManager.h"
#import "FeedVideoCell.h"

#import "SDLayer.h"
#import "ZPAttributedLabel.h"

static NSString *cellId = @"cellId";

@interface ZPFeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@end

@implementation ZPFeedViewController

/**
 全部收起的功能
 测试多行 sizetofit
 提取zplabel
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *array;
    
    if (data) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        array = dictionary[@"data"];
    }
    self.datas = [NSMutableArray arrayWithArray:array];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0 ,ScreenWidth, ScreenHeight - 64} style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    [tableView registerClass:[FeedImageCell class] forCellReuseIdentifier:cellId];
    [tableView registerClass:[FeedVideoCell class] forCellReuseIdentifier:NSStringFromClass([FeedVideoCell class])];
    
    self.tableView = tableView;
    
    //    _fpsLabel = [YYFPSLabel new];
    //    [_fpsLabel sizeToFit];
    //    _fpsLabel.y = ScreenHeight - 30 - 64;
    //    _fpsLabel.x = 15;
    //    _fpsLabel.alpha = 0;
    //    [self.view addSubview:_fpsLabel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.datas[indexPath.row];
    BaseFeedCell *cell;
    if ([item[@"type"] isEqualToString:@"img"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        [cell configWithData:item];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FeedVideoCell class])];
        [cell configWithData:item];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.datas[indexPath.row];
    return [BaseFeedCell cellHeightWithData:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseFeedCell *feedCell = (BaseFeedCell *)cell;
    if (feedCell.filePath) {
        [[VideoPlayerManager shareInstance] cancelOperationByFilePath:feedCell.filePath];
    }
    
    for (SDLayer *layer in feedCell.sources) {
        [layer _clearPendingListObserver];
        layer.contents = nil;
        [layer removeFromSuperlayer];
    }
    [feedCell.sources removeAllObjects];
    feedCell.filePath = nil;
    feedCell.linkString = nil;
    [feedCell removeHeaderLayer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (_fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}

@end
