//
//  PickTableViewController.m
//  SpeakTestHelper
//
//  Created by 溫芷榆 on 2017/8/31.
//  Copyright © 2017年 zoe. All rights reserved.
//

#import "PickTableViewController.h"
#import "ExpandCell.h"
#import "TestVC.h"

#define kCell_Height 44
@interface PickTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray      *stateArray;
    UITableView         *expandTable;
}
@property (nonatomic,strong) NSArray * questionList;
@property (nonatomic,strong) NSDictionary * question;

@end

@implementation PickTableViewController
- (void)initDataSource {
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"SpeakingTopic" ofType:@"plist"];
    
    self.questionList = [[NSArray alloc]initWithContentsOfFile:filePath];
    stateArray = [NSMutableArray array];
    for (int i = 0; i < self.questionList.count; i++){
        //當0時 表示所有 section 關起來
        [stateArray addObject:@"0"];
    }
    
    UIImage * image = [UIImage imageNamed:@"back"];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(navigationBackBtnTap)];
    self.navigationItem.leftBarButtonItem = backButton;

    
}
-(void)initTable{
    expandTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 110) style:UITableViewStylePlain];
    expandTable.dataSource = self;
    expandTable.delegate =  self;
    expandTable.tableFooterView = [UIView new];
    [expandTable registerNib:[UINib nibWithNibName:@"ExpandCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:expandTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataSource];
    [self initTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.questionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([stateArray[section] isEqualToString:@"1"]){
        //如果是展開狀態
        NSArray * array = [self.questionList objectAtIndex:section];
        return array.count;
    }else{
        //如果是關起來
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.listLabel.textAlignment = NSTextAlignmentLeft;
    [cell.listLabel sizeToFit];
    cell.listLabel.text = [self questionDic:indexPath][@"Question"];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    TestVC * testVc = [[TestVC alloc] init];
     TestVC * testVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TestVC"];
    testVC.quesDic = [self questionDic:indexPath];
    
//    [self presentViewController:testVC animated:YES completion:nil];
    testVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:testVC animated:YES];
    
}
-(NSDictionary *)questionDic:(NSIndexPath *)indexPath {
    NSString * str = [[NSString alloc] initWithFormat:(@"Question_%ld"),indexPath.row + 1];
    NSDictionary * topic = self.questionList[indexPath.section];
    self.question = topic[str];
    
    return self.question;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // 把section 的位置裝進一個按鈕來控制
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [button setTag:section];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];

    // 底線裝飾
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, button.frame.size.height-1, button.frame.size.width, 1)];
    [line setImage:[UIImage imageNamed:@"line_real"]];
    [button addSubview:line];
    
    // 前面圖案裝飾
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, (kCell_Height-18)/2, 18, 18)];
    [imgView setImage:[UIImage imageNamed:@"ico_faq_d"]];
    [button addSubview:imgView];
    
    UIImageView *_imgView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-30, (kCell_Height-6)/2, 10, 6)];
    
    // 箭頭狀態
    if ([stateArray[section] isEqualToString:@"0"]) {
        _imgView.image = [UIImage imageNamed:@"ico_listdown"];
    }else if ([stateArray[section] isEqualToString:@"1"]) {
        _imgView.image = [UIImage imageNamed:@"ico_listup"];
    }
    [button addSubview:_imgView];
    
    UILabel *tlabel = [[UILabel alloc]initWithFrame:CGRectMake(45, (kCell_Height-20)/2, 200, 20)];
    
    [tlabel setBackgroundColor:[UIColor clearColor]];
    [tlabel setFont:[UIFont systemFontOfSize:14]];
    [tlabel setText:[self sectionTitle:section]];
    [button addSubview:tlabel];
    return button;
}
- (void)buttonPress:(UIButton *)sender {
    
    if ([stateArray[sender.tag] isEqualToString:@"1"]){
        
        [stateArray replaceObjectAtIndex:sender.tag withObject:@"0"];
    }else{
        [stateArray replaceObjectAtIndex:sender.tag withObject:@"1"];
    }
    [expandTable reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

#pragma mark - height for rows
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kCell_Height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(NSString *)sectionTitle:(NSInteger)section{
    NSDictionary * topic = self.questionList[section];
    NSString * str;
    for (int i = 1; i <= topic.count; i++){
        str = [[NSString alloc] initWithFormat:(@"Question_%d"),i];
    }
    NSDictionary * qiz = topic[str];
    
    switch (section) {
        case 0:
            return qiz[@"QusTopic"];
            break;
        case 1:
            return qiz[@"QusTopic"];
            break;
        case 2:
            return qiz[@"QusTopic"];
            break;
        default:
            return @"";
            break;
    }
}
-(void)navigationBackBtnTap{
    NSLog(@"navigationBackBtnTap");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Question List";
}


@end
