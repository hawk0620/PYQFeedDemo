//
//  VideoDownloadManager.h
//  UU
//
//  Created by 陈浩 on 16/7/2.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^VoidProgressBlock)(float progress);
typedef void (^VoidCompleteBlock)(NSString *filePath, NSError *error);

@interface VideoDownloadManager : NSObject

+ (void)downloadViedoFromURL:(NSURL *)targetURL progressBlock:(VoidProgressBlock)progressBlock completeBlock:(VoidCompleteBlock)completeBlock;

@end
