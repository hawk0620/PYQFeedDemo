//
// Created by 陈浩 on 16/7/7.
// Copyright (c) 2016 陈浩. All rights reserved.
//

#import "VideoPlayerManager.h"
#import "VideoDecodeOperation.h"

@implementation VideoPlayerManager

+ (instancetype)shareInstance {
    static VideoPlayerManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _queueDictionary = [NSMutableDictionary dictionary];
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 30;
    }
    return self;
}

- (void)decodeVideo:(NSString *)filePath
        withVideoPerDataBlock:(VideoPerDataBlock)block
        decodeFinishBlock:(VideoStopDecodeBlock)finishBlock{
    [self cancelOperationByFilePath:filePath];
    VideoDecodeOperation *operation = [[VideoDecodeOperation alloc] initDecoderWithURLPath:filePath
                                                                             newFrameBlock:block
                                                                             finishedBlock:finishBlock];
    [self.queue addOperation:operation];
    self.queueDictionary[filePath] = operation;
}

- (void)cancelOperationByFilePath:(NSString *)filePath {
    VideoDecodeOperation *operation = self.queueDictionary[filePath];
    if ([operation isCancelled]) {
        [self.queueDictionary removeObjectForKey:filePath];
        return;
    }

    [operation cancel];
    if ([operation isCancelled]) {
        [self.queueDictionary removeObjectForKey:filePath];
    }
}

- (void)cancelAllOperation {
    for (NSString *key in self.queueDictionary) {
        [self cancelOperationByFilePath:key];
    }
    [self.queue cancelAllOperations];
    [self.queueDictionary removeAllObjects];
}

@end