//
//  ViewController.m
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/14.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import "ViewController.h"
#import "FYPDBManager.h"
#import "User.h"

static NSString *const USERCell = @"USERCell";

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
<UITableViewDelegate,
UITableViewDataSource>
{
    BOOL editState;
}

/** 用户列表数据 */
@property (nonatomic, strong) NSMutableArray * userList;

@property (nonatomic, strong) UITableView * userTable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];
    [self test];
    self.userList = [[[FYPDBManager sharedFYPDBBase] getAllUser] mutableCopy];
    for (NSDictionary *user in self.userList) {
        NSLog(@"查询的数据:%@",user);
    }
}

- (void)setUI
{
    //创建一个导航栏
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 44)];
    //创建一个导航栏集合
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"数据库增删"];
    //在这个集合Item中添加标题，按钮
    //style:设置按钮的风格，一共有三种选择
    //action：@selector:设置按钮的点击事件
    //创建一个右边按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton)];
    //把导航栏集合添加到导航栏中，设置动画关闭
    [navBar pushNavigationItem:navItem animated:YES];
    
    // 把左右两个按钮添加到导航栏集合中去
    [navItem setRightBarButtonItem:rightButton];
    
    // 将导航栏中的内容全部添加到主视图当中
    [self.view addSubview:navBar];
    
    self.userTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];
    self.userTable.dataSource = self;
    self.userTable.bounces = NO;
    self.userTable.delegate = self;
    [self.userTable registerClass:[UITableViewCell class] forCellReuseIdentifier:USERCell];
    self.userTable.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.userTable];
    
    editState = NO;
    [self.userTable setEditing:editState animated:YES];
}

- (void)clickRightButton
{
    editState = !editState;
    /** 使tableView处于编辑状态. */
    [self.userTable setEditing:editState animated:YES];
}

- (void)test{
    NSDictionary *user = @{@"UserID":@"20170100",@"LoginID":@"20170101",@"loginPassword":@"fyp111",@"UserName":@"凤云鹏",@"Age":@"19",@"Title":@"插入一条数据"};
    [[FYPDBManager sharedFYPDBBase] insertUser:[User feedWithDictionary:user]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USERCell forIndexPath:indexPath];
    cell.textLabel.text = [(User*)self.userList[indexPath.row] UserName];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editState)
    {
       return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        User *user = self.userList[indexPath.row];
        [self.userList removeObjectAtIndex:indexPath.row];
        [self.userTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[FYPDBManager sharedFYPDBBase] deleteUserForUserID:user.UserID];

    }else
    {
        NSDictionary *user = @{@"UserID":[@"2017010" stringByAppendingFormat:@"%ld",(long)self.userList.count],@"LoginID":@"20170101",@"loginPassword":@"fyp111",@"UserName":[@"凤云鹏"stringByAppendingFormat:@"%ld",(long)self.userList.count],@"Age":@"19",@"Title":@"插入一条数据"};
        
        NSIndexPath *refreshCell = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [self.userList insertObject:[User feedWithDictionary:user] atIndex:indexPath.row+1];
        [self.userTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:refreshCell, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[FYPDBManager sharedFYPDBBase] insertUser:[User feedWithDictionary:user]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
