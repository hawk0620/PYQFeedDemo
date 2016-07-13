//
//  ViewController.m
//  PYQFeedDemo
//
//  Created by 陈浩 on 16/7/10.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "ViewController.h"
#import "FeedCell.h"
#import "NSString+Additions.h"
#import "YYFPSLabel.h"
#import "VideoPlayerManager.h"

#import "SDLayer.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@end

static NSString *cellId = @"cellId";

@implementation ViewController

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
    
    self.datas = [NSMutableArray array];
    for (NSDictionary *item in array) {
        CGSize nicknameSize = [item[@"nickname"] sizeWithConstrainedToWidth:ScreenWidth * (1.0 / 2.0)
                                                                   fromFont:kNicknameFont lineSpace:0
                                                              lineBreakMode:kCTLineBreakByTruncatingTail];
        CGSize contentSize = [item[@"content"] sizeWithConstrainedToWidth:kContentTextWidth
                                                                 fromFont:kContentTextFont
                                                                lineSpace:5
                                                            lineBreakMode:kCTLineBreakByWordWrapping];
        
        NSMutableDictionary *mItem = [NSMutableDictionary dictionaryWithDictionary:item];
        mItem[@"contentSize"] = [NSValue valueWithCGSize:contentSize];
        mItem[@"nicknameSize"] = [NSValue valueWithCGSize:nicknameSize];
        
        NSString *type = item[@"type"];
        NSArray *resources = item[@"resources"];
        if (resources.count > 0) {
            //            if ([type isEqualToString:@"img"]) {
            if (resources.count == 1) {
                NSDictionary *resource = resources.firstObject;
                if (resource) {
                    CGFloat width = [resource[@"width"] floatValue];
                    CGFloat height = [resource[@"height"] floatValue];
                    if (width > height) {
                        
                        if (width > kMaxContentImageSide) {
                            CGFloat scale = kMaxContentImageSide / width;
                            mItem[@"resourcesHeight"] = @((scale * height) / 2.0);
                            mItem[@"resourcesWidth"] = @(kMaxContentImageSide / 2.0);
                        } else {
                            mItem[@"resourcesHeight"] = @(width / 2.0);
                            mItem[@"resourcesWidth"] = @(height / 2.0);
                        }
                    } else {
                        
                        if (height > kMaxContentImageSide) {
                            CGFloat scale = kMaxContentImageSide / height;
                            mItem[@"resourcesHeight"] = @(kMaxContentImageSide / 2.0);
                            mItem[@"resourcesWidth"] = @((scale * width) / 2.0);
                        } else {
                            mItem[@"resourcesHeight"] = @(width / 2.0);
                            mItem[@"resourcesWidth"] = @(height / 2.0);
                        }
                    }
                }
            } else {
                NSInteger row = (resources.count - 1) / 3 + 1;
                mItem[@"resourcesHeight"] = @(row  * kContentImageWidth + (row - 1) * kImageGap);
                mItem[@"resourcesWidth"] = @(kContentImageWidth);
            }
            //            }
        }
        
        [self.datas addObject:mItem];
    }
    
    UITableView *tabelView = [[UITableView alloc] initWithFrame:(CGRect){0, 0 ,ScreenWidth, ScreenHeight - 64} style:UITableViewStylePlain];
    tabelView.backgroundColor = [UIColor whiteColor];
    tabelView.delegate = self;
    tabelView.dataSource = self;
    tabelView.delaysContentTouches = NO;
    tabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tabelView];
    self.tableView = tabelView;
    
    _fpsLabel = [YYFPSLabel new];
    [_fpsLabel sizeToFit];
    _fpsLabel.y = ScreenHeight - 30 - 64;
    _fpsLabel.x = 15;
    _fpsLabel.alpha = 0;
    [self.view addSubview:_fpsLabel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *item = self.datas[indexPath.row];
    [cell configWithData:item];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.datas[indexPath.row];
    return ceil([item[@"contentSize"] CGSizeValue].height +
                [item[@"nicknameSize"] CGSizeValue].height +
                [item[@"resourcesHeight"] floatValue] + kSpec * 4);
}

- (void)tableView:(UITableView *)tableView
didEndDisplayingCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell * feedCell = (FeedCell *)cell;
    if (feedCell.filePath) {
        [[VideoPlayerManager shareInstance] cancelOperationByFilePath:feedCell.filePath];
    }
    
    for (SDLayer *layer in feedCell.sources) {
        [layer _clearPendingListObserver];
        layer.contents = nil;
        [layer removeFromSuperlayer];
    }
    feedCell.filePath = nil;
    feedCell.linkString = nil;
    [feedCell removeHeaderLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
