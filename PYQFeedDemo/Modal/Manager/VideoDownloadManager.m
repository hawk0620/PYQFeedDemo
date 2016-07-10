//
//  VideoDownloadManager.m
//  UU
//
//  Created by 陈浩 on 16/7/2.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "VideoDownloadManager.h"
#import "AFNetworking.h"
#import "ZPFileManager.h"

@implementation VideoDownloadManager

+ (void)downloadViedoFromURL:(NSURL *)targetURL
               progressBlock:(VoidProgressBlock)progressBlock
               completeBlock:(VoidCompleteBlock)completeBlock
{
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progressBlock(downloadProgress.fractionCompleted);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSString *outputPath = [ZPFileManager libCachesPath:@"Regular"];
        NSString *filePath = [outputPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[response suggestedFilename]]];
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",filePath]];
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        completeBlock([filePath path], error);
    }];
    [downloadTask resume];
    
}

@end
