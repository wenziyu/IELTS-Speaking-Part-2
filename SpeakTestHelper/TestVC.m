//
//  TestVC.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/8/31.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "TestVC.h"
#import <AVFoundation/AVFoundation.h>
#import "CoreDataManager.h"
#import "TestData+CoreDataModel.h"
#import "TabBarVC.h"

@interface TestVC ()
{
    AVAudioRecorder *voiceRecorder;
    AVAudioPlayer *voicePlayer;
    TabBarVC * tabrVC;
}

// 一分鐘倒數
@property (nonatomic,assign) int totalSeconds;
@property (nonatomic,weak)NSTimer * oneMinTimer;

// 兩分鐘計時
@property (nonatomic,weak)NSTimer * twoMinTimer;
@property (nonatomic,assign) int twoMinSeconds;

// player 倒數
@property (nonatomic,weak)NSTimer * audioTimer;
@property (nonatomic,assign) int audioSeconds;

@property (weak, nonatomic) IBOutlet UILabel *QusLabel;
@property (weak, nonatomic) IBOutlet UITextView *hintTextView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (nonatomic,assign) NSTimeInterval time;
@property (nonatomic,assign) NSTimeInterval audioDuration;
@property (nonatomic,assign) NSString * videoFilePath;
@property (nonatomic, assign) float proValue;

@property (nonatomic, assign)BOOL save;
@property (nonatomic, assign)BOOL started;
@property (nonatomic,assign) BOOL again;
@property (nonatomic,assign) BOOL nevercome;
@property (nonatomic,assign) BOOL play;
@property (nonatomic,assign) BOOL isDraggingTimeSlider;
@property (nonatomic,assign) BOOL isPlaying;

- (IBAction)sliderTouchDown:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)sliderTouchUpInside:(id)sender;



@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tabrVC = [TabBarVC shared];
    
    
    // 題目 label
    self.QusLabel.numberOfLines = 0;
    self.QusLabel.text = self.quesDic[@"Question"];
    NSString * replaceHint = [self.quesDic[@"Hint"] stringByReplacingOccurrencesOfString:@"&" withString:@"\n"];
    self.hintTextView.text = replaceHint;
    self.topicLabel.text = self.quesDic[@"QusTopic"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hintTextView.layoutManager.allowsNonContiguousLayout = NO;
    
    self.playContentView.hidden = true;
    self.started = false;
    self.save = false;
    self.nevercome = true;
    self.play = false;
    self.twoMinSeconds = 1;
    self.isDraggingTimeSlider = false;
    self.audioProgressBar.progress = 0;
    self.audioProgressBar.hidden = true;
    self.countContentView.hidden = true;
    self.progressSlider.hidden = true;
    self.isPlaying = false;
    
    [self fontFamily];
    
    UIImage * image = [UIImage imageNamed:@"back"];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(navigationBackBtnTap)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // requestRecordPermission
    AVAudioSession *instance=[AVAudioSession sharedInstance];
    if([instance respondsToSelector:@selector(requestRecordPermission:)]){
        [instance requestRecordPermission:^(BOOL granted) {
            
            NSString *message=nil;
            
            if(granted){
                message=@"User granted the permission.";
            }else{
                message=@"User did not grant the permission.";
            }
        }];
    }
    
    // 一分鐘倒數的timer
    [self oneMinTimerCount];

}


#pragma mark - one minute count method
- (void)oneMinTimerCount {
    self.totalSeconds = 60;
    self.oneMinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}
-(void)tick {
    
    self.totalSeconds --;
    self.countLabel.text = [NSString stringWithFormat:@"%d",self.totalSeconds / 10];
    self.countLabelTwo.text = [NSString stringWithFormat:@"%d",self.totalSeconds % 10];
    
    if ( self.totalSeconds == 0 ) {
        [self.oneMinTimer invalidate];
        [self prepareRecording];
        [voiceRecorder recordForDuration:135];
        self.started = true;
        [self.startRecordBtn setImage:[UIImage imageNamed:@"stopRecord"] forState:UIControlStateNormal];
        self.contentView.hidden = true;
        [self twoMinuteTimer];
    }
}

