//
//  TabBarVC.h
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/9/2.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"
#import "TestData+CoreDataModel.h"

@interface TabBarVC : UITabBarController
{
    CoreDataManager<Testdata*> * dataManager;
}
@end
