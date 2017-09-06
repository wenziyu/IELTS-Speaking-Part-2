//
//  CoreDataManager.h
//  HelloMyCoreDataManager
//
//  Created by 溫芷榆 on 2017/7/14.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^SaveCompletion)(BOOL success);

@interface CoreDataManager<ItemType> : NSObject

- (instancetype) initWithModel:(NSString *)model
                    dbFileNAme:(NSString *)dbFile
                     dbPathURL:(NSURL *)dbPathUrl
                       sortKey:(NSString *)sortKey
                    entityName:(NSString *)entityName;

- (void)saveContextWithCompletion:(SaveCompletion)completion;

-(NSInteger) count;
//-(NSManagedObject *) createItem;
// 泛型
-(ItemType) createItem;
-(void)deleteItem:(ItemType) item;
-(ItemType) itemWithIndex:(NSInteger)index;
-(NSArray *)searchAtField:(NSString *) field
               forKeyword:(NSString *) keyword;



@end
