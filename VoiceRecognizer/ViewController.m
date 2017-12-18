//
//  ViewController.m
//  VoiceRecognizer
//
//  Created by Yehua Gao on 2017/12/11.
//  Copyright © 2017年 Yehua Gao. All rights reserved.
//

#import "ViewController.h"
#import "VoiceRecognizer.h"

@interface ViewController ()<VoiceRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (nonatomic,strong) VoiceRecognizer *voiceRecognizer;
@end

@implementation ViewController

- (VoiceRecognizer *)voiceRecognizer{
    if (!_voiceRecognizer) {
        _voiceRecognizer = [VoiceRecognizer shareRecognizer];
        _voiceRecognizer.delegate = self;
    }
    return _voiceRecognizer;
}

#pragma mark - VoiceRecognizerDelegate
- (void)recognizerVoiceStart{
//    [self.voiceRecognizer startVoiceRecognize];
    NSLog(@"recognizerVoiceStart");
}

- (void)recognizerVoiceEnd{
    NSLog(@"当前识别已完成");
    [self.voiceRecognizer startVoiceRecognize];
}

- (void)recognizerWithResult:(NSString *)result{
    self.startBtn.enabled = YES;
    NSLog(@"识别结果：%@",result);
    self.resultLabel.text = result;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.resultLabel.text = @"";
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"百度语音识别";
}

- (IBAction)startRecognize:(UIButton *)sender {
//    sender.enabled = NO;
    sender.hidden = YES;
    [self.voiceRecognizer startVoiceRecognize];
}

@end
