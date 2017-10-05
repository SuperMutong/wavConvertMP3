//
//  ViewController.m
//  singsoundDemo
//
//  Created by sing on 17/1/6.
//  Copyright © 2017年 singsound. All rights reserved.
//

#import "ViewController.h"
#import "SingSound/SSOralEvaluatingManager.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "lame.h"
#import "ConvertAudioFile.h"
#import "PlayerManager.h"
#import "NSObject+Print.h"
#pragma mark -CustomButton
@interface CustomButton:UIButton
@end

@implementation CustomButton
- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, 54, contentRect.size.width, contentRect.size.height - 54);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((contentRect.size.width - 45)/2, 0, 45, 45);
}
@end


#pragma mark - ViewController
@interface ViewController ()<SSOralEvaluatingManagerDelegate>
//UI
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UITextField *field;
@property (nonatomic, strong) CustomButton *startButton;
@property (nonatomic, strong) CustomButton *playButton;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UIImageView *animalView;

@property (nonatomic, strong) CustomButton *realTimeButton;
@property (nonatomic, strong) CustomButton *handleButton;


//Data
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSString *currentTokenId;




@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSMutableData *data;



@property (nonatomic, copy) NSString *kOrginName;
@property (nonatomic, copy) NSString *kOrginPicName;
@property (nonatomic, copy) NSString *kChangeMp3Name;
@property (nonatomic, copy) NSString *kChangeMp3UserName;


@end

@implementation ViewController
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupConstrains];
    self.fileManager = [NSFileManager defaultManager];
}



#pragma mark - oralEvaluating
//开始评测
- (void)startOral {
    [_field resignFirstResponder];
    if (_field.text.length == 0) {
        return;
    }
    self.data = nil;

    int rand = random();
//    NSLog(@"rand:%d",rand);
    self.kOrginName = [NSString stringWithFormat:@"%d.wav",rand];
    self.kOrginPicName = [NSString stringWithFormat:@"%d.pcm",rand];
    self.kChangeMp3Name = [NSString stringWithFormat:@"%d.mp3",rand];
    self.kChangeMp3UserName = [NSString stringWithFormat:@"%d.mp3",rand+1];
    
    
    
    [self startAnimation];
    SSOralEvaluatingConfig *config = [[SSOralEvaluatingConfig alloc]init];
    config.oralType = OralTypeParagraph;
    config.oralContent = _field.text;
    config.enableRetry = 1;
    NSString *storePath = [NSString stringWithFormat:@"%@/Documents/ssrecord/%@",NSHomeDirectory(),self.kOrginName];
    [[SSOralEvaluatingManager shareManager] startEvaluateOralWithConfig:config storeWavPath:storePath];
//    NSLog(@"config:%@",config.print);
     [ConvertAudioFile sharedInstance].stopConvert = NO;
//    NSLog(@"korginName%@",storePath);
    
//    if (![self.fileManager fileExistsAtPath:storePath]) {
//        [self.fileManager createFileAtPath:storePath contents:nil attributes:nil];
//    }
//    
    [self realTimeToMp3];
 }
//结束评测
- (void)stopOral {
    NSLog(@"结束评测");
    [self stopAnimation];
    [[SSOralEvaluatingManager shareManager] stopEvaluate];
   
}
//播放录音
- (void)playRecore {
    [ConvertAudioFile sharedInstance].stopConvert = NO;

    NSString *path1 =  [NSString stringWithFormat:@"%@/Documents/ssrecord/%@",NSHomeDirectory(),self.kOrginName];
    //
    //    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path1] error:nil];
    //    self.player.volume = 15;
    //    [self.player prepareToPlay];
    //    [self.player play];
    //
    NSURL *url = [NSURL fileURLWithPath:path1];
    
    [[PlayerManager sharedInstance] playWithVoiceURL:url];

   
    
//    [self handle_PCMtoMP3];
//    [self realTimeToMp3];
    

}

