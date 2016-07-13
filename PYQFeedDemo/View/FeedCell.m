//
//  FeedCell.m
//  UU
//
//  Created by luoo on 16/5/24.
//  Copyright © 2016年 陈浩. All rights reserved.
//

#import "FeedCell.h"
#import "NSString+Additions.h"
#import "ContentTextManager.h"
#import "SDLayer.h"
#import "VideoDownloadManager.h"
#import "ZPFileManager.h"
#import "VideoPlayerManager.h"

@interface FeedCell ()
@property (nonatomic, weak) SDLayer *headImgLayer;

@property (nonatomic, assign) CGPoint satrtLocation;

@property (nonatomic, assign) CGRect nicknameRect;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *contentString;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGSize nicknameSize;
@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, strong) ContentTextManager *drawer;
@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) CALayer *separatorLayer;

@end

@implementation FeedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CALayer *separatorLayer = [[CALayer alloc] init];
        separatorLayer.backgroundColor = UIColorFromRGB(0xe6e6e6).CGColor;
        [self.contentView.layer addSublayer:separatorLayer];
        _separatorLayer = separatorLayer;
    }
    return self;
}

- (void)configWithData:(NSDictionary *)data {
    self.sources = [NSMutableArray array];
    
    self.nicknameSize = [data[@"nicknameSize"] CGSizeValue];
    self.contentSize = [data[@"contentSize"] CGSizeValue];
    self.nicknameRect = (CGRect){kTextXOffset, kSpec, self.nicknameSize};
    self.nickname = data[@"nickname"];
    self.contentString = data[@"content"];
    self.drawer = [[ContentTextManager alloc] init];
    
    CGFloat resourcesHeight = [data[@"resourcesHeight"] floatValue];
    CGFloat resourcesWidth = [data[@"resourcesWidth"] floatValue];
    
    self.size = CGSizeMake(ScreenWidth, ceil([data[@"contentSize"] CGSizeValue].height + kSpec * 4 +
                                             [data[@"nicknameSize"] CGSizeValue].height + resourcesHeight));
    
    self.separatorLayer.frame = (CGRect){0, self.size.height - 1, ScreenWidth, 1};
    
    SDLayer *headImgLayer = [[SDLayer alloc] initWithType:@"img"];
    headImgLayer.frame = CGRectMake(kSpec, kSpec, kAvatar, kAvatar);
    [self.contentView.layer addSublayer:headImgLayer];
    self.headImgLayer = headImgLayer;
    [self.headImgLayer setContentsWithURLString:data[@"avatar"]];
    [self fillContents:nil];
    
    CGFloat baseHeight = ceil([data[@"contentSize"] CGSizeValue].height + kSpec * 3 +
                              [data[@"nicknameSize"] CGSizeValue].height);
    NSString *type = data[@"type"];
    self.resources = data[@"resources"];
    if (self.resources.count > 0) {
        if ([type isEqualToString:@"img"]) {
            if (self.resources.count == 1) {
                NSDictionary *resource = self.resources.firstObject;
                SDLayer *layer = [[SDLayer alloc] initWithType:type];
                layer.frame = CGRectMake(kTextXOffset, baseHeight, resourcesWidth, resourcesHeight);
                [layer setContentsWithURLString:resource[@"image_url"]];
                [self.contentView.layer addSublayer:layer];
                [self.sources addObject:layer];
                
            } else {
                for (NSInteger i = 0; i < self.resources.count; i++) {
                    NSDictionary *resource = self.resources[i];
                    NSInteger row = i / 3;
                    
                    SDLayer *layer = [[SDLayer alloc] initWithType:type];
                    layer.frame = CGRectMake(kTextXOffset + (i % 3) * (kImageGap + kContentImageWidth), baseHeight
                            + row * (kImageGap + kContentImageWidth), kContentImageWidth, kContentImageWidth);
                    layer.contentsGravity = kCAGravityResizeAspectFill;
                    layer.masksToBounds = YES;
                    [layer setContentsWithURLString:resource[@"image_url"]];
                    [self.contentView.layer addSublayer:layer];
                    
                    [self.sources addObject:layer];
                }
            }
        } else if ([type isEqualToString:@"video"]) {
            NSDictionary *resource = self.resources.firstObject;
            SDLayer *layer = [[SDLayer alloc] initWithType:type];
            layer.frame = CGRectMake(kTextXOffset, baseHeight, resourcesWidth, resourcesHeight);
            
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
}

- (void)fillData:(CGContextRef)context {
    [self.nickname drawInContext:context withPosition:(CGPoint){kTextXOffset, kSpec} andFont:kNicknameFont
                    andTextColor:UIColorFromRGB(0x556c95) andHeight:self.nicknameSize.height
                        andWidth:self.nicknameSize.width lineBreakMode:kCTLineBreakByTruncatingTail];
    [self.drawer setText:self.contentString context:context contentSize:self.contentSize
         backgroundColor:[UIColor whiteColor] font:kContentTextFont textColor:[UIColor blackColor]
                   block:nil xOffset:kTextXOffset yOffset:kSpec * 2 + self.nicknameSize.height];
}

- (void)fillContents:(NSArray *)array {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIColorFromRGB(0xffffff) set];
    CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
    
    // 获取需要高亮的链接CGRect，并填充背景色
    if (array) {
        for (NSString *string in array) {
            CGRect rect = CGRectFromString(string);
            [UIColorFromRGB(0xe5e5e5) set];
            CGContextFillRect(context, rect);
        }
    }
    
    [self fillData:context];
    
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.contentView.layer.contents = (__bridge id _Nullable)(temp.CGImage);
}

- (void)playVideoWithFilePath:(NSString *)filePath_ type:(NSString *)type {
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
                              } decodeFinishBlock:^(NSString *filePath){
                [self playVideoWithFilePath:filePath type:type];
            }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.satrtLocation = [[touches anyObject] locationInView:self];
    if([self.headImgLayer touchBeginPoint:self.satrtLocation]) { return; }
    
    if (CGRectContainsPoint(self.nicknameRect, self.satrtLocation)) {
        [self fillContents:@[NSStringFromCGRect(self.nicknameRect)]];
        return;
    }
    
    for (NSInteger i = 0; i < self.sources.count; i++) {
        SDLayer *layer = [self.sources objectAtIndex:i];
        if([layer touchBeginPoint:self.satrtLocation]) { return; }
    }
    
    for (NSString *key in self.drawer.framesDict) {
        
        CGRect frame = [[self.drawer.framesDict valueForKey:key] CGRectValue];
        if (CGRectContainsPoint(frame, self.satrtLocation)) {
            NSRange tapRange = NSRangeFromString(key);
            for (NSString *rangeString in self.drawer.ranges) {
                NSRange myRange = NSRangeFromString(rangeString);
                if (NSLocationInRange(tapRange.location, myRange)) {
                    NSArray *rects = self.drawer.relationDict[rangeString];
                    [self fillContents:rects];
                    self.linkString = [self.contentString substringWithRange:myRange];
                    return;
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.headImgLayer touchCancelPoint];
    for (NSInteger i = 0; i < self.sources.count; i++) {
        SDLayer *layer = [self.sources objectAtIndex:i];
        [layer touchCancelPoint];
    }
    
    self.linkString = nil;
    [self fillContents:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    [self.headImgLayer touchEndPoint:location action:^{
        
    }];
    for (NSInteger i = 0; i < self.sources.count; i++) {
        SDLayer *layer = [self.sources objectAtIndex:i];
        BOOL flag = [layer touchEndPoint:location action:^{
            NSDictionary *resource = self.resources[i];
            NSLog(@"%@",resource);
        }];
        if (flag) {
            break;
        }
    }
    
    if (self.linkString) {
        NSLog(@"%@",self.linkString);
    }
    
    if (CGRectContainsPoint(self.nicknameRect, location) && CGRectContainsPoint(self.nicknameRect, self.satrtLocation)) {
        NSLog(@"-------");
    }
    
    [self fillContents:nil];
}

- (void)removeHeaderLayer {
    [self.headImgLayer removeFromSuperlayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
