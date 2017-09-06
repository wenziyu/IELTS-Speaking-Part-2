//
//  TabBarVC.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/9/2.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "TabBarVC.h"
#import "CoreDataManager.h"
#import "TestData+CoreDataModel.h"

static TabBarVC * tabBarVC = nil;

@interface TabBarVC ()

@end

@implementation TabBarVC
+(instancetype)shared {
    if (tabBarVC == nil) {
        tabBarVC = [TabBarVC new];
    }
    
    return tabBarVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataManager = [[CoreDataManager alloc]initWithModel:@"TestData" dbFileNAme:@"test.sqlite" dbPathURL:nil sortKey:@"createtime" entityName:@"Testdata"];

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
