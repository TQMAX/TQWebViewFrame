//
//  ViewController.m
//  TQWebViewFrame
//
//  Created by TQ_Lemon on 2019/9/21.
//  Copyright © 2019 TQ_Lemon. All rights reserved.
//

#import "ViewController.h"
#import "TQWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatUI];
}

-(void)creatUI{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 50);
    [btn setTitle:@"jumpWebView" forState:0];
    [btn setBackgroundColor:[UIColor yellowColor]];
    [btn addTarget:self action:@selector(jumpAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)jumpAction{
    TQWebViewController *webViewVC = [[TQWebViewController alloc]init];
    webViewVC.URL = @"https://www.baidu.com";
    [self.navigationController pushViewController:webViewVC animated:YES];
}
@end
