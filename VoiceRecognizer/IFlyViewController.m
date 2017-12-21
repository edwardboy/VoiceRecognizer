//
//  IFlyViewController.m
//  VoiceRecognizer
//
//  Created by Yehua Gao on 2017/12/21.
//  Copyright © 2017年 Yehua Gao. All rights reserved.
//

#import "IFlyViewController.h"
#import <iflyMSC/iflyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"

@interface IFlyViewController ()<IFlySpeechRecognizerDelegate,IFlyPcmRecorderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//Recognition conrol without view
@property (nonatomic, strong) IFlyPcmRecorder *pcmRecorder;//PCM Recorder to be used to demonstrate Audio Stream Recognition.
@end

@implementation IFlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"讯飞语音识别";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate:nil];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [_pcmRecorder stop];
    _pcmRecorder.delegate = nil;
    
    [super viewWillDisappear:animated];
}

- (IBAction)startRecognize:(UIButton *)sender {
    
    [self startRecognize];
}

- (void)startRecognize{
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //Set microphone as audio source
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //Set result type
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //Set the audio name of saved recording file while is generated in the local storage path of SDK,by default in library/cache.
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    NSLog(@"ret---%d",ret);
}

/**
 initialize recognition conctol and set recognition params
 **/
-(void)initRecognizer{
    
    //recognition singleton without view
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //set recognition domain
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //set timeout of recording
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //set VAD timeout of end of speech(EOS)
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //set VAD timeout of beginning of speech(BOS)
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //set network timeout
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //set sample rate, 16K as a recommended option
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        //set language
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //set accent
        [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        
        //set whether or not to show punctuation in recognition results
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
    
    //Initialize recorder
    if (_pcmRecorder == nil)
    {
        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
    }
    
    _pcmRecorder.delegate = self;
    
    [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
    
    [_pcmRecorder setSaveAudioPath:nil];    //not save the audio file
}

#pragma mark - IFlySpeechRecognizerDelegate
- (void) onError:(IFlySpeechError *) errorCode{
    NSLog(@"error-%@",[NSString stringWithFormat:@"code:%d,desc:%@",errorCode.errorCode,errorCode.errorDesc]);
//    [self.iFlySpeechRecognizer startListening];
}

- (void) onResults:(NSArray *)results isLast:(BOOL)isLast{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    NSLog(@"resultFromJson--_%@",resultFromJson);
    self.resultLabel.text = [NSString stringWithFormat:@"%@%@",_resultLabel.text,resultFromJson];
    if (isLast){
        
        [UIView animateWithDuration:2 animations:^{
            self.resultLabel.text = @"";
        }];
        
        [self startRecognize];
    }
}

#pragma mark - IFlyPcmRecorderDelegate
- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    if (!ret){
        [self.iFlySpeechRecognizer stopListening];
    }
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}

//range from 0 to 30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
        NSLog(@"%s,power=%d",__func__,power);
    
//    if (self.isCanceled) {
//        [_popUpView removeFromSuperview];
//        return;
//    }
//
//    NSString * vol = [NSString stringWithFormat:@"%@：%d", NSLocalizedString(@"T_RecVol", nil),power];
//    [_popUpView showText: vol];
}

- (void)dealloc{
    NSLog(@"IFlyVC---dealloc");
}

@end
