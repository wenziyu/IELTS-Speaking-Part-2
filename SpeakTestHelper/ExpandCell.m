//
//  ViewController.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/8/30.
//  Copyright © 2017年 zoe. All rights reserved.
//


#import "ExpandCell.h"

@implementation ExpandCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.listLabel.numberOfLines = 0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
