//
//  SogouSemantic.h
//  SogouSpeechRecognize_Inc_Arc
//
//  Created by sogou on 2016/11/23.
//  Copyright © 2016年 Sogou. All rights reserved.
//
//  Version:1.1.0

#import <Foundation/Foundation.h>


/**
 语义理解的委托类
 */
@protocol SogouSemanticDelegate<NSObject>

@optional
/**
 语义结果返回

 @param jsonStr JSON格式的字符串
 */
- (void)onJSONResutls:(NSString*)jsonStr;

/**
 错误返回

 @param error 语义过程中产生的错误
 */
- (void)onError:(NSError*)error;

/**
 录音停止(可能语义并没有停止，语义过程结束须由onError或onJSONResults来标识);
 */
- (void)onRecordStop;


/**
 相对音量的回调

 @param volume 产生波动的数值（0-100）
 */
- (void)onUpdateVolume:(int)volume;

/******************************************
 设置AudioSession的委托对象：
 ******************************************/
//语音识别开始和结束时，用来自定义AVAudioSession的方法。
//返回YES则内部默认设置失效，自定义设置生效；如果返回NO或者不实现该方法，则默认设置生效。
- (BOOL)customAudioSessionWhenStart;
- (BOOL)customAudioSessionWhenEnd;

@end


/**
 语义理解的控制类
 */
@interface SogouSemantic : NSObject

@property(nonatomic, weak) id<SogouSemanticDelegate> delegate;


/**
 单例模式

 @return 单例
 */
+ (SogouSemantic*) sharedInstance;


/**
 开始监听

 @return 监听状态
 */
- (BOOL) startListening;

/**
 停止录音，等待语义结果
 */
- (void) stopListening;


/**
 取消本次语义请求
 */
- (void) cancel;


/**
 销毁语义请求相关资源

 @return 销毁是否成功
 */
- (BOOL) destroy;

//外部录音接口
/**
 开始外部录音
 
 @return 监听状态
 */
- (BOOL)startUploadData;

/**
 处理外部录音数据
 */
- (void)processDataWithData:(char *)data length:(int)length;

/**
 停止录音
 */
- (void)stopUploading;

/**
 取消录音
 */
- (void)cancelUploadData;

@end


@interface SogouSemanticSetting : NSObject

/* 
 设置账号密码。（开始识别前，必须设置）
 @param userID:账号； @param key:密码 
 */
+ (void)setUserID:(NSString*)userID andKey:(NSString*)key;

/**
 设置语言类型

 @param area （目前支持普通话0，粤语，英语）
 */
+ (void)setArea:(int)area;

/**
 设置vad头部和尾部的判断时间长度（单位：毫秒。默认为3000ms头部，900ms尾部）

 @param vad_bos 前端点检测；静音超时时间，即用户多长时间不说话则当做超时处理；
 @param vad_eos 后断点检测；后端点静音检测时间，即用户停止说话多长时间内即认为不再输入，自动停止录音.
 */
+ (void) setVadHeadInterval:(int)vad_bos withTailInterval:(int)vad_eos;

/**
 保存音频文件路径；设置此参数后，将会自动保存识别的录音文件。不设置或者设置为nil，则不保存音频

 @param asrAudioPath 文件路径
 */
+ (void) setAsrAudioPath:(NSString*)asrAudioPath;

//  设置录音最多能够录多少秒。

/**
 设置录音时长。

 @param interval 单位秒，默认30秒
 */
+ (void) setMaxRecordInterval:(float)interval;

/**
 保存语音压缩后数据的路径，设置此参数后，将会自动保存录音的压缩文件。不设置或者设置为nil，则不保存。

 @param spxPathStr 压缩后数据路径
 */
+ (void) setSaveSpxPath:(NSString*)spxPathStr;

//选择识别的方式：连续语音识别YES,非连续语音识别NO。默认YES。
//二者区别是：非连续语音识别只在语音结束后返回一个识别结果；
//          连续语音识别是录音过程中持续返回结果。

/**
 选择识别的方式

 @param isContinuous 目前不能设置，只支持连续版
 */
+ (void) setIsContinuous:(BOOL)isContinuous;


/**
 省市

 @param city 省市，默认北京。
 */
+ (void) setCity:(NSString*)city;
+ (void) setProvince:(NSString*) province;

/**
 清空云端的历史记录

 @param clearHistory 是否，默认为否
 */
+ (void) setClearHistory:(BOOL)clearHistory;

/**
 开启语义服务

 @param needSemanticsRes 是否，默认为是
 */
+ (void) setNeedSemanticsRes:(BOOL)needSemanticsRes;

/**
 设置请求地址
 
 @param serverURL 定制化请求地址，URL
 */
+ (void) setServerURL:(NSString*)serverURL;


/**
 设置位置信息

 @param longitude 设置经度，默认116.403875
 @param latitude 设置纬度，默认39.915168
 */
+ (void)setLongitude:(float)longitude andLatitude:(float)latitude;

@end



