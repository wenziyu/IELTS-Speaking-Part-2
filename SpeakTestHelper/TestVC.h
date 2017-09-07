//
//  TestVC.h
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/8/31.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface TestVC : UIViewController<AVAudioPlayerDelegate,AVAudioRecorderDelegate>

@property (nonatomic,strong)NSDictionary * quesDic;
@property (weak, nonatomic) IBOutlet UIView *contentView;

- (IBAction)recordVoiceButtonPressed:(id)sender;
- (IBAction)playVoiceButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)againButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *startRecordBtn;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UILabel *countLabelTwo;

@property (weak, nonatomic) IBOutlet UIView *playContentView;
@property (weak, nonatomic) IBOutlet UIButton *playVoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *againBtn;

@property (weak, nonatomic) IBOutlet UIView *countContentView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *setTime;
@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;


@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIProgressView *audioProgressBar;




@end
