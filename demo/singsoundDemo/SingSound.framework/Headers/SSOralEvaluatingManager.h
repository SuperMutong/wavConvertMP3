//
//  SSOralEvaluatingManager.h
//  singSoundDemo
//
//  Created by sing on 16/11/18.
//  Copyright © 2016年 an. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSOralEvaluatingConfig.h"
#import "SSOralEvaluatingManagerConfig.h"

@protocol SSOralEvaluatingManagerDelegate;

typedef NS_ENUM(NSInteger, OralEvaluatingType) {
    OralEvaluatingTypeOffLine   = 1,     //离线
    OralEvaluatingTypeLine      = 2,     //在线
    OralEvaluatingTypeMixed     = 3,    //混合模式
};

@interface SSOralEvaluatingManager : NSObject

@property (nonatomic, weak) id<SSOralEvaluatingManagerDelegate> delegate;

+ (instancetype)shareManager;

/**
 返回版本号

 @return 版本号
 */
+ (NSString *)version;

/**
 注册初始化参数

 @param config 初始化参数
 */
+ (void)registerEvaluatingManagerConfig:(SSOralEvaluatingManagerConfig *)config;

/**
 注册全局评测模式

 @param type 评测模式
 */
- (void)registerEvaluatingType:(OralEvaluatingType)type;

/**
 初始化对象

 @param config 初始化参数
 @param type 评测模式
 @return 对象
 */
- (instancetype)initWithManagerConfig:(SSOralEvaluatingManagerConfig *)config type:(OralEvaluatingType)type;

/**
 开始评测

 @param config 评测配置
 */
- (void)startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config;

/**
 开始评测
 
 @param config 评测配置
 @param storeWavPath 音频存储路径
 */
- (void)startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config storeWavPath:(NSString *)storeWavPath;

/**
 开始评测(本地音频文件)
 
 @param wavPath 本地音频文件地址
 */
- (void)startEvaluateOralWithWavPath:(NSString *)wavPath config:(SSOralEvaluatingConfig *)config;

/**
 停止评测，返回结果
 */
- (void)stopEvaluate;

/**
 取消评测
 */
- (void)cancelEvaluate;

/**
 引擎释放
 */
-(void)engineDealloc;

/**
 清除所有录音文件（只针对调用startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config)

 @return YES is Success
 */
+ (BOOL)clearAllRecord;

/**
 返回录音文件地址 （只针对调用startEvaluateOralWithConfig:(SSOralEvaluatingConfig *)config)

 @param tokenId 结果的tokenId
 @return 本地录音路径
 */
+ (NSString *)recordPathWithTokenId:(NSString *)tokenId;
@end


@protocol SSOralEvaluatingManagerDelegate <NSObject>

@optional


/**
 引擎初始化成功
 */
- (void)oralEvaluatingInitSuccess;

/**
 评测开始
 */
- (void)oralEvaluatingDidStart;
/**
 评测停止
 */
- (void)oralEvaluatingDidStop;
/**
 评测完成后的结果
 */
- (void)oralEvaluatingDidEndWithResult: (NSDictionary *)result isLast:(BOOL)isLast;
/**
 评测失败回调
 */
- (void)oralEvaluatingDidEndError: (NSError *)error;

/**
 录音数据回调
 */
- (void)oralEvaluatingRecordingBuffer: (NSData *)recordingData;

/**
 录音音量大小回调
 */
- (void)oralEvaluatingDidUpdateVolume: (int)volume;

/**
 VAD(前置时间）超时回调
 */
- (void)oralEvaluatingDidVADFrontTimeOut;

/**
 VAD(后置时间）超时回调
 */
- (void)oralEvaluatingDidVADBackTimeOut;

/**
 录音即将超时（只支持在线模式，单词20s，句子40s)
 */
- (void)oralEvaluatingDidRecorderWillTimeOut;


@end


