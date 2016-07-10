//
// Created by 陈浩 on 16/7/7.
// Copyright (c) 2016 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NewVideoFrameBlock)(CGImageRef *imageRef, NSString *filePath);
typedef void (^DecodeFinishedBlock)(NSArray *imgs, float duration);

@interface VideoDecodeOperation : NSOperation

- (instancetype)initDecoderWithURLPath:(NSString *)path
                 newFrameBlock:(VideoPerDataBlock)newFrameBlock
                 finishedBlock:(VideoStopDecodeBlock)finishedBlock;

@end