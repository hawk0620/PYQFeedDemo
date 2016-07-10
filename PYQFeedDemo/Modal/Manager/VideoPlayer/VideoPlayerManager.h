//
// Created by 陈浩 on 16/7/7.
// Copyright (c) 2016 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VideoPlayerManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *queueDictionary;
@property (nonatomic, strong) NSOperationQueue *queue;

+ (instancetype)shareInstance;
- (void)decodeVideo:(NSString *)filePath
        withVideoPerDataBlock:(VideoPerDataBlock)block
  decodeFinishBlock:(VideoStopDecodeBlock)finishBlock;
- (void)cancelOperationByFilePath:(NSString *)filePath;
- (void)cancelAllOperation;

@end