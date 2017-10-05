//
//  ConvertAudioFile.h
//  singsoundDemo
//
//  Created by Haitang on 17/8/19.
//  Copyright © 2017年 singsound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completeBlock)(BOOL result , NSString *errorStr);

@interface ConvertAudioFile : NSObject
@property (nonatomic, assign)   BOOL stopConvert;
@property (nonatomic, copy)     void (^conventResult)(BOOL result);
+ (instancetype)sharedInstance;


/**
 real time convent

 @param cafFilePath <#cafFilePath description#>
 @param mp3FilePath <#mp3FilePath description#>
 @param block <#block description#>
 */
- (void)realTimeConventToMp3WithCafFilePath:(NSString *)cafFilePath
                        mp3FilePath:(NSString *)mp3FilePath
                           callBlock:(completeBlock)block;



/**
 after record, start  convent

 @param cafFilePath <#cafFilePath description#>
 @param mp3FilePath <#mp3FilePath description#>
 @param block <#block description#>
 */
- (void)handleConventToMp3WithCafFilePath:(NSString *)cafFilePath
                                mp3FilePath:(NSString *)mp3FilePath
                                  callBlock:(completeBlock)block;
@end
