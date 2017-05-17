//
//  ViewController.m
//  FYPDBManager
//
//  Created by 凤云鹏 on 2017/5/14.
//  Copyright © 2017年 FYP. All rights reserved.
//

#import "ViewController.h"
#import "FYPDBManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self test];
    
    NSArray *list = [[FYPDBManager sharedFYPDBBase] getAllMessage];
    for (NSDictionary *user in list) {
        NSLog(@"查询的数据:%@",user);
    }
}

- (void)test{
    NSDictionary *user = @{@"UserId":@"20170101",@"LoginId":@"20170101",@"loginPassword":@"fyp111",@"UserName":@"凤云鹏",@"Age":@"19",@"Title":@"插入一条数据"};
    [[FYPDBManager sharedFYPDBBase] insertMessage:user];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