- (void)realTimeplayRecore {
    
    NSString *path1 =  [NSString stringWithFormat:@"%@/Documents/ssrecord/%@",NSHomeDirectory(),self.kChangeMp3Name];
//    
//    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path1] error:nil];
//    self.player.volume = 15;
//    [self.player prepareToPlay];
//    [self.player play];
//    
    NSURL *url = [NSURL fileURLWithPath:path1];
    
    [[PlayerManager sharedInstance] playWithVoiceURL:url];
    
}

- (void)handleplayRecore {
    
    NSString *path1 =  [NSString stringWithFormat:@"%@/Documents/ssrecord/%@",NSHomeDirectory(),self.kChangeMp3UserName];
    
//    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path1] error:nil];
//    self.player.volume = 15;
//    [self.player prepareToPlay];
//    [self.player play];
    NSURL *url = [NSURL fileURLWithPath:path1];
    [[PlayerManager sharedInstance] playWithVoiceURL:url];
    
}

#pragma mark - OralEvaluatingManagerDelegate
/**
 评测完成后的结果
 */
- (void)oralEvaluatingDidEndWithResult:(NSDictionary *)result isLast:(BOOL)isLast {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    NSLog(@"result:%@",result[@"tokenId"]);
//    self.currentTokenId = result[@"tokenId"];
    _scoreLabel.hidden = NO;
    _scoreLabel.text = [NSString stringWithFormat:@"%d",[result[@"result"][@"overall"] intValue]];
    
//    [ConvertAudioFile sharedInstance].stopConvert = YES;
//    [self handle_PCMtoMP3];
    
    [ConvertAudioFile sharedInstance].stopConvert = YES;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self handle_PCMtoMP3];
//    });

}
/**
 录音数据回调
 */
- (void)oralEvaluatingRecordingBuffer:(NSData *)recordingData{
    
//    NSLog(@"recordingDta:%d",(int)recordingData.bytes);
    NSLog(@"----------------------");

 
//    if (![ConvertAudioFile sharedInstance].stopConvert) {
//        [self.data appendData:recordingData];
//        [self.data writeToFile:self.kOrginPicName atomically:YES];
 
//    }
}
#pragma mark  -- 手动转码
- (void)handle_PCMtoMP3
{
    
//    NSString *mp3FileName = self.currentTokenId;
//    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//    NSString *path =  [NSString stringWithFormat:@"%@/Documents/ssrecord/",NSHomeDirectory()];
//
//    NSString *mp3FilePath = [path stringByAppendingPathComponent:mp3FileName];

//    NSString *mp3FileName = @"2";
    
    NSString *mp3FileName = self.kChangeMp3UserName;
    NSString *path =  [NSString stringWithFormat:@"%@/Documents/ssrecord/",NSHomeDirectory()];
    
    NSString *mp3FilePath =  [path stringByAppendingPathComponent:mp3FileName];
    
//    NSLog(@"mp3FilePath%@",mp3FilePath);
    NSString *pcmStr = [[NSString stringWithFormat:@"%@/Documents/ssrecord/",NSHomeDirectory()] stringByAppendingPathComponent:self.kOrginName];
   [[ConvertAudioFile sharedInstance] handleConventToMp3WithCafFilePath:pcmStr mp3FilePath:mp3FilePath callBlock:^(BOOL result, NSString *errorStr) {
       if (!result) {
//           NSLog(@"errorStr:%@",errorStr);
       }
   }];
    
//    @try {
//        int read, write;
//        
//        FILE *pcm = fopen([pcmStr cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
//        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
//        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
//        
//        const int PCM_SIZE = 16000;
//        const int MP3_SIZE = 16000;
//        short int pcm_buffer[PCM_SIZE*1];
//        unsigned char mp3_buffer[MP3_SIZE];
//        
//        lame_t lame = lame_init();
//        lame_set_in_samplerate(lame, 16000);
//        lame_set_out_samplerate(lame, 16000);
//        lame_set_num_channels(lame,1);
//        lame_set_mode(lame, MONO);
//        //设置 MP3的编码方式
//        lame_set_VBR(lame, vbr_default);
//        lame_init_params(lame);
//        
//        do {
//            //1是 channel
//            read = fread(pcm_buffer, 1*sizeof(short int), PCM_SIZE, pcm);
//            if (read == 0)
//                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//            else
//                 write = lame_encode_buffer(lame, pcm_buffer, NULL,read, mp3_buffer, MP3_SIZE);
//            //把转化后的 mp3 数据写到文件里
//            fwrite(mp3_buffer,sizeof(unsigned char),write, mp3);
//            
//        } while (read != 0);
//        NSLog(@"手动转码 read %d bytes and flush to mp3 file", write);
//
//        lame_close(lame);
//        fclose(mp3);
//        fclose(pcm);
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@",[exception description]);
//    }
//    @finally {
//        self.pathStr = mp3FilePath;
//        NSLog(@"MP3生成成功: %@",self.pathStr);
////        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:self.pathStr] error:nil];
////        self.player.volume = 15;
////        [self.player prepareToPlay];
////        [self.player play];
//    }
}

