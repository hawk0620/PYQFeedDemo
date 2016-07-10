//
// Created by 陈浩 on 16/7/7.
// Copyright (c) 2016 陈浩. All rights reserved.
//

#import "VideoDecodeOperation.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoDecodeOperation ()

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, copy) VideoPerDataBlock newVideoFrameBlock;
@property (nonatomic, copy) VideoStopDecodeBlock decodeFinishedBlock;

@end

@implementation VideoDecodeOperation

- (instancetype)initDecoderWithURLPath:(NSString *)path
                 newFrameBlock:(VideoPerDataBlock)newFrameBlock
                 finishedBlock:(VideoStopDecodeBlock)finishedBlock {

    if (self = [super init]) {
        _filePath = path;
        _newVideoFrameBlock = newFrameBlock;
        _decodeFinishedBlock = finishedBlock;
    }
    return self;
}

- (void)main {

    @autoreleasepool {

        if (self.isCancelled) {
            _newVideoFrameBlock = nil;
            _decodeFinishedBlock = nil;
            return;
        }

        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[[NSURL alloc] initFileURLWithPath:self.filePath] options:nil];
        NSError *error;
        AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        if (error) {
            return;
        }

        NSArray* videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
        // 视频播放时，m_pixelFormatType=kCVPixelFormatType_32BGRA
        // 其他用途，如视频压缩，m_pixelFormatType=kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        int m_pixelFormatType = kCVPixelFormatType_32BGRA;
        NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt: (int)m_pixelFormatType]
                                                            forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc]
                initWithTrack:videoTrack outputSettings:options];
        [reader addOutput:videoReaderOutput];
        [reader startReading];
        // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
        if (self.isCancelled) {
            _newVideoFrameBlock = nil;
            _decodeFinishedBlock = nil;
            return;
        }

        while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
            if (self.isCancelled) {
                _newVideoFrameBlock = nil;
                _decodeFinishedBlock = nil;
                return;
            }
            
            CMSampleBufferRef sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            
            // Lock the base address of the pixel buffer
            CVPixelBufferLockBaseAddress(imageBuffer, 0);
            
            // Get the number of bytes per row for the pixel buffer
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
            
            // Get the pixel buffer width and height
            size_t width = CVPixelBufferGetWidth(imageBuffer);
            size_t height = CVPixelBufferGetHeight(imageBuffer);
            
            //Generate image to edit`
            unsigned char* pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
            
            CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
            CGContextRef context=CGBitmapContextCreate(pixel, width, height, 8, bytesPerRow, colorSpace,
                                                       kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
            if (context != NULL) {
                CGImageRef imageRef = CGBitmapContextCreateImage(context);
                
                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                CGColorSpaceRelease(colorSpace);
                CGContextRelease(context);
                
                // 解码图片
                size_t width = CGImageGetWidth(imageRef);
                size_t height = CGImageGetHeight(imageRef);
                size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
                
                // CGImageGetBytesPerRow() calculates incorrectly in iOS 5.0, so defer to CGBitmapContextCreate
                size_t bytesPerRow = 0;
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
                CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
                
                if (colorSpaceModel == kCGColorSpaceModelRGB) {
                    uint32_t alpha = (bitmapInfo & kCGBitmapAlphaInfoMask);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
                    if (alpha == kCGImageAlphaNone) {
                        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
                        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
                    } else if (!(alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast)) {
                        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
                        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
                    }
#pragma clang diagnostic pop
                }
                
                CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent,
                                                             bytesPerRow, colorSpace, bitmapInfo);
                
                CGColorSpaceRelease(colorSpace);
                
                if (!context) {
                    if (self.newVideoFrameBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.isCancelled) {
                                _newVideoFrameBlock = nil;
                                _decodeFinishedBlock = nil;
                                return;
                            }
                            self.newVideoFrameBlock(imageRef, self.filePath);
                            CGImageRelease(imageRef);
                        });
                    }
                } else {
                    
                    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), imageRef);
                    CGImageRef inflatedImageRef = CGBitmapContextCreateImage(context);
                    
                    CGContextRelease(context);
                    if (self.newVideoFrameBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.isCancelled) {
                                _newVideoFrameBlock = nil;
                                _decodeFinishedBlock = nil;
                                return;
                            }
                            self.newVideoFrameBlock(inflatedImageRef, self.filePath);
                            
                            CGImageRelease(inflatedImageRef);
                        });
                    }
                    CGImageRelease(imageRef);
                }
                
                if(sampleBuffer) {
                    CMSampleBufferInvalidate(sampleBuffer);
                    CFRelease(sampleBuffer);
                    sampleBuffer = NULL;
                    
                } else {
                    break;
                }
            }
            
            [NSThread sleepForTimeInterval:CMTimeGetSeconds(videoTrack.minFrameDuration)];
        }

        if (self.isCancelled) {
            _newVideoFrameBlock = nil;
            _decodeFinishedBlock = nil;
            return;
        }
        if (self.decodeFinishedBlock) {
            self.decodeFinishedBlock(self.filePath);
        }
    }
}

@end