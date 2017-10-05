## wav 转码 mp3总结

#### 1. 需求
	最近公司做了一个音频类的 APP, 因为一些业务的原因, 录音的过程是一个第三方提供的 SDK 来做的,具体是怎么录音的不是很清楚, 只是能设置采样频率,而且录音的时候是单声道录音, 而且生成的文件是 wav 文件, 因为 wav 文件大, 不适合用来传输, 所以就碰到了如何转码的需求, 这篇博客就是为了记录我解决这个问题的过程
#### 2. 遇到的问题
		1. SDK 录音方式是单声道, 如何解决转码成的 mp3 是尖锐的变声?
		2. 如何实现实时转码? 
#### 3. 读前准备
		1. 因为我的这篇博客是在别人的基础上添加了自己的一部分理解, 所以别人的博客我就不再照抄一遍了, 建议先去看下下面这篇博客,这篇博客写的真棒, 看完这篇博客之后大部分问题都能解决了, 只是我的两个问题这篇博客没有碰到
				1. http://www.jianshu.com/p/971fff236881
		下面说的解决方法, 我都是以为各位已经看过了前面的那篇博客
#### 4. 问题1: SDK 录音方式是单声道,  如何解决转码成的 mp3 是尖锐的变声?
		碰到很多博客都在说录音的时候要用双声道, 当初也想过让第三方改成双声道录音, 但是尝试了一下自己是否能解决, 发现可以解决, 就没去和人家交涉
	解决方法:
		在用 lame 转码的时候需要设置采样频率和通道数,其实就下面这三行代码, 直接上代码
		

                //设置通道数 1是单声道, 2是双声道
                lame_set_num_channels(lame,1);
                //设置 mp3 编码的采样率
                lame_set_in_samplerate(lame, 16000);
                lame_set_out_samplerate(lame, 16000);
		
	
#### 	5.问题2: 如何实现实时转码? 
	 上面那篇我推荐读者先去看的博客其实也是实现了实时转码, 但是实际跑下来, 发现他总是转少了, 各种跑下来, 发现的问题的缘由, 其实就在在转码的那个 do while 循环在停止转码的时候, 有些转码文件没有写进入, 刚好有些文件没有转码, 所以在 do while 循环以后,我又加了一个 while 循环,来吧那些没能写进入的文件在写进, 核心代码是我自己加的 while  下面是我的代码, 如果觉得看代码不方便的话, 可以直接看 demo, 最下面有我的 demo 链接
	 

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
                
                //核心代码 从下面的代码是我自己加的
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
       最后和手动转码出来的 mp3 文件播放时间都是一样的, 但是和原生的 wav 文件还是差0.0几秒, 暂时还没有找到问题
#### Demo
	为了保持我写的博客的统一性, 没有把第三方 SDK 给剔除出去, 而是直接放在 demo 中上传了 下面是链接地址
	[demo 地址](https://github.com/haitanghuakai/wavConvertMP3)
#### 致谢
	感谢下面的这些博客的博主
	http://chinaxxren.iteye.com/blog/1750296
	http://www.jianshu.com/p/971fff236881
	http://www.jianshu.com/p/57f38f075ba0