#pragma mark - two minute count method
-(void)twoMinuteTimer {
    self.twoMinSeconds = 1;
    self.audioProgressBar.progress = 0.0;
    self.proValue = 0;
    self.twoMinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
    
}
-(void)countTime {
    self.twoMinSeconds ++;
    
    [self lightImageViewSetting];
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.twoMinSeconds]];
    self.setTime.text = [NSString stringWithFormat:@"%@",[self formatTime:135]];
    
    // 1 / 135 = 0.00740 一秒跑這樣
    self.proValue += 0.00740;
    self.audioProgressBar.progress = self.proValue;
    
    // 兩分鐘到了自動停止
    if (self.twoMinSeconds == 135){
        [self.twoMinTimer invalidate];
        // 顯示為02:00/02:00
        self.timeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:135]];
        self.setTime.text = [NSString stringWithFormat:@"%@",[self formatTime:135]];
        self.playContentView.hidden = false;
        self.startRecordBtn.hidden = true;
        self.audioProgressBar.progress = 1;
        // 錄音結束後準備檔案給 player 播放
        [self prepreAudioPath];
    }
}

- (NSString *)formatTime:(int)num{
    int sec = num % 60;
    int min = num / 60;
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
}
- (void) lightImageViewSetting {
    // 給燈提示 一分鐘橘燈 一分半綠燈 兩分鐘紅燈
    if (self.twoMinSeconds == 60){
        self.lightImageView.image = [UIImage imageNamed:@"orange"];
    }else if (self.twoMinSeconds == 65) {
        self.lightImageView.hidden = true;
    }else if (self.twoMinSeconds == 90){
        self.lightImageView.hidden = false;
        self.lightImageView.image = [UIImage imageNamed:@"green"];
    }else if (self.twoMinSeconds == 95){
        self.lightImageView.hidden = true;
    }else if (self.twoMinSeconds == 120){
        self.lightImageView.hidden = false;
        self.lightImageView.image = [UIImage imageNamed:@"red"];
    }else if (self.twoMinSeconds == 125){
        self.lightImageView.hidden = true;
    }

}

#pragma mark - record Voice Button Pressed method
-(void)recordVoiceButtonPressed:(id)sender {
    if([voiceRecorder isRecording]){
        // 按下後停止錄音
        [sender setImage:[UIImage imageNamed:@"startRecord"] forState:UIControlStateNormal];
        [voiceRecorder stop];
        voiceRecorder=nil;
        // 不能再度錄音
        self.playContentView.hidden = false;
        self.startRecordBtn.hidden = true;
        // 錄音結束後準備檔案給 player 播放
        [self prepreAudioPath];
        // 停止計時
        [self.twoMinTimer invalidate];
    }else {
        self.started = true;
        voiceRecorder.delegate = self;
        [sender setImage:[UIImage imageNamed:@"stopRecord"] forState:UIControlStateNormal];
        self.contentView.hidden = true;
        // 停止一分鐘倒數計時
        [self.oneMinTimer invalidate];
        self.countLabel.text = [NSString stringWithFormat:@"%d",6];
        self.countLabelTwo.text = [NSString stringWithFormat:@"%d",0];
        self.countContentView.hidden = false;
        self.audioProgressBar.hidden = false;
        // 開始兩分鐘計時
        [self twoMinuteTimer];
        [self prepareRecording];
        // 開始為期兩分鐘錄音
        [voiceRecorder recordForDuration:135];
        
    }
}
#pragma mark - if user want to record again
- (IBAction)againButtonPressed:(id)sender {
    [sender setImage:[UIImage imageNamed:@"again"] forState:UIControlStateNormal];
    NSString * recordFilePath = [NSString stringWithFormat:@"%frecord.caf",self.time];
    // clean new time for file name
    self.time = 0;
    // 如果 again 之前沒有存檔 則捨棄剛剛的音檔
    if (self.save == false){
        [self deleteVoiceFile:recordFilePath];
    }
    
    self.nevercome = false;
    self.playContentView.hidden = true;
    self.contentView.hidden = false;
    self.startRecordBtn.hidden = false;
    self.progressSlider.hidden = true;
    self.countContentView.hidden = true;
    self.audioProgressBar.hidden = true;
    self.started = false;
    [self oneMinTimerCount];
    [self.saveBtn setImage:[UIImage imageNamed:@"noSave"] forState:UIControlStateNormal];
    self.save = false;
    self.audioProgressBar.progress = 0.0;
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:0]];
}



