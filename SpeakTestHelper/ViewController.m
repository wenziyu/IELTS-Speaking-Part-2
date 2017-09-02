//
//  ViewController.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/8/30.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "ViewController.h"
#import "PickTableViewController.h"
#import "TestVC.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray * questionList;
@property (weak, nonatomic) IBOutlet UIButton *randomBtn;
@property (weak, nonatomic) IBOutlet UIButton *pickUpBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"SpeakingTopic" ofType:@"plist"];
    
    self.questionList = [[NSArray alloc]initWithContentsOfFile:filePath];
    
//    NSLog(@"%lu",(unsigned long)self.questionList.count);
}
- (IBAction)pressedRandomButton:(id)sender {
    int random = arc4random() % self.questionList.count;
    NSDictionary * randomTopic = self.questionList[random];
    int randomques = arc4random() % randomTopic.count;
    NSString * str = [[NSString alloc] initWithFormat:(@"Question_%d"),randomques + 1];
    NSDictionary * qiz = randomTopic[str];
    
    TestVC * testVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TestVC"];
    testVC.quesDic = qiz;
    
    [self.navigationController pushViewController:testVC animated:YES];
//    [self presentViewController:testVC animated:YES completion:nil];
    
}
- (IBAction)pressedPickUPButton:(id)sender {
    PickTableViewController *add =
    [self.storyboard instantiateViewControllerWithIdentifier:@"PickTableViewController"];
    [self.navigationController pushViewController:add animated:YES];
//    [self presentViewController:add animated:YES completion:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
