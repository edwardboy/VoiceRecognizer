//
//  VoiceRecognizer.h
//  VoiceRecognizer
//
//  Created by Yehua Gao on 2017/12/14.
//  Copyright © 2017年 Yehua Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VoiceRecognizerDelegate <NSObject>

/**
 开始说话
 */
- (void)recognizerVoiceStart;
/**
 结束说话
 */
- (void)recognizerVoiceEnd;
/**
 识别结果
 */
- (void)recognizerWithResult:(NSString *)result;

@end

@interface VoiceRecognizer : NSObject
@property (nonatomic,weak) id <VoiceRecognizerDelegate>delegate;

+ (instancetype)shareRecognizer;
- (void)startVoiceRecognize;

@end