#pragma mark - play Voice Button Pressed method
- (IBAction)playVoiceButtonPressed:(id)sender {

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.audioProgressBar.hidden = true;
    self.progressSlider.hidden = false;
    
    if([voicePlayer isPlaying]){
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [voicePlayer pause];
        [self removeAudioTimer];

    }else{
        [sender setImage:[UIImage imageNamed:@"stopPlay"] forState:UIControlStateNormal];
        [voicePlayer prepareToPlay];
        [voicePlayer play];
        [self audioDurationTimer];
    }
}
- (void)prepreAudioPath {
    NSString *recordFilePath=[NSString stringWithFormat:@"%@/Documents/%frecord.caf",NSHomeDirectory(),self.time];
    NSURL *recordFileURL=[NSURL fileURLWithPath:recordFilePath];
    voicePlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:recordFileURL error:nil];
    voicePlayer.delegate = self;
    voicePlayer.numberOfLoops = 0;
    self.audioDuration = voicePlayer.duration;
}
-(void)audioDurationTimer {
    [self audioDurationCount];
    self.audioSeconds = 1;
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(audioDurationCount) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];

}
-(void)audioDurationCount {
    CGFloat progressRatio = voicePlayer.currentTime / voicePlayer.duration;
    
    self.audioSeconds ++;
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:voicePlayer.currentTime]];
    
    self.setTime.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];

    if (!self.isDraggingTimeSlider) {
        self.progressSlider.value = progressRatio;
    }
}

-(void)removeAudioTimer {
    [self.audioTimer invalidate];
    self.audioTimer = nil;
}

#pragma mark - save test data to core data method
- (IBAction)saveButtonPressed:(id)sender {
    NSString * recordFilePath = [NSString stringWithFormat:@"/Documents/%frecord.caf",self.time];
    
    if (self.save == false){
        // 如果還沒存 要存
        [sender setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
        self.save = true;
        self.again = false;
        Testdata * testItem = [tabrVC.dataManager createItem];
        testItem.createtime = [NSDate date];
        testItem.qustopic = self.quesDic[@"QusTopic"];
        testItem.question = self.quesDic[@"Question"];
        testItem.voice_audio = recordFilePath;
        [tabrVC.dataManager saveContextWithCompletion:^(BOOL success) {
            if (success){
                NSLog(@"存了！！！！！");
            }
        }];
    }else {
        // 如果又反悔剛剛得存檔 則刪除
        [sender setImage:[UIImage imageNamed:@"noSave"] forState:UIControlStateNormal];
        NSArray * result = [tabrVC.dataManager searchAtField:@"voice_audio" forKeyword:recordFilePath];
        [tabrVC.dataManager deleteItem:result.firstObject];
        [tabrVC.dataManager saveContextWithCompletion:^(BOOL success) {
            if (success){
                NSLog(@"刪了也存了！！！！！");
            }
        }];
        self.save = false;
        self.again = true;
    }
}

#pragma mark - finish record or play method
-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    
    self.progressSlider.value = voicePlayer.duration;
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];
    self.setTime.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];
    [self.playVoiceBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self removeAudioTimer];
    [voicePlayer stop];

}

