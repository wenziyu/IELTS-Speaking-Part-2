//
//  CollectionVC.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/9/2.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "CollectionVC.h"
#import "CoreDataManager.h"
#import "TestData+CoreDataModel.h"
#import "CollectionCell.h"
#import "CollectionDetailVC.h"
#import "TabBarVC.h"

@interface CollectionVC ()<UITableViewDelegate,UITableViewDataSource>
{
    TabBarVC * tabrVC;
    NSInteger dataCount;
}
@end

@implementation CollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"did %ld",(long)dataCount);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Testdata * item = [tabrVC.dataManager itemWithIndex:indexPath.row];
    cell.lblTitle.text = item.question;
    NSDate * date = item.createtime;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString * stringDate = [dateFormatter stringFromDate:date];
    cell.lblDesc.text = stringDate;

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    CollectionDetailVC * collectionDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionDetailVC"];
    Testdata * item = [tabrVC.dataManager itemWithIndex:indexPath.row];
    NSDate * date = item.createtime;
    NSString * file = item.voice_audio;
    collectionDetailVC.date = date;
    collectionDetailVC.fileName = file;

    [self.navigationController pushViewController:collectionDetailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 102;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:NO];
    tabrVC = [TabBarVC shared];

    dataCount = [tabrVC.dataManager count];
    [self.myTableView reloadData];
    NSLog(@"will %ld",(long)dataCount);
}

@end
