//
//  SGViewController.m
//  VoiceRecognizer
//
//  Created by Yehua Gao on 2017/12/14.
//  Copyright © 2017年 Yehua Gao. All rights reserved.
//

#import "SGViewController.h"

@interface SGViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@end

@implementation SGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"搜狗语音识别";
}

- (IBAction)startRecognize:(UIButton *)sender {
    
}


@end
