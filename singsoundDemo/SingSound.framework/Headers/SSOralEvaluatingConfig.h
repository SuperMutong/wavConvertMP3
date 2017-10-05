//
//  SSOralEvaluatingConfig.h
//  singSoundDemo
//
//  Created by sing on 16/11/18.
//  Copyright © 2016年 an. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//评测的题型
typedef NS_ENUM(NSInteger, OralType) {
    OralTypeWord = 1,                               //单词
    OralTypeSentence,                               //语句
    OralTypeParagraph,                              //段落
    OralTypeChoose,                                 //选择题
    OralTypeEssayQuestion,                          //问单题
    OralTypePicture,                                //看图作文
    OralTypeChineseWord,                            //中文单词，只支持在线
    OralTypeChineseSentence,                        //中文句子，只支持在线
};

//评分精确度
typedef NS_ENUM(NSInteger, EvaluatingPrecision) {
    EvaluatingPrecisionMedium,
    EvaluatingPrecisionHigh,
};
//混合模式下强制选择在线评测，离线评测。
typedef NS_ENUM(NSInteger, MixedType) {
    MixedTypeDefault,   //默认情况有网用在线，无网用离线
    MixedTypeOnline,   //强制使用在线
    MixedTypeOffline,   //强制使用离线
};

@class SSOralEvaluatingAnswer;

@interface SSOralEvaluatingConfig : NSObject


/**
 声音格式 defaults is "wav"
 */
@property (nonatomic, strong) NSString *audioType;

/**
 采样率 defaults is 16000,
 Options are 8000,16000,44000.
 */
@property (nonatomic, assign) NSInteger sampleRate;
/**
 题型(必选）
 */
@property (nonatomic, assign) OralType oralType;

/**
 混合模式下强制选择在线评测，离线评测。
 */
@property (nonatomic, assign) MixedType mixedType;


/**
 内容(非必选）
 */
@property (nonatomic, copy) NSString *oralContent;

/**
 分值(非必选 default:100）
 */
@property (nonatomic, assign) NSUInteger rank;

/**
 用户ID(非必选 default:@"this-is-user-id"）
 */
@property (nonatomic, copy) NSString *userId;

/**
 评分精确度(非必选 default:EvaluatingPrecisionHigh）
 */
@property (nonatomic, assign) EvaluatingPrecision precision;

/**
 评分松紧度，范围0.8~1.5，数值越小，打分越严厉
 */
@property (nonatomic, assign) CGFloat rateScale;

/**
 评分松紧度，可传 1，2，3，4。越来越松，1最严格，4最松。和rateScale不能同时传
 */
@property (nonatomic, assign) NSUInteger typeThres;

/**
 答案（非必选）
 */
@property (nonatomic, strong) NSArray<__kindof SSOralEvaluatingAnswer *> *answerArray;

/**
 关键字数组（非必选）
 */
@property (nonatomic, strong) NSArray<__kindof NSString *> *keywordArray;

/**
 问题 （非必选）
 */
@property (nonatomic, strong) NSString *question;

/**
 录音文本（非必选）
 */
@property (nonatomic, strong) NSString *recorderContent;

/**
 句子评测中是否输出每个单词的音标分
 */
@property (nonatomic, assign) BOOL isOutputPhonogramForSentence;

/**
 重传机制类型：
 0是默认值，不重传；
 1表示重传，出现这类异常时，等待测评时间很短，重传不会影响用户体验。
 2表示重传，出现这类异常时，等待测评的时间很长，重传可能会导致用户等待很久。（2包含1重传的情况）
 */
@property (nonatomic, assign) NSInteger enableRetry;

@end




#pragma mark - SSOralEvaluatingAnswer
@interface SSOralEvaluatingAnswer:NSObject

/**
 分值
 */
@property (nonatomic, assign) CGFloat rank;

/**
 答案
 */
@property (nonatomic, strong) NSString *answer;

@end


