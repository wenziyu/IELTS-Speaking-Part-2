//
//  CollectionDetailVC.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/9/2.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "CollectionDetailVC.h"
#import <AVFoundation/AVFoundation.h>
#import "CoreDataManager.h"
#import "TestData+CoreDataModel.h"
#import "TabBarVC.h"


@interface CollectionDetailVC ()<AVAudioPlayerDelegate>
{
    TabBarVC * tabrVC;
}
@property (strong, nonatomic) AVAudioPlayer * audioplayer;
@property (nonatomic,assign) NSTimeInterval floatDate;
@property (nonatomic,strong) NSString * recordFilePath;
@property (nonatomic,weak) NSTimer * audioTimer;
@property (nonatomic,assign) int audioSeconds;
@property (nonatomic,assign) NSTimeInterval audioDuration;
@property (nonatomic,assign) BOOL isDraggingTimeSlider;
@property (nonatomic,assign) BOOL save;
@property (nonatomic,strong) Testdata * thisData;
@property (nonatomic,assign) BOOL isPlaying;

- (IBAction)startSlider:(id)sender;
- (IBAction)endSlide:(id)sender;
- (IBAction)sliderValueChange:(id)sender;
- (IBAction)sliderClick:(UITapGestureRecognizer *)sender;



@end

@implementation CollectionDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    tabrVC = [TabBarVC shared];

    UIImage * image = [UIImage imageNamed:@"back"];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(navigationBackBtnTap)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.questionLabel.numberOfLines = 0;
    self.isDraggingTimeSlider = false;
    self.save = true;
    self.isPlaying = false;

    // use audio file path for select key select from core data
    NSArray * result = [tabrVC.dataManager searchAtField:@"voice_audio" forKeyword:self.fileName];
    for (Testdata * tmp in result){
        // keep this data item for delete
        self.thisData = tmp;
        NSDate * date = tmp.createtime;
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString * stringDate = [dateFormatter stringFromDate:date];

        self.dateLabel.text = stringDate;
        self.topicLabel.text = tmp.qustopic;
        self.questionLabel.text = tmp.question;
        self.recordFilePath = tmp.voice_audio;
    }
    
    // permission for audio player
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

    
    [self prepreAudioPath];
    self.audioTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];
    
}
#pragma mark - prapare for audio path
- (void)prepreAudioPath {
    // combine audio file name with document directory
    NSString * Path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),self.recordFilePath];
    NSURL * recordFileURL = [NSURL fileURLWithPath:Path];
    
    // init audio play (can't init while calling play method if use pause)
    self.audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:recordFileURL error:nil];
    self.audioplayer.delegate = self;
    self.audioplayer.numberOfLoops = 0;
    self.audioDuration = self.audioplayer.duration;

}

- (IBAction)audioPlayButtonPressed:(id)sender {
    // Playback make volum loud
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    if([self.audioplayer isPlaying]){
        [sender setImage:[UIImage imageNamed:@"bigPlay"] forState:UIControlStateNormal];
        [self.audioplayer pause];
        [self removeAudioTimer];

    }else{
        [sender setImage:[UIImage imageNamed:@"bigStop"] forState:UIControlStateNormal];
        [self.audioplayer prepareToPlay];
        [self.audioplayer play];
        [self audioDurationTimer];
    }
}

#pragma mark - timer for slider and time label
-(void)audioDurationTimer {
    [self audioDurationCount];
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(audioDurationCount) userInfo:nil repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];
}
-(void)audioDurationCount {
    self.countTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioplayer.currentTime]];
    
    // 計算進度條比例
    CGFloat progressRatio = self.audioplayer.currentTime / self.audioplayer.duration;

    self.audioSeconds ++;
    self.countTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioplayer.currentTime]];
    self.audioTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];
    
    // updating  slider value when finish dragging
    if (!self.isDraggingTimeSlider) {
        self.progressSlider.value = progressRatio;
    }
}

- (void)removeAudioTimer{
    [self.audioTimer invalidate];
    self.audioTimer = nil;
}
- (NSString *)formatTime:(int)num{
    int sec = num % 60;
    int min = num / 60;
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
}

-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {

    self.progressSlider.value = self.audioDuration;
    self.countTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];
    self.audioTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.audioDuration]];
    
    [self.audioPlayBtn setImage:[UIImage imageNamed:@"bigPlay"] forState:UIControlStateNormal];
    [self removeAudioTimer];
    [self.audioplayer stop];

}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"%@",error);
}

#pragma mark - progress slider action method
- (IBAction)startSlider:(id)sender {
    // if playing pause and stop timer
    if (self.audioplayer.playing){
        self.isPlaying = YES;
        [self.audioplayer pause];
        [self removeAudioTimer];
        self.isDraggingTimeSlider = true;
        
    }else {
        // not playing just stop timer
        [self removeAudioTimer];
        self.isDraggingTimeSlider = true;
    }
}

- (IBAction)endSlide:(id)sender {
    // if playing then keep play and start timer
    if (self.isPlaying == YES){
        [self.audioplayer play];
        [self audioDurationTimer];
        self.isDraggingTimeSlider = false;
        self.isPlaying = NO;
    }
}

- (IBAction)sliderValueChange:(id)sender {
    // 拖曳時 countTimeLabel 時間快數轉換
    self.countTimeLabel.text = [NSString stringWithFormat:@"%@",[self formatTime:self.progressSlider.value * self.audioplayer.duration]];
    self.audioplayer.currentTime = self.progressSlider.value * self.audioplayer.duration;
}

- (IBAction)sliderClick:(UITapGestureRecognizer *)sender {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
    [self setFont];
}

- (void)setFont {
    self.topicLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
    self.questionLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:25];
    self.dateLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17];
}

-(void)navigationBackBtnTap{
    
    if (self.save == false){
        [self deleteVoiceFile:self.recordFilePath];
        [self delectFromCoreData];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated {
    // dont forget to stop all timer and player when leaveing
    [self.audioplayer stop];
    self.audioplayer = nil;
    [self removeAudioTimer];
}


- (IBAction)saveOrNotSavaAction:(id)sender {
    if (self.save == true){
        // 按下後變成不存
        [self.saveBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
        self.save = false;
    }else {
        self.save = true;
        [self.saveBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
}
#pragma mark - delete audio file form file manager
- (void)deleteVoiceFile:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString * Path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),filename];
    NSError * error;
    BOOL success = [fileManager removeItemAtPath:Path error:&error];
    if (success) {
        NSLog(@"刪掉了喔！！！！");
    }else{
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (void) delectFromCoreData {
    [tabrVC.dataManager deleteItem:self.thisData];
    [tabrVC.dataManager saveContextWithCompletion:^(BOOL success) {
        if (success){
            NSLog(@"成功刪除");
        }
    }];
}
@end
