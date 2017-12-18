//
//  SGVoiceRecognizer.m
//  VoiceRecognizer
//
//  Created by Yehua Gao on 2017/12/14.
//  Copyright © 2017年 Yehua Gao. All rights reserved.
//

#import "SGVoiceRecognizer.h"
#import "SogouSemantic.h"

@interface SGVoiceRecognizer ()<SogouSemanticDelegate>

@end

@implementation SGVoiceRecognizer
static SGVoiceRecognizer *voiceRecognizer;
+ (instancetype)shareRecognizer{
    if (voiceRecognizer == nil) {
        voiceRecognizer = [[self alloc]init];
    }
    return voiceRecognizer;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        voiceRecognizer = [super allocWithZone:zone];
    });
    return voiceRecognizer;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    [SogouSemanticSetting setUserID:@"HMOX0181" andKey:@"jg1YoCKA"];    // 测试使用
    [SogouSemanticSetting setNeedSemanticsRes:NO];  // 是否开启语义服务
}

/**
 开始识别
 */
- (void)startRecognize{
    [[SogouSemantic sharedInstance] setDelegate:self];
    [[SogouSemantic sharedInstance] startListening];
}

/**
 停止识别
 */
- (void)stopRecognize{
    [[SogouSemantic sharedInstance]stopListening];
}

#pragma mark - SogouSemanticDelegate
- (void)onJSONResutls:(NSString*)jsonStr{
    NSLog(@"jsonStr:%@",jsonStr);
}

- (void)onUpdateVolume:(int)volume{
    if (volume > 0) {
        [[SogouSemantic sharedInstance] startListening];
    }
}

@end
