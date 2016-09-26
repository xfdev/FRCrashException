//
//  ViewController.m
//  FRCrashException
//
//  Created by sonny on 16/9/22.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import "ViewController.h"

#import "FRDebugViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"Click Me!";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 100, 50);
    button.center = self.view.center;
    [button setTitle:@"click me" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:@"list" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton:)];
    self.navigationItem.rightBarButtonItem = barBtn;
    
}

- (void)clickButton:(UIButton *)button {
    
    NSLog(@"button = %@",button);
    
    NSArray *arr = [NSArray arrayWithObjects:@"1",@"3", nil];
    NSLog(@"0 = %@",[arr objectAtIndex:0]);
    NSLog(@"3 = %@",[arr objectAtIndex:3]);
    
}

- (void)clickRightButton:(UIBarButtonItem *)item {
    
    NSLog(@"item = %@",item);
    
    FRDebugViewController *debug = [[FRDebugViewController alloc] init];
    [self.navigationController pushViewController:debug animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
