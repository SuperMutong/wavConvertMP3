//
//  SSOralEvaluatingManagerConfig.h
//  SingSound
//
//  Created by sing on 17/2/14.
//  Copyright © 2017年 sing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, offLineSource) {
    Word         = 0,     //单词离线资源
    Sentence,             //句子离线资源
    Paragraph,            //段落离线资源
    WordAndSent,          //单词+句子
    SentAndPred,          //句子+段落
    Default,     //默认，单词+句子+段落
};

@interface SSOralEvaluatingManagerConfig : NSObject

/**
 appkey
 */
@property (nonatomic, copy) NSString *appKey;

/**
 secretKey
 */
@property (nonatomic, copy) NSString *secretKey;

/**
 服务器超时时间 default is 60s
 */
@property (nonatomic, assign) NSTimeInterval serverTimeout;

/**
 开启关闭vad,default is NO
 */
@property (nonatomic, assign) BOOL vad;

/**
 vad 前置超时时间
 */
@property (nonatomic, assign) NSTimeInterval frontTime;


/**
 vad 后置超时时间
 
 */
@property (nonatomic, assign) NSTimeInterval backTime;

/**
 logPath log信息路径默认为nil
 */
@property (nonatomic, strong) NSString *logPath;

/**
 logLevel log信息级别，可传@1,@2,@3,@4
 */
@property (nonatomic, strong) NSNumber *logLevel;

/**
 offLineSource 离线资源类型 0单词 1句子 2段落 3单词+句子 4句子+段落 5单词+句子+段落 不传默认5
 */
@property (nonatomic,assign) NSInteger offLineSource;


//cao


@end