#pragma mark - prepareRecording file path method
- (void) prepareRecording {
    NSDictionary *settings=
    @{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatAppleIMA4],
      AVSampleRateKey: [NSNumber numberWithFloat:22050.0],
      AVNumberOfChannelsKey:@(1),
      AVLinearPCMBitDepthKey: [NSNumber numberWithInt:16],
      AVLinearPCMIsBigEndianKey: [NSNumber numberWithBool:NO],
      AVLinearPCMIsFloatKey: [NSNumber numberWithBool:NO]};
    
    // Decide Record File Path
    NSDate *date = [NSDate date];
    self.time = [date timeIntervalSince1970];
    
    NSString *recordFilePath=[NSString stringWithFormat:@"%@/Documents/%frecord.caf",NSHomeDirectory(),self.time];
    NSURL *recordFileURL=[NSURL fileURLWithPath:recordFilePath];
    NSLog(@"Record File Path: %@",recordFilePath);
    self.videoFilePath = recordFilePath;
    
    voiceRecorder=[[AVAudioRecorder alloc] initWithURL:recordFileURL settings:settings error:nil];
    
    [voiceRecorder prepareToRecord];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
}

#pragma mark - navigation Back Btn Tap
-(void)navigationBackBtnTap{
    // 確保使用者不是忘了按存檔，可能會添加設定按鈕讓他選擇要不要跳提醒
    if (self.started == true && self.save == false && self.again == true){
        [self alertSetMessage:@"是否儲存剛剛的測驗" settitle:@"即將離開"];
    }
    if (self.nevercome == true && self.started == true && self.save == false){
        [self alertSetMessage:@"是否儲存剛剛的測驗" settitle:@"即將離開"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)deleteVoiceFile:(NSString *)filename {
    // 離開時不想存剛剛的音檔 則刪除
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError * error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"刪掉了喔！！！！");
    }
    else{
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
- (void)alertSetMessage:(NSString *)message settitle:(NSString *)title{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * save = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString * recordFilePath = [NSString stringWithFormat:@"/Documents/%frecord.caf",self.time];
        Testdata * testItem = [tabrVC.dataManager createItem];
        testItem.createtime = [NSDate date];
        testItem.qustopic = self.quesDic[@"QusTopic"];
        testItem.question = self.quesDic[@"Question"];
        
        testItem.voice_audio = recordFilePath;
        [tabrVC.dataManager saveContextWithCompletion:^(BOOL success) {
            if (success){
                NSLog(@"存了！！！！！");
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        NSString * recordFilePath = [NSString stringWithFormat:@"%frecord.caf",self.time];
        [self deleteVoiceFile:recordFilePath];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction:save];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Disappear and shut down all timer
-(void)viewWillDisappear:(BOOL)animated {
    // 離開前先關閉所有timer 和 audio player reocrder
    [self timerInvalidate];
    [voicePlayer stop];
    voicePlayer = nil;
    [voiceRecorder stop];
    voiceRecorder = nil;
}

-(void)timerInvalidate {
    
    [self.oneMinTimer invalidate];
    self.oneMinTimer = nil;
    [self.twoMinTimer invalidate];
    self.twoMinTimer = nil;
    [self.audioTimer invalidate];
    self.audioTimer = nil;
}
-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Test";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fontFamily {
    self.topicLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
    self.QusLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:22];
    self.hintTextView.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
}

#pragma mark - slider methods
- (IBAction)sliderValueChanged:(id)sender {
    // 更新 label 和 player currentTime
    self.timeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.progressSlider.value * voicePlayer.duration]];
    voicePlayer.currentTime = self.progressSlider.value * voicePlayer.duration;
}

- (IBAction)sliderTouchDown:(id)sender {
    // 按下的那剎那 如果正在播放 則暫停播放和時間
    if (voicePlayer.playing){
        self.isPlaying = YES;
        [voicePlayer pause];
        [self removeAudioTimer];
        self.isDraggingTimeSlider = true;

    }else {
        // 如果不是在播放 則暫停時間
        [self removeAudioTimer];
        self.isDraggingTimeSlider = true;
    }
}

- (IBAction)sliderTouchUpInside:(id)sender {
    // 如果剛剛是播放狀態按下 則繼續播放和時間
    if (self.isPlaying == YES){
        [voicePlayer play];
        [self audioDurationTimer];
        self.isDraggingTimeSlider = false;
        self.isPlaying = NO;
    }
}

@end