#pragma mark -- 实时转码
- (void)realTimeToMp3 {
    
    NSLog(@"convert begin!!");

   
    
    NSString *mp3FileName = self.kChangeMp3Name;

     NSString *path =  [NSString stringWithFormat:@"%@/Documents/ssrecord/",NSHomeDirectory()];
    
    NSString *mp3FilePath =  [path stringByAppendingPathComponent:mp3FileName];
//     NSLog(@"mp3FilePath%@",mp3FilePath);
    
    NSString *pcmStr = [[NSString stringWithFormat:@"%@/Documents/ssrecord/",NSHomeDirectory()] stringByAppendingPathComponent:self.kOrginName];
    
//    if ([self.fileManager fileExistsAtPath:pcmStr]) {
        [[ConvertAudioFile sharedInstance] realTimeConventToMp3WithCafFilePath:pcmStr mp3FilePath:mp3FilePath callBlock:^(BOOL result, NSString *errorStr) {
            if (!result) {
//                NSLog(@"errorStr:%@",errorStr);
            }
        }];
//    }
//    else{
//        [self realTimeToMp3];
//    }
  
    
    
//    @try {
//        
//        int read, write;
//        
//        FILE *pcm = fopen([pcmStr cStringUsingEncoding:NSASCIIStringEncoding], "rb");
//        if (pcm) {
//            
//        }
//            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
//            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
//            if (pcm == nil || mp3 == nil) {
//                return;
//            }
//            
//            
//            const int PCM_SIZE = 16000;
//            const int MP3_SIZE = 16000;
//            short int pcm_buffer[PCM_SIZE*1];
//            unsigned char mp3_buffer[MP3_SIZE];
//            
//            lame_t lame = lame_init();
//            lame_set_num_channels(lame,1);
//            lame_set_in_samplerate(lame, 16000);
//            lame_set_out_samplerate(lame, 16000);
//            //设置 MP3的编码方式
//            lame_set_VBR(lame, vbr_default);
//            lame_set_mode(lame, MONO);
//            lame_init_params(lame);
//            
//            
//            
//            long curpos;
//            BOOL isSkipPCMHeader = YES;
//            long length;
//            do {
//                
//                curpos = ftell(pcm);
//                
//                long startPos = ftell(pcm);
//                
//                fseek(pcm, 0, SEEK_END);
//                long endPos = ftell(pcm);
//                
//                length = endPos - startPos;
//                
//                fseek(pcm, curpos, SEEK_SET);
//                 NSLog(@"length %ld  %lu",length,PCM_SIZE * 1 * sizeof(short int));
//                if (length > PCM_SIZE * 1 * sizeof(short int)) {
//                    if (!isSkipPCMHeader) {
//                        //Uump audio file header, If you do not skip file header
//                        //you will heard some noise at the beginning!!!
//                        fseek(pcm, 4 * 1024, SEEK_CUR);
//                        isSkipPCMHeader = YES;
//                        NSLog(@"skip pcm file header !!!!!!!!!!");
//                    }
//                    
//                    
//                    //1是 channel
//                    read = (int)fread(pcm_buffer, 1*sizeof(short int), PCM_SIZE, pcm);
//                    write = lame_encode_buffer(lame, pcm_buffer, NULL,read, mp3_buffer, MP3_SIZE);
////                    write = lame_encode_buffer_interleaved(lame, pcm_buffer,read, mp3_buffer, MP3_SIZE);
//
//                    //把转化后的 mp3 数据写到文件里
//                    fwrite(mp3_buffer,write,1,mp3);
//                    NSLog(@"read %d bytes  write %d",read,write);
//                }
//                
//                else {
//                    
//                    [NSThread sleepForTimeInterval:0.05];
//                    NSLog(@"sleep");
//                    
//                }
//                
//            } while (!self.isStopRecorde);
//            curpos = ftell(pcm);
//            NSLog(@"length:%ld",length);
////            long startPos = ftell(pcm);
////            fseek(pcm, 0, SEEK_END);
////            long endPos = ftell(pcm);
////            long length = endPos - startPos;
////            NSLog(@"start  end  lenth  %ld  %ld %ld",startPos,endPos,length);
////            fseek(pcm, curpos, SEEK_SET);
////            NSLog(@"length %ld  %lu",length,PCM_SIZE * 1 * sizeof(short int));
//
//        if (length > 0) {
//            read = (int)fread(pcm_buffer, 1*sizeof(short int), PCM_SIZE, pcm);
//            write = lame_encode_buffer(lame, pcm_buffer, NULL,read, mp3_buffer, MP3_SIZE);
//            //把转化后的 mp3 数据写到文件里
//            fwrite(mp3_buffer,write,1,mp3);
//        }
//        
//        
//        
//            read = (int)fread(pcm_buffer, 1 * sizeof(short int), PCM_SIZE, pcm);
//            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//            NSLog(@"实时转码 read %d bytes and flush to mp3 file", write);
//            lame_mp3_tags_fid(lame, mp3);
//        
//        long startPos1 = ftell(pcm);
//        long endPos1 = ftell(pcm);
//        long length1 = endPos1 - startPos1;
//        NSLog(@"start  end  lenth  %ld  %ld %ld",startPos1,endPos1,length1);
//        
//        
//            lame_close(lame);
//            fclose(mp3);
//            fclose(pcm);
//        }
//    @catch (NSException *exception) {
////        NSLog(@"%@", [exception description]);
//    }
//    @finally {
//        NSLog(@"convert mp3 finish!!!");
//        self.isStopRecorde = YES;
//        [self handle_PCMtoMP3];
//    }
}
- (void)oralEvaluatingDidEndError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    NSLog(@"%@",error);
    [[SSOralEvaluatingManager shareManager] cancelEvaluate];
    [ConvertAudioFile sharedInstance].stopConvert = YES;
}

