//
//  ViewController.m
//  PYQFeedDemo
//
//  Created by 陈浩 on 16/7/10.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "ViewController.h"
#import "ZPFeedViewController.h"
#import "ZPTextLabelViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSArray *datas;

@end

static NSString *cellId = @"cellId";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.datas = @[@"feed", @"normal"];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0 ,ScreenWidth, ScreenHeight - 64} style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    self.tableView = tableView;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = self.datas[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            ZPFeedViewController *viewController = [ZPFeedViewController new];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 1:
        {
            ZPTextLabelViewController *viewController = [ZPTextLabelViewController new];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        default:
            break;
    }
}


@end
