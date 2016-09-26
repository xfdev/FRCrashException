//
//  FRDebugViewController.m
//  FRCrashException
//
//  Created by sonny on 16/9/26.
//  Copyright © 2016年 sonny. All rights reserved.
//

#import "FRDebugViewController.h"

#import "Masonry.h"

#define weakSelf(wSelf)  __weak __typeof(&*self)wSelf = self;
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface FRDebugViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation FRDebugViewController

// 数据较多的情况可以考虑使用另开线程加载
- (void)deployCrashLog {
    
    self.array = [NSMutableArray array];
    
    NSString *logPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"crashLog"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath]) { // 如果存在
        
        // 遍历所有文件并添加文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        // fileList:该文件夹下所有文件数组
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:logPath error:&error];
        NSInteger count = fileList.count;
        // 倒序取文件名
        for (NSInteger i = count - 1; i >= 0; i--) {
            NSString *fileName = [fileList objectAtIndex:i];
            [self.array addObject:fileName];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self deployCrashLog];
    self.navigationItem.title = [NSString stringWithFormat:@"crashLog(%ld)",self.array.count];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:@"•••" style:UIBarButtonItemStylePlain target:self action:@selector(clickRightButton:)];
    self.navigationItem.rightBarButtonItem = barBtn;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
    self.scrollView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    self.scrollView.alpha = 0;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.scrollView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.label.text = @"";
    self.label.numberOfLines = 0;
    self.label.font = [UIFont systemFontOfSize:12];
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *logPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"crashLog"];
    NSString *textPath = [NSString stringWithFormat:@"%@/%@",logPath,[self.array objectAtIndex:indexPath.row]];
    
    NSError *error = nil;
    NSString *crashLog = [[NSString alloc] initWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:&error];
    
    self.label.text = crashLog;
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    weakSelf(wSelf);
    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect rect = wSelf.scrollView.frame;
        rect.size.width = width - 20;
        rect.size.height = height - 20;
        wSelf.scrollView.frame = rect;
        wSelf.scrollView.alpha = 1;
        wSelf.scrollView.center = CGPointMake(width/2, height/2);
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)clickRightButton:(UIBarButtonItem *)item {
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}

- (UIAlertController *)alertController {
    if (_alertController) {
        return _alertController;
    }
    self.alertController = [UIAlertController alertControllerWithTitle:@"操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = self.label.text;
    }];
    
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf(wSelf);
        [UIView animateWithDuration:0.25 animations:^{
            CGRect rect = wSelf.scrollView.frame;
            rect.size.width = SCREEN_WIDTH/2;
            rect.size.height = SCREEN_HEIGHT/2;
            wSelf.scrollView.frame = rect;
            wSelf.scrollView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
            wSelf.scrollView.alpha = 0;
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [self.alertController addAction:copyAction];
    [self.alertController addAction:closeAction];
    [self.alertController addAction:cancelAction];
    
    return _alertController;
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