- (void)oralEvaluatingDidStop {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)oralEvaluatingDidVADBackTimeOut {
    NSLog(@"后置超时");
    [self stopAnimation];
    [[SSOralEvaluatingManager shareManager] stopEvaluate];
}

- (void)oralEvaluatingDidVADFrontTimeOut {
    NSLog(@"前置超时");
    [self stopAnimation];
    [[SSOralEvaluatingManager shareManager] cancelEvaluate];
}

#pragma mark - private
//开始动画
- (void)startAnimation {
    
    _animalView.hidden = NO;
    [_animalView startAnimating];
}

//结束动画
- (void)stopAnimation {
    [self.animalView stopAnimating];
    self.animalView.hidden = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_field resignFirstResponder];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"111" ofType:@"wav"];
    SSOralEvaluatingConfig *config = [[SSOralEvaluatingConfig alloc]init];
    config.oralContent = @"She is doing the laundry";
    config.oralType = OralTypeSentence;
    [[SSOralEvaluatingManager shareManager] startEvaluateOralWithWavPath:path config:config];
}
- (NSMutableData *)data{
    if (!_data) {
        _data = [[NSMutableData alloc]init];
    }
    return _data;
}
- (void)setupView {
    
    //设置代理
    [SSOralEvaluatingManager shareManager].delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _topLabel = [[UILabel alloc]init];
    _topLabel.font = [UIFont systemFontOfSize:15];
    _topLabel.textColor = [UIColor blackColor];
    _topLabel.text = @"评测的单词:";
    [self.view addSubview:_topLabel];
    
    _field = [[UITextField alloc]init];
    _field.layer.borderColor = [UIColor grayColor].CGColor;
    _field.layer.borderWidth = 2;
    _field.text = @"People always think that the babies know nothing about the world, so that they don’t know what they are doing and their mistakes can be forgiven all the time. Actually, according to the new research, the babies have their own recognition, they make judgement by observing parents’ reaction.People always think that the babies know nothing about the world, so that they don’t know what they are doing and their mistakes can be forgiven all the time. Actually, according to the new research, the babies have their own recognition, they make judgement by observing parents’ reaction.";
    _field.keyboardType = UIKeyboardTypeASCIICapable;
    [self.view addSubview:_field];
    
    _scoreLabel = [[UILabel alloc]init];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.backgroundColor = [UIColor greenColor];
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.font = [UIFont systemFontOfSize:17];
    _scoreLabel.layer.cornerRadius = 20;
    _scoreLabel.layer.masksToBounds = YES;
    _scoreLabel.hidden = YES;
    [self.view addSubview:_scoreLabel];
    
    
    _startButton = [self buttonWithTitle:@"点击跟读" imageName:@"_04"];
    [_startButton addTarget:self action:@selector(startOral) forControlEvents:UIControlEventTouchDown];
    [_startButton addTarget:self action:@selector(stopOral) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.view addSubview:_startButton];
    
    _playButton = [self buttonWithTitle:@"我的录音" imageName:@"10"];
    [_playButton addTarget:self action:@selector(playRecore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    
    _realTimeButton = [self buttonWithTitle:@"实时转码录音" imageName:@"10"];
    [_realTimeButton addTarget:self action:@selector(realTimeplayRecore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_realTimeButton];
    
    _handleButton = [self buttonWithTitle:@"手动转码录音" imageName:@"10"];
    [_handleButton addTarget:self action:@selector(handleplayRecore) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_handleButton];
    
    
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 1; i< 15 ; i++) {
        
        NSString *name = [NSString stringWithFormat:@"record_animate_%02d",i];
        UIImage *image = [UIImage imageNamed:name];
        if (image) {
            [images addObject:image];
        }
        
    }
    
    _animalView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 74)];
    [_animalView setAnimationImages:images];
    [_animalView setAnimationDuration:0.0];
    [self.view addSubview:_animalView];
    _animalView.center = self.view.center;
    
}

