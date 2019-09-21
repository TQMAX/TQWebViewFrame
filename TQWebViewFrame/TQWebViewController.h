//
//  TQWebViewController.h
//  TQWebViewFrame
//
//  Created by TQ_Lemon on 2019/9/21.
//  Copyright © 2019 TQ_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 通用web，基于wkwebview
 */

typedef void(^topBtnBlock)(UIButton *);//topBtnBlock

typedef enum {
    foundationType = 0,//基础web(头部默认颜色)
    foundationWhiteBgType = 1,//基础web（白色头部）
    withTopBtnType = 2,//多个webview的跳转需要有关闭和返回按钮(头部默认颜色)
    withTopBtnWhiteBgType = 3
}HFCWebType;

@interface TQWebViewController : UIViewController

@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic,copy) NSString *URL;

@property (nonatomic) HFCWebType type;
@property (nonatomic,assign) BOOL needServer; // 有客服选项
@property (nonatomic,strong) UIButton *topBtn;  //自定义按钮
@property (nonatomic,copy) topBtnBlock newTopBtnBlock;//topBtnBlock

@property (nonatomic,assign) BOOL dontTF; //导航栏不要缩放

@property (nonatomic,assign)BOOL whiteNav;

@end

NS_ASSUME_NONNULL_END
