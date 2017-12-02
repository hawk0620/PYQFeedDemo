//
//  FeedVideoCell.m
//  PYQFeedDemo
//
//  Created by 陈浩 on 2017/8/24.
//  Copyright © 2017年 陈浩. All rights reserved.
//

#import "FeedVideoCell.h"
#import "SDLayer.h"
#import "VideoDownloadManager.h"
#import "ZPFileManager.h"
#import "VideoPlayerManager.h"

@interface FeedVideoCell ()

@end

@implementation FeedVideoCell

- (void)configWithData:(NSDictionary *)data {
    [super configWithData:data];
    
    NSString *type = data[@"type"];
    self.resources = data[@"resources"];
    if (self.resources.count > 0) {
        
        NSDictionary *resource = self.resources.firstObject;
        SDLayer *layer = [[SDLayer alloc] initWithType:type];
        layer.frame = CGRectMake(kTextXOffset, self.baseHeight, self.resourcesSize.width, self.resourcesSize.height);
        
        [layer setContentsWithURLString:resource[@"image_url"]];
        [self.contentView.layer addSublayer:layer];
        [self.sources addObject:layer];
        
        NSString *video_url = resource[@"video_url"];
        NSURL *videoURL = [NSURL URLWithString:video_url];
        NSString *lastPathComponent = [video_url lastPathComponent];
        
        NSString *outputPath = [ZPFileManager libCachesPath:@"Regular"];
        NSString *file_path = [outputPath stringByAppendingPathComponent:lastPathComponent];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:file_path];
        if (fileExists) {
            self.filePath = file_path;
            [self playVideoWithFilePath:self.filePath type:type];
            
        } else {
            @weakify(self)
            [VideoDownloadManager downloadViedoFromURL:videoURL progressBlock:^(float progress) {
                //                    NSLog(@"%f",progress);
            } completeBlock:^(NSString *file_path, NSError *error) {
                @strongify(self)
                if ([[file_path lastPathComponent] isEqualToString:lastPathComponent]) {
                    self.filePath = file_path;
                    [self playVideoWithFilePath:self.filePath type:type];
                }
            }];
        }
        
    }
}

- (void)playVideoWithFilePath:(NSString *)filePath_ type:(NSString *)type {
    if ([type isEqualToString:@"video"]) {
        @weakify(self)
        [[VideoPlayerManager shareInstance] decodeVideo:filePath_
                                  withVideoPerDataBlock:^(CGImageRef imageData, NSString *filePath) {
                                      @strongify(self)
                                      if ([type isEqualToString:@"video"]) {
                                          if ([filePath isEqualToString:self.filePath]) {
                                              [self.sources.firstObject
                                               setContents:(__bridge id _Nullable)(imageData)];
                                          }
                                      }
                                  }
                                      decodeFinishBlock:^(NSString *filePath){
                                          @strongify(self)
                                          [self playVideoWithFilePath:filePath type:type];
                                      }];
    }
}

@end