- (CustomButton *)buttonWithTitle:(NSString *)title imageName:(NSString *)imageName{
    CustomButton *button = [CustomButton new];
    NSAttributedString *attr = [[NSAttributedString alloc]initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                                                                            NSForegroundColorAttributeName : [UIColor greenColor]}];
    [button setAttributedTitle:attr forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    return button;
}

- (void)setupConstrains {
    [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(200);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(100);
    }];
    
    [_field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_topLabel.mas_centerY);
        make.left.mas_equalTo(_topLabel.mas_right).offset(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(30);
    }];
    
    [_scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_field.mas_bottom).offset(20);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    
    CGFloat buttonW = 60;
    CGFloat buttonSpace = (self.view.frame.size.width - 2 * buttonW) / 3;
    
    [_startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_scoreLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(buttonSpace);
        make.size.mas_equalTo(CGSizeMake(buttonW, 80));
    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_scoreLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(_startButton.mas_right).offset(buttonSpace);
        make.size.mas_equalTo(CGSizeMake(buttonW, 80));
    }];
    
    [_realTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_startButton.mas_bottom).offset(20);
        make.left.mas_equalTo(buttonSpace);
        make.size.mas_equalTo(CGSizeMake(buttonW, 80));
    }];
    
    [_handleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_playButton.mas_bottom).offset(20);
        make.left.mas_equalTo(_realTimeButton.mas_right).offset(buttonSpace);
        make.size.mas_equalTo(CGSizeMake(buttonW, 80));
    }];
    
}
@end
