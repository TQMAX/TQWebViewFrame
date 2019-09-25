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
    [btn setBackgroundColor:[UIColor grayColor]];
    [btn addTarget:self action:@selector(jumpAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 200, 100, 50);
    [btn1 setTitle:@"jumpWebView1" forState:0];
    [btn1 setBackgroundColor:[UIColor grayColor]];
    [btn1 addTarget:self action:@selector(jumpAction1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(100, 300, 100, 50);
    [btn2 setTitle:@"jumpWebView2" forState:0];
    [btn2 setBackgroundColor:[UIColor grayColor]];
    [btn2 addTarget:self action:@selector(jumpAction2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

}

-(void)jumpAction{
    TQWebViewController *webViewVC = [[TQWebViewController alloc]init];
    webViewVC.URL = @"https://www.baidu.com";
    [self.navigationController pushViewController:webViewVC animated:YES];
}
    
-(void)jumpAction1{
    TQWebViewController *webViewVC = [[TQWebViewController alloc]init];
    webViewVC.type = foundationWhiteBgType;
    webViewVC.URL = @"https://www.baidu.com";
    [self.navigationController pushViewController:webViewVC animated:YES];
}


-(void)jumpAction2{
    TQWebViewController *webViewVC = [[TQWebViewController alloc]init];
    webViewVC.type = foundationWhiteBgType;
    webViewVC.dontTF = YES;
    webViewVC.URL = @"https://www.baidu.com";
    [self.navigationController pushViewController:webViewVC animated:YES];
}

@end
