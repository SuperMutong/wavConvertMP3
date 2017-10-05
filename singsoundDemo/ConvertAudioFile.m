//
//  ConvertAudioFile.m
//  singsoundDemo
//
//  Created by Haitang on 17/8/19.
//  Copyright © 2017年 singsound. All rights reserved.
//

#import "ConvertAudioFile.h"
#import "lame.h"
@implementation ConvertAudioFile
+ (instancetype)sharedInstance {
    static ConvertAudioFile *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConvertAudioFile alloc] init];
    });
    return instance;
}
- (void)realTimeConventToMp3WithCafFilePath:(NSString *)cafFilePath
                                mp3FilePath:(NSString *)mp3FilePath
                                  callBlock:(completeBlock)block{
    __weak typeof(self) weakself = self;
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakself.stopConvert = NO;
            @try {
                
                int read, write;
                
                FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
                fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
                FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
                if (pcm == nil || mp3 == nil) {
                    return;
                }
                
                
                const int PCM_SIZE = 16000 *1.25 +7200;
                const int MP3_SIZE = 16000*1.25 + 7200;
                short int pcm_buffer[PCM_SIZE];
                unsigned char mp3_buffer[MP3_SIZE];
                //初始化 lame 的编码器
                lame_t lame = lame_init();
                //设置通道数 1是单声道, 2是双声道
                lame_set_num_channels(lame,1);
                //设置 mp3 编码的采样率
                lame_set_in_samplerate(lame, 16000);
                lame_set_out_samplerate(lame, 16000);
                //设置 MP3的编码方式
                lame_set_VBR(lame, vbr_default);
                lame_set_mode(lame, MONO);
                //压缩速率
                lame_init_params(lame);
                
                
                
                long curpos;
                BOOL isSkipPCMHeader =  YES;
                long length;
                
                
                do {
                    
                    curpos = ftell(pcm);
                    
                    long startPos = ftell(pcm);
                    
                    fseek(pcm, 0, SEEK_END);
                    long endPos = ftell(pcm);
                    length = endPos - startPos;
                    fseek(pcm, curpos, SEEK_SET);
                    if (length > PCM_SIZE * 1 * sizeof(short int) && length>0) {
                        if (!isSkipPCMHeader) {
                            //Uump audio file header, If you do not skip file header
                            //you will heard some noise at the beginning!!!
                            fseek(pcm, 4 * 1024, SEEK_CUR);
                            isSkipPCMHeader = YES;
                            NSLog(@"skip pcm file header !!!!!!!!!!");
                        }
                        read = (int)fread(pcm_buffer, 1*sizeof(short int), PCM_SIZE, pcm);
                        write = lame_encode_buffer(lame, pcm_buffer, NULL,read, mp3_buffer, MP3_SIZE);
                        //把转化后的 mp3 数据写到文件里
                        fwrite(mp3_buffer,write,1,mp3);
                        NSLog(@"自动转码 read %d   write %d",read,write);
                    }
                    
                    else {
                        [NSThread sleepForTimeInterval:0.05];
                    }
                    
                } while (!self.stopConvert);
                
                curpos = ftell(pcm);
                long startPos = ftell(pcm);
                fseek(pcm, 0, SEEK_END);
                long endPos = ftell(pcm);
                length = endPos - startPos;
                fseek(pcm, curpos, SEEK_SET);
                
                
                while (length > 0){
                    read = (int)fread(pcm_buffer, 1*sizeof(short int), PCM_SIZE, pcm);
                    write = lame_encode_buffer(lame, pcm_buffer, NULL,read, mp3_buffer, MP3_SIZE);
                    fwrite(mp3_buffer,write,1,mp3);
                    NSLog(@"实时转码 read %d   write %d",read,write);
                    
                    curpos = ftell(pcm);
                    long startPos = ftell(pcm);
                    fseek(pcm, 0, SEEK_END);
                    long endPos = ftell(pcm);
                    length = endPos - startPos;
                    fseek(pcm, curpos, SEEK_SET);
                    NSLog(@"实时转码  start:%ld endpos:%ld length %ld ",startPos,endPos,length);
                    
                }
                read = (int)fread(pcm_buffer, 1 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer,write,1,mp3);
                NSLog(@"实时转码 flush read %d  write: %d", read, write);
                //写入 VBR 头文件
                lame_mp3_tags_fid(lame, mp3);
                lame_close(lame);
                fclose(mp3);
                fclose(pcm);
                
                
            }
            @catch (NSException *exception) {
                NSLog(@"实时转码 fail %@", [exception description]);
                block(NO,[exception description]);
            }
            @finally {
                NSLog(@"实时转码 mp3 成功");
                
                block(YES,nil);
            }
        });
}
- (void)handleConventToMp3WithCafFilePath:(NSString *)cafFilePath
                                mp3FilePath:(NSString *)mp3FilePath
                                  callBlock:(completeBlock)block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            int read, write;
            
            FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 16000*1.25 +7200;
            const int MP3_SIZE = 16000*1.25 +7200;
            short int pcm_buffer[PCM_SIZE*1];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 16000);
            lame_set_out_samplerate(lame, 16000);
            lame_set_num_channels(lame,1);
            lame_set_mode(lame, MONO);
            //设置 MP3的编码方式
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                //1是 channel
                read = (int)fread(pcm_buffer, 1*sizeof(short int), PCM_SIZE, pcm);
                
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer(lame, pcm_buffer, NULL,read, mp3_buffer, MP3_SIZE);
                
                //把转化后的 mp3 数据写到文件里
                NSLog(@"手动转码 read %d write %d",read,write);
                fwrite(mp3_buffer,write,1,mp3);
                
            } while (read != 0);
            
            
            long startPos1 = ftell(pcm);
            long endPos1 = ftell(pcm);
            NSLog(@"手动转码 pcm start %ld  end %ld read:%d",startPos1,endPos1,read);
            long mp3startPos1 = ftell(mp3);
            long mp3endPos1 = ftell(mp3);
            long mp3length1 = mp3endPos1 - mp3startPos1;
            NSLog(@"手动转码 mp3 start  end  lenth  %ld  %ld %ld",mp3startPos1,mp3endPos1,mp3length1);
            lame_mp3_tags_fid(lame, mp3);

            
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception description]);
            block(NO,[exception description]);
        }
        @finally {
            block(YES,nil);
            NSLog(@"手动转码 MP3生成成功");
        }
    });
}



@end
