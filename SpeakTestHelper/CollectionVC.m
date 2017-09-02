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

@interface CollectionVC ()<UITableViewDelegate,UITableViewDataSource>
{
    CoreDataManager<Testdata*> * dataManager;
    NSInteger dataCount;
}
@end

@implementation CollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    dataManager = [[CoreDataManager alloc]initWithModel:@"TestData" dbFileNAme:@"test.sqlite" dbPathURL:nil sortKey:@"createtime" entityName:@"Testdata"];
    dataCount = [dataManager count];
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
    
    Testdata * item = [dataManager itemWithIndex:indexPath.row];
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
    Testdata * item = [dataManager itemWithIndex:indexPath.row];
    NSDate * date = item.createtime;
    collectionDetailVC.date = date;

    [self.navigationController pushViewController:collectionDetailVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 102;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
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
