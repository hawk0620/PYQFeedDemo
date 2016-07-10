//
//  ZPFileManager.m
//  Records
//
//  Created by 陈浩 on 15/11/10.
//  Copyright © 2015年 陈浩. All rights reserved.
//

#import "ZPFileManager.h"

@implementation ZPFileManager

+ (NSString *)libCachesPath:(NSString *)directory {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
                      stringByAppendingPathComponent:@"ZPDirector"];
    if (directory) {
        path = [path stringByAppendingPathComponent:directory];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

@end
