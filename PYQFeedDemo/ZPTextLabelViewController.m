//
//  ZPTextLabelViewController.m
//  PYQFeedDemo
//
//  Created by gzHawk on 2017/9/26.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "ZPTextLabelViewController.h"
#import "ZPAttributedLabel.h"

@interface ZPTextLabelViewController ()

@end

@implementation ZPTextLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [paragraphStyle setLineSpacing:0];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"fasfaffdfadsfdsafasfaffdfadsfdsafasfaffdfadsfdsafasfaffdfadsfdsa" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName: [UIColor greenColor], NSParagraphStyleAttributeName: paragraphStyle}];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9] range:NSMakeRange(0, 2)];
    
    ZPAttributedLabel *label = [[ZPAttributedLabel alloc] initWithFrame:(CGRect){0, 0, 80, 80}];
    label.attributedText = text;
    label.backgroundColor = [UIColor orangeColor];
    label.font = [UIFont systemFontOfSize:18];
    label.center = self.view.center;
    
    label.numberOfLines = 3;
    [label sizeToFit];
    
    [self.view addSubview:label];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
