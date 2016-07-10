//
//  SDLayer.m
//  UU
//
//  Created by 陈浩 on 16/6/22.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "SDLayer.h"
#import "SDWebImageManager.h"
#import "UIImage+Filter.h"


static const CFIndex CATransactionCommitRunLoopOrder = 2000000;
static const CFIndex POPAnimationApplyRunLoopOrder = CATransactionCommitRunLoopOrder - 1;

@interface SDLayer () {
    
    CFRunLoopObserverRef _observer;
}
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, strong) NSString *type;

@end

@implementation SDLayer

- (instancetype)initWithType:(NSString *)type {
    if (self = [super init]) {
        _type = type;
    }
    return self;
}

- (void)setContentsWithURLString:(NSString *)urlString {
    
    self.contents = (__bridge id _Nullable)([UIImage imageNamed:@"placeholder"].CGImage);
    @weakify(self)
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:urlString]
                          options:SDWebImageCacheMemoryOnly
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                @strongify(self)
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    if (!_observer) {
                                        
                                        _observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting | kCFRunLoopExit, false, POPAnimationApplyRunLoopOrder, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                                            self.contents = (__bridge id _Nullable)(image.CGImage);
                                        });
                                        
                                        if (_observer) {
                                            CFRunLoopAddObserver(CFRunLoopGetMain(), _observer,  kCFRunLoopCommonModes);
                                        }
                                    }
                                });
                                self.originImage = image;
                            }
                        }];
}

- (void)highlightedImage {
    if (!self.highlightImage) {
        self.highlightImage = [self.originImage colorizeImageWithColor:[UIColor grayColor]];
    }
    self.contents = (__bridge id _Nullable)(self.highlightImage.CGImage);
}

- (void)unhighlightedImage {
    self.contents = (__bridge id _Nullable)(self.originImage.CGImage);
}

- (BOOL)touchBeginPoint:(CGPoint)point {
    if (!self.originImage) { return NO; }
    self.startLocation = point;
    
    if (CGRectContainsPoint(self.frame, point)) {
        
        if ([self.type isEqualToString:@"img"]) {
            [self highlightedImage];
        }
        return YES;
    }
    return NO;
}

- (void)touchCancelPoint {
    if (!self.originImage) { return; }
    if ([self.type isEqualToString:@"img"]) {
        [self unhighlightedImage];
    }
}

- (BOOL)touchEndPoint:(CGPoint)point action:(VoidResultBlock)block {
    if (!self.originImage) { return NO; }
    
    if ([self.type isEqualToString:@"img"]) {
        [self unhighlightedImage];
    }

    if (CGRectContainsPoint(self.frame, point) && CGRectContainsPoint(self.frame, self.startLocation)) {
        block();
        return YES;
    }
    return NO;
}


- (void)_clearPendingListObserver
{
    if (_observer) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
        CFRelease(_observer);
        _observer = NULL;
    }
}

@end
