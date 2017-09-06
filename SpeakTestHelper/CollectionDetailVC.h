//
//  CollectionDetailVC.h
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/9/2.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CollectionDetailVC : UIViewController

@property (nonatomic,strong) NSDate * date;
@property (nonatomic,strong) NSString * fileName;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (weak, nonatomic) IBOutlet UIButton *audioPlayBtn;
@property (weak, nonatomic) IBOutlet UILabel *countTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioTimeLabel;

@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
- (IBAction)audioPlayButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (IBAction)saveOrNotSavaAction:(id)sender;



@end
