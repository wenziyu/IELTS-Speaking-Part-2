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

- (IBAction)recordVoiceButtonPressed:(id)sender;
- (IBAction)playVoiceButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *startRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *playVoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;




@end
