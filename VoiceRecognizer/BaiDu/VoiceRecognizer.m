//
//  VoiceRecognizer.m
//  VoiceRecognizer
//
//  Created by Yehua Gao on 2017/12/14.
//  Copyright © 2017年 Yehua Gao. All rights reserved.
//  语音识别器

#import "VoiceRecognizer.h"

#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "BDSEventManager.h"
#import "BDRecognizerViewDelegate.h"

const NSString* API_KEY = @"FABOyKTmyv6T9pvFFRVREnF3";
const NSString* SECRET_KEY = @"182c1bcf4ccab87f61f21f52aaa5714b";
const NSString* APP_ID = @"10497560";

@interface VoiceRecognizer ()<BDSClientASRDelegate, BDRecognizerViewDelegate>

@property (strong, nonatomic) BDSEventManager *asrEventManager;

@end

@implementation VoiceRecognizer

static VoiceRecognizer *voiceRecognizer;
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

- (void)startVoiceRecognize {
    NSLog(@"开始下一句识别");
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self voiceRecogButtonHelper];
}

- (void)setup {
    _asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    [self configVoiceRecognitionClient];
}

- (void)voiceRecogButtonHelper {
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
}

- (void)configVoiceRecognitionClient {
    //设置DEBUG_LOG的级别
//    [self.asrEventManager setParameter:@(EVRDebugLogLevelTrace) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    //配置API_KEY 和 SECRET_KEY 和 APP_ID
    [self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    //配置端点检测（二选一）
    [self configModelVAD];
    //    [self configDNNMFE];
    
    //     [self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
    // ---- 语义与标点 -----
//    [self enableNLU];
    //    [self enablePunctuation];
    // ------------------------
}


- (void) enableNLU {
    // ---- 开启语义理解 -----
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU];
    [self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
}

- (void) enablePunctuation {
    // ---- 开启标点输出 -----
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_DISABLE_PUNCTUATION];
    // 普通话标点
    //    [self.asrEventManager setParameter:@"1537" forKey:BDS_ASR_PRODUCT_ID];
    // 英文标点
    [self.asrEventManager setParameter:@"1737" forKey:BDS_ASR_PRODUCT_ID];
}

- (void)configModelVAD {
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

- (void)configDNNMFE {
    NSString *mfe_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_dnn" ofType:@"dat"];
    [self.asrEventManager setParameter:mfe_dnn_filepath forKey:BDS_ASR_MFE_DNN_DAT_FILE];
    NSString *cmvn_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_cmvn" ofType:@"dat"];
    [self.asrEventManager setParameter:cmvn_dnn_filepath forKey:BDS_ASR_MFE_CMVN_DAT_FILE];
    // 自定义静音时长
    //    [self.asrEventManager setParameter:@(501) forKey:BDS_ASR_MFE_MAX_SPEECH_PAUSE];
    //    [self.asrEventManager setParameter:@(500) forKey:BDS_ASR_MFE_MAX_WAIT_DURATION];
}

#pragma mark - BDSClientASRDelegate
- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj{
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            NSLog(@"EVoiceRecognitionClientWorkStatusNewRecordData---%@",[self getDescriptionForDic:aObj]);
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            NSLog(@"EVoiceRecognitionClientWorkStatusStartWorkIng---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            NSLog(@"开始说话---%@",[self getDescriptionForDic:aObj]);
            if (self.delegate && [self.delegate respondsToSelector:@selector(recognizerVoiceStart)]){
                [self.delegate recognizerVoiceStart];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            NSLog(@"EVoiceRecognitionClientWorkStatusEnd---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            NSLog(@"EVoiceRecognitionClientWorkStatusFlushData---%@",[self getDescriptionForDic:aObj]);
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            NSLog(@"EVoiceRecognitionClientWorkStatusMeterLevel---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            NSLog(@"EVoiceRecognitionClientWorkStatusCancel---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            NSLog(@"EVoiceRecognitionClientWorkStatusError---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusLoaded: {
            NSLog(@"EVoiceRecognitionClientWorkStatusLoaded---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusUnLoaded: {
            NSLog(@"EVoiceRecognitionClientWorkStatusUnLoaded---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkThirdData: {
            NSLog(@"EVoiceRecognitionClientWorkStatusChunkThirdData---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkNlu: {
            NSLog(@"EVoiceRecognitionClientWorkStatusChunkNlu---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkEnd: {
            NSLog(@"EVoiceRecognitionClientWorkStatusChunkEnd---%@",[self getDescriptionForDic:aObj]);
            if (self.delegate && [self.delegate respondsToSelector:@selector(recognizerVoiceEnd)]){
                [self.delegate recognizerVoiceEnd];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusFeedback: {
            NSLog(@"EVoiceRecognitionClientWorkStatusFeedback---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusRecorderEnd: {
            NSLog(@"EVoiceRecognitionClientWorkStatusRecorderEnd---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            NSLog(@"EVoiceRecognitionClientWorkStatusLongSpeechEnd---%@",[self getDescriptionForDic:aObj]);
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            if (aObj) {
                NSArray *results = aObj[@"results_recognition"];
                NSString *result = results.firstObject;
                if (self.delegate && [self.delegate respondsToSelector:@selector(recognizerWithResult:)]) {
                    [self.delegate recognizerWithResult:result];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (NSString *)getDescriptionForDic:(id)dic {
    
    return @"测试";
    
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}


@end
