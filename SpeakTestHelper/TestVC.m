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
    CoreDataManager<Testdata*> * dataManager;
    
}
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *digitViews;
@property (nonatomic,assign) int totalSeconds;
@property (nonatomic,assign)NSTimer * oneMinTimer;

@property (weak, nonatomic) IBOutlet UILabel *QusLabel;
@property (weak, nonatomic) IBOutlet UITextView *hintTextView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (nonatomic,assign) NSTimeInterval time;
@property (nonatomic, assign)BOOL started;
@property (nonatomic,assign) NSString * videoFilePath;
@property (nonatomic, assign)BOOL save;

@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataManager = [[CoreDataManager alloc]initWithModel:@"TestData" dbFileNAme:@"test.sqlite" dbPathURL:nil sortKey:@"createtime" entityName:@"Testdata"];
    
    
    
    self.QusLabel.text = self.quesDic[@"Question"];
    NSString * replaceHint = [self.quesDic[@"Hint"] stringByReplacingOccurrencesOfString:@"&" withString:@"\n"];
    self.hintTextView.text = replaceHint;
    self.topicLabel.text = self.quesDic[@"QusTopic"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.started = false;
    self.save = false;
    self.playVoiceBtn.hidden = true;
    self.saveBtn.hidden = true;
    
    AVAudioSession *instance=[AVAudioSession sharedInstance];
    if([instance respondsToSelector:@selector(requestRecordPermission:)]){
        [instance requestRecordPermission:^(BOOL granted) {
            
            NSString *message=nil;
            
            if(granted){
                message=@"User granted the permission.";
            }else{
                message=@"User did not grant the permission.";
            }
            
//            UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
//        
//            [alert addAction:ok];
//            [self presentViewController:alert animated:YES completion:nil];
//            
            }];
    }

    [NSTimer scheduledTimerWithTimeInterval:60 repeats:false block:^(NSTimer * _Nonnull timer) {
        if (self.started == false){
            [self prepareRecording];
            [voiceRecorder recordForDuration:120];
            self.startRecordBtn.hidden = true;
        }
    }];
    for (UIView *view in _digitViews)
    {
        UIImage *image = [UIImage imageNamed:@"11.jpg"];
        view.layer.contents = (__bridge id _Nullable)(image.CGImage);
        view.layer.contentsRect = CGRectMake(0, 0, 0.1, 1);
    }
    self.totalSeconds = 60;
    self.oneMinTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self tick];
}
-(void)tick{
       self.totalSeconds --;
    [self setDigit:self.totalSeconds / 10 forView:self.digitViews[0]];
    [self setDigit:self.totalSeconds % 10 forView:self.digitViews[1]];
    
    if ( self.totalSeconds == 0 ) {
        
        [self.oneMinTimer invalidate];
        [self setDigit:0 forView:self.digitViews[0]];
        [self setDigit:0 forView:self.digitViews[1]];
    }
}

-(void)setDigit:(float)digit forView:(UIView *)view {
    view.layer.contentsRect = CGRectMake(digit * 0.1, 0, 0.1, 1.0f);
}
-(void)recordVoiceButtonPressed:(id)sender {
    if([voiceRecorder isRecording]){
        [sender setTitle:@"START" forState:UIControlStateNormal];
        [voiceRecorder stop];
        voiceRecorder=nil;
        self.startRecordBtn.hidden = true;
        self.playVoiceBtn.hidden = false;
        self.saveBtn.hidden = false;
    }else {
        self.started = true;
        voiceRecorder.delegate = self;
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
        [self prepareRecording];
        [voiceRecorder recordForDuration:120];
    }
}

- (IBAction)playVoiceButtonPressed:(id)sender {
    if([voicePlayer isPlaying]){
        [sender setTitle:@"PLAY" forState:UIControlStateNormal];
        [voicePlayer stop];
        voicePlayer=nil;
    }else{
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
        NSString *recordFilePath=[NSString stringWithFormat:@"%@/Documents/%frecord.caf",NSHomeDirectory(),self.time];
        NSURL *recordFileURL=[NSURL fileURLWithPath:recordFilePath];
        voicePlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:recordFileURL error:nil];
        voicePlayer.numberOfLoops = 0;
        [voicePlayer prepareToPlay];
        voicePlayer.delegate = self;
        [voicePlayer play];
    }
}
- (IBAction)saveButtonPressed:(id)sender {
    
    if (self.save == false){
        self.save = true;
        Testdata * testItem = [dataManager createItem];
        testItem.createtime = [NSDate date];
        testItem.qustopic = self.quesDic[@"QusTopic"];
        testItem.question = self.quesDic[@"Question"];
        NSString * recordFilePath = [NSString stringWithFormat:@"%@/Documents/%frecord.caf",NSHomeDirectory(),self.time];
        testItem.voice_audio = recordFilePath;
        [dataManager saveContextWithCompletion:^(BOOL success) {
            if (success){
                NSLog(@"存了！！！！！");
            }
        }];
    }else {
        
        NSString * recordFilePath = [NSString stringWithFormat:@"%@/Documents/%frecord.caf",NSHomeDirectory(),self.time];
        NSArray * result = [dataManager searchAtField:@"voice_audio" forKeyword:recordFilePath];
        [dataManager deleteItem:result.firstObject];
        [dataManager saveContextWithCompletion:^(BOOL success) {
            if (success){
                NSLog(@"刪了也存了！！！！！");
            }
        }];
        self.save = false;
    }
    
}
-(void)audioPlayerDidFinishPlaying: (AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"停了");
    [self.playVoiceBtn setTitle:@"PLAY" forState:UIControlStateNormal];
    [voicePlayer stop];
    voicePlayer=nil;
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"說話啊！！！！！！！");
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    if (error){
        NSLog(@"%@",error);
    }else{
        NSLog(@"說話啊！！！！！！！");
    }
    
}
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
