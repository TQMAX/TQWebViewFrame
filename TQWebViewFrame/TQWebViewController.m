//
//  TQWebViewController.m
//  TQWebViewFrame
//
//  Created by TQ_Lemon on 2019/9/21.
//  Copyright © 2019 TQ_Lemon. All rights reserved.
//


// Frame相关宏定义
#define Rect(a,b,c,d) CGRectMake(a, b, c, d)

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height  //屏幕高
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width   //屏幕宽

//获取状态栏的高度
#define getStatusHight  [[UIApplication sharedApplication] statusBarFrame].size.height
//获取导航栏+状态栏的高度
#define getRectNavHight  self.navigationController.navigationBar.frame.size.height
//获取导航栏+状态栏的高度
#define getRectNavAndStatusHight  self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height

// 字体相关宏定义
#define Font(x)  (IS_IOS_VERSION >= 9.0) ? [UIFont fontWithName:@"PingFangSC-Regular" size:x] : [UIFont systemFontOfSize:(x)]
#define FontSystem(x) [UIFont systemFontOfSize:(x)]
#define FontB(x)  [UIFont fontWithName:@"Helvetica-Light" size:x]
#define FontC(x)  [UIFont fontWithName:@"AppleGothic" size:x]
#define FontD(x)  [UIFont fontWithName:@"Arial Rounded MT Bold" size:x]
#define Semibold(x)  (IS_IOS_VERSION >= 9.0) ? [UIFont fontWithName:@"PingFangSC-Semibold" size:x] : [UIFont systemFontOfSize:(x)]
#define FontE(x)  (IS_IOS_VERSION >= 9.0) ? [UIFont fontWithName:@"PingFangSC-Light" size:x] : [UIFont systemFontOfSize:(x)]
#define MediumFont(x) (IS_IOS_VERSION >= 9.0) ? [UIFont fontWithName:@"PingFangSC-Medium" size:x] : [UIFont systemFontOfSize:(x)]

// 系统版本
#define IS_IOS_VERSION   floorf([[UIDevice currentDevice].systemVersion floatValue])
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "TQWebViewController.h"
#import "LMJDropdownMenu.h"
#import "WKProcessPool+SharedProcessPool.h"
#import "UIImage+InsetEdge.h"

@interface TQWebViewController ()<WKUIDelegate,UIScrollViewDelegate,WKNavigationDelegate,CAAnimationDelegate,UIGestureRecognizerDelegate,LMJDropdownMenuDelegate>

@property (nonatomic, strong) UILabel *lb_host;//显示网页提供来源
@property (nonatomic, strong) UIView *webNavigationBar;//自定义bar
@property (nonatomic, strong) UIButton *backBtn;//返回按钮
@property (nonatomic, strong) UILabel *webTitle;//网页标题

@property (nonatomic, assign) CGFloat last_y;//上次滑动的地方
@property (nonatomic, assign) CGFloat begin_y;//开始滑动的地方

@property (nonatomic, strong) UIProgressView *progressView;//进度条
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;//侧滑控制

@property (nonatomic, copy) NSURL *currentUrl;

@property (nonatomic,strong) LMJDropdownMenu *dropdownMenu;

@property (nonatomic,copy)UIColor *topBtnColor;//顶部按钮颜色
@property (nonatomic,copy)NSString *backImgName;//顶部返回按钮图片
@property (nonatomic,copy)NSString *moreImgName;//顶部更多按钮图片
@property (nonatomic,copy)UIColor *topBgColor;//顶部背景颜色

@property (nonatomic, assign) CGFloat webViewHeight;//开始滑动的地方
@property (nonatomic, assign) BOOL allowZoom;//控制缩放

@end

@implementation TQWebViewController{
    UIImage *_saveImage;
    NSString *_qrCodeString;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取默认User-Agent
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    // 给User-Agent添加额外的信息
//    NSString *appAgent = [NSString stringWithFormat:@"%@:%@",@"ios",[HttpTool getSystemVersion]];
//    if (![oldAgent containsString:appAgent]) {
//        NSString *newAgent = [NSString stringWithFormat:@"%@;%@", oldAgent,appAgent ];
//        // 设置global User-Agent
//        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
//        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
//    }
    
    if (_type == foundationType || _type == withTopBtnType ) {
        self.whiteNav = NO;
        _topBtnColor = [UIColor whiteColor];
        _topBgColor = [UIColor lightGrayColor];
        _backImgName = @"homepageBackImage";
        _moreImgName = @"whiteMore";
    }else if (_type == foundationWhiteBgType || _type == withTopBtnWhiteBgType){
        self.whiteNav = YES;
        _topBtnColor = [UIColor blackColor];
        _topBgColor = [UIColor whiteColor];
        _backImgName = @"icon_back_black";
        _moreImgName = @"blackMore";
    }
    self.navigationController.navigationBarHidden = YES;
    self.allowZoom = NO;
    _last_y = 0;
    [self initUI];
    [self loadWebView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//    刷新设置
//    if ([HFCShareInstanceForTypeActivity shareHFCShareInstanceForTypeActivity].needFlashWebView) {
//        [self reloadRequest];
//        [HFCShareInstanceForTypeActivity shareHFCShareInstanceForTypeActivity].needFlashWebView = NO;
//    }
    
    [self.webview.scrollView setDelegate:self];
    [self.webview setNavigationDelegate:self];
    [self.webview setUIDelegate:self];
    
    [_webview addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
    //    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    //    AppLog(@"viewControllers:\n%@",array);
    //    for (UIViewController *vc in array) {
    //        if ([vc isKindOfClass:[HFCCommonWebviewViewController class]]) {
    //            [array removeObject:vc];
    //            self.navigationController.viewControllers = array;
    //            break;
    //        }
    //    }
    
}

#pragma --mark ui
- (void)initUI
{
    _webNavigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, getRectNavAndStatusHight)];
    _webNavigationBar.backgroundColor = _topBgColor;
    [self.view addSubview:_webNavigationBar];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage  imageNamed:_backImgName] forState:UIControlStateNormal];
    _backBtn.frame = CGRectMake(15, getStatusHight, getRectNavHight/23*13, getRectNavHight);
    [_backBtn setTitleColor:_topBtnColor forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(popBackAction) forControlEvents:UIControlEventTouchUpInside];
    [_webNavigationBar addSubview:_backBtn];
    
    _webTitle = [[UILabel alloc]initWithFrame:CGRectMake(40, getStatusHight, SCREEN_WIDTH - 80, getRectNavHight)];
    _webTitle.font = MediumFont(17);
    _webTitle.textAlignment = NSTextAlignmentCenter;
    _webTitle.textColor = _topBtnColor;
    [_webNavigationBar addSubview:_webTitle];
    
    self.webTitle.text = self.title;
//    [self.webTitle wl_changeBaselineOffsetWithTextBaselineOffset:@(6.0) TextFont:Font(20) changeText:@"+"];
    self.view.backgroundColor = HexRGB(0xBDBDC2);
    
    if (_type == withTopBtnType || _type == withTopBtnWhiteBgType) {
        [_topBtn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_webNavigationBar addSubview:_topBtn];
    }else{
        //右上角下拉列表选项
        _dropdownMenu = [[LMJDropdownMenu alloc] init];
        _dropdownMenu.btnImgName = _moreImgName;
        [_dropdownMenu setFrame:CGRectMake(SCREEN_WIDTH - 120, getStatusHight, 120, getRectNavHight)];
        NSMutableArray *titles = [[NSMutableArray alloc]initWithObjects:@"刷新",@"复制链接",@"浏览器打开",nil];
        if (_needServer) {
            [titles addObject:@"联系客服"];
        }
        [_dropdownMenu setMenuTitles:titles rowHeight:50];
        _dropdownMenu.delegate = self;
        [self.view addSubview:_dropdownMenu];
    }
    
    _lb_host = [[UILabel alloc] initWithFrame:CGRectMake(0, getRectNavAndStatusHight + 10, SCREEN_WIDTH, 15)];
    _lb_host.font = Font(10);
    _lb_host.textColor = HexRGB(0x666666);
    [self.view addSubview:_lb_host];
    
//    [_lb_host mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.view).offset(getRectNavAndStatusHight + 10);
//    }];
    
    //    //以下代码适配大小
    //    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    //    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    //    [userContentController addUserScript:wkUScript];
    
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    // 设置偏好设置
    configuration.preferences = [[WKPreferences alloc] init];
    // 默认为0
    configuration.preferences.minimumFontSize = 10;
    // 默认认为YES
    configuration.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    // 通过JS与webview内容交互
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    //获取本地缓存JSESSIONID数据
    //    NSString  *cookieValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"PHPSESSID"];
    //    //拼接Cookie
    //    NSString *cookie = [NSString stringWithFormat:@"document.cookie = 'PHPSESSID=%@;path=/';",cookieValue];
    
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValues = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"document.cookie = '%@=%@;path=/';", key, [cookieDic valueForKey:key]];
        [cookieValues appendString:appendString];
    }
    //通过oc 调用js 方法设置cookies
    WKUserScript * cookieScript = [[WKUserScript alloc]
                                   initWithSource: cookieValues
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    
    [configuration.userContentController addUserScript:cookieScript];
    
    _webview = [[WKWebView alloc] initWithFrame:Rect(0, getRectNavAndStatusHight, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:configuration];
    _webview.UIDelegate = self;
    _webview.scrollView.delegate = self;
    _webview.backgroundColor = [UIColor clearColor];
    _webview.scrollView.backgroundColor = [UIColor clearColor];
    _webview.navigationDelegate = self;
    _webview.opaque = YES;
    _webview.allowsLinkPreview = NO;
    _webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_webview setMultipleTouchEnabled:YES];
    [_webview setAutoresizesSubviews:YES];
    [_webview.scrollView setAlwaysBounceVertical:YES];
    
    //    [self loadWebView];
    [self.view addSubview:_webview];
    
    [_webview insertSubview:_progressView aboveSubview:_webview];
    
    //在用户手指从屏幕左边边缘划入时产生互动
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1;
    longPress.delegate = self;
    [_webview addGestureRecognizer:longPress];
    [self.view addSubview:_webview];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)loadWebView
{
    [_dropdownMenu hideDropDown];
//    if ([Utils isNetworkReachable]) {
//
        NSString *lastUrl =[_URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:lastUrl] cachePolicy:0 timeoutInterval:15.f];
        request.HTTPShouldHandleCookies = YES;
        request.timeoutInterval = 30.0f;
        [request setValue: [self setMyCookies] forHTTPHeaderField:@"Cookie"];
//        [request setValue: [HttpTool getSystemVersion] forHTTPHeaderField:@"Client-Version"];
    
        [_webview loadRequest:request];
//        [self hiddenNonetWork];
//    }else{
//        [self showNonetWork];
//    }
}

- (void)reloadRequest
{
    [_dropdownMenu hideDropDown];
    
//    if ([Utils isNetworkReachable]) {
//        [self hiddenNonetWork];
        [self deleteWebCache];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.URL] cachePolicy:1 timeoutInterval:15.f];
        request.HTTPShouldHandleCookies = YES;
        request.timeoutInterval = 30.0f;
        [request setValue: [self setMyCookies] forHTTPHeaderField:@"Cookie"];
//        [request setValue: [HttpTool getSystemVersion] forHTTPHeaderField:@"Client-Version"];
    
        [_webview loadRequest:request];
        //        [GiFHUD show];
//    }
}

- (void)deleteWebCache {
    //allWebsiteDataTypes清除所有缓存
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
}

- (NSString *)setMyCookies{
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    
    return cookieValue;
}

#pragma mark - WebViewDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    若要拦截跳转，可以在这里拦截
//    _currentUrl = webView.URL;
//    [self webVcToAnyVcCurrentVc:self WkWebView:_webview SuccessStr:_currentUrl.absoluteString];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_dropdownMenu hideDropDown];
    
    self.allowZoom = NO;  //关闭缩放
    
//    AppLog(@"页面加载完成");
//    [GiFHUD dismiss];
    NSString *host = [self.webview.URL.host stringByReplacingOccurrencesOfString:@"www." withString:@""];
    _lb_host.text = [NSString stringWithFormat:@"网页由 %@ 提供", host];
    //    if ([self.webTitle.text isEqualToString:@""]) {
    if (_webview.title.length != 0) {//!IsEmpty(_webview.title)
        self.webTitle.text = _webview.title;
    }
    //    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _webNavigationBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, getRectNavAndStatusHight);
        _webview.frame = Rect(0, getRectNavAndStatusHight, SCREEN_WIDTH, SCREEN_HEIGHT - _webNavigationBar.frame.size.height);
        if (_backBtn.hidden) {
            [self babyCoinFadeAwayWithPosition:CGPointMake(0.5 * SCREEN_WIDTH, getRectNavHight / 2 + getStatusHight) fromValue:0.6 toValue:1];
        }
        _backBtn.hidden = NO;
        _dropdownMenu.hidden = NO;
        _topBtn.hidden = NO;
        
    }];
    
    __block CGFloat webViewHeight;
    //获取内容实际高度（像素）@"document.getElementById(\"content\").offsetHeight;"
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result,NSError * _Nullable error) {
        // 此处js字符串采用scrollHeight而不是offsetHeight是因为后者并获取不到高度，看参考资料说是对于加载html字符串的情况下使用后者可以(@"document.getElementById(\"content\").offsetHeight;")，但如果是和我一样直接加载原站内容使用前者更合适
        //获取页面高度，并重置webview的frame
        webViewHeight = [result doubleValue];
        //        webView.frame.size = CGSizeMake(SCREEN_WIDTH, webViewHeight) ;
        webView.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, webViewHeight + 10);
//        AppLog(@"webViewHeigh=t%f",webViewHeight);
    }];
    _webViewHeight = webViewHeight;
    webView.scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);
    
    // 不执行前段界面弹出列表的JS代码
    [self.webview evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
    
    //取出cookie
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSLog(@"name = %@ value = %@",cookie.name,cookie.value);
    }
    //js函数
    NSString *JSFuncString =
    @"function setCookie(name,value,expires)\
    {\
    var oDate=new Date();\
    oDate.setDate(oDate.getDate()+expires);\
    document.cookie=name+'='+value+';expires='+oDate;\
    }\
    function getCookie(name)\
    {\
    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
    if(arr != null) return unescape(arr[2]); return null;\
    }\
    function delCookie(name)\
    {\
    var exp = new Date();\
    exp.setTime(exp.getTime() - 1);\
    var cval=getCookie(name);\
    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
    }";
    
    //拼凑js字符串
    NSMutableString *JSCookieString = JSFuncString.mutableCopy;
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", cookie.name, cookie.value];
        [JSCookieString appendString:excuteJSString];
    }
    
    NSString *excuteJSString = [NSString stringWithFormat:@"setCookie('%@', '%@', 1);", @"PHPSESSID",[[NSUserDefaults standardUserDefaults] objectForKey:@"PHPSESSID"] ];
    [JSCookieString appendString:excuteJSString];
    //执行js
    [webView evaluateJavaScript:JSCookieString completionHandler:nil];
    
}

//在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame ==nil) {
        [webView loadRequest:navigationAction.request];
    }
    // 没有这一句页面就不会显示
    decisionHandler(WKNavigationActionPolicyAllow);
    NSURLRequest *app = navigationAction.request;
//    AppLog(@"%@",app.allHTTPHeaderFields);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    //    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    //    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    //    NSLog(@"\n====================================\n");
    //    //读取wkwebview中的cookie 方法1
    //    for (NSHTTPCookie *cookie in cookies) {
    //        //        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    //        NSLog(@"wkwebview中的cookie1:%@", cookie);
    //    }
    //    NSLog(@"\n====================================\n");
    //    //读取wkwebview中的cookie 方法2 读取Set-Cookie字段
    //    NSString *cookieString = [[response allHeaderFields] valueForKey:@"Set-Cookie"];
    //    NSLog(@"wkwebview中的cookie2:%@", cookieString);
    //    NSLog(@"\n====================================\n");
    //    //看看存入到了NSHTTPCookieStorage了没有
    //    NSHTTPCookieStorage *cookieJar2 = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    //    for (NSHTTPCookie *cookie in cookieJar2.cookies) {
    //        NSLog(@"NSHTTPCookieStorage中的cookie%@", cookie);
    //    }
    //    NSLog(@"\n====================================\n");
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - ***** 进度条
- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        progressView.tintColor = [UIColor colorWithRed:0.400 green:0.863 blue:0.133 alpha:1.000];
        progressView.trackTintColor = HexRGB(0xBDBDC2);
        [self.webview addSubview:progressView];
        self.progressView = progressView;
    }
    return _progressView;
}

#pragma mark 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [_dropdownMenu hideDropDown];
    
    if (object == self.webview && [keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))])
    {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1)
        {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }
        else
        {
            self.progressView.hidden = YES;//NO
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

#pragma mark - srollview delegate


/**
 控制缩放
 
 @param scrollView
 @return nil
 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if(!self.allowZoom){
        return nil;
    }else{
        return self.webview.scrollView.subviews.firstObject;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _begin_y = _webview.scrollView.contentOffset.y;
    [_dropdownMenu hideDropDown];
}

/**
 *  重写这个代理方法就行了，利用contentOffset这个属性改变frame
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_dontTF) {
        return;
    }
    
    CGFloat currentPostion = scrollView.contentOffset.y;
    
    [_dropdownMenu hideDropDown];
    
    if (currentPostion - _last_y > 10  && currentPostion > 0) {
        _last_y = currentPostion;
        
        [UIView animateWithDuration:0.5 animations:^{
            //            AppLog(@"111SCREEN_WIDTH:%f\n SCREEN_HEIGHT:%f\n getRectNavAndStatusHight:%f\n getStatusHight:%f\n getRectNavHight:%f\n",SCREEN_WIDTH,SCREEN_HEIGHT,getRectNavAndStatusHight,getStatusHight,getRectNavHight);
            _webNavigationBar.frame = CGRectMake(0, -29, SCREEN_WIDTH, getRectNavAndStatusHight);
            _webview.frame = Rect(0, getStatusHight + 15, SCREEN_WIDTH, SCREEN_HEIGHT - getStatusHight - 15);
            //            _webview.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _webViewHeight + 10);
            if (!_backBtn.hidden) {
                [self babyCoinFadeAwayWithPosition:CGPointMake(0.5 * SCREEN_WIDTH, getStatusHight + getRectNavHight * 0.2 + 24) fromValue:1 toValue:0.6];
            }
            _backBtn.hidden = YES;
            _dropdownMenu.hidden = YES;
            _topBtn.hidden = YES;
        }completion:^(BOOL finished) {
            
        }];
        
    }
    else if ((_last_y - currentPostion > 30) && (currentPostion  <= scrollView.contentSize.height-scrollView.bounds.size.height-30) ){
        _last_y = currentPostion;
        [UIView animateWithDuration:0.5 animations:^{
            //            AppLog(@"222SCREEN_WIDTH:%f\n SCREEN_HEIGHT:%f\n getRectNavAndStatusHight:%f\n getStatusHight:%f\n getRectNavHight:%f\n",SCREEN_WIDTH,SCREEN_HEIGHT,getRectNavAndStatusHight,getStatusHight,getRectNavHight);
            _webNavigationBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, getRectNavAndStatusHight);
            _webview.frame = Rect(0, getRectNavAndStatusHight, SCREEN_WIDTH, SCREEN_HEIGHT - _webNavigationBar.frame.size.height);
            //            _webview.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _webViewHeight + 10);
            if (_backBtn.hidden) {
                [self babyCoinFadeAwayWithPosition:CGPointMake(0.5 * SCREEN_WIDTH, getRectNavHight / 2 + getStatusHight) fromValue:0.6 toValue:1];
            }
            _backBtn.hidden = NO;
            _dropdownMenu.hidden = NO;
            _topBtn.hidden = NO;
        }completion:^(BOOL finished) {
            
        }];
        
    }
    /* 往上滑动contentOffset值为正，大多数都是监听这个值来做一些事 */
}

-(void)babyCoinFadeAwayWithPosition:(CGPoint)tagarPosition fromValue:(float)fromValue toValue:(float)toValue
{
    
    //相当与两个动画  合成
    //位置改变
    CABasicAnimation * aniMove = [CABasicAnimation animationWithKeyPath:@"position"];
    aniMove.fromValue = [NSValue valueWithCGPoint:_webNavigationBar.layer.position];
    aniMove.toValue = [NSValue valueWithCGPoint:tagarPosition];//目标中心坐标
    //大小改变
    CABasicAnimation * aniScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    aniScale.fromValue = [NSNumber numberWithFloat:fromValue];//原大小
    aniScale.toValue = [NSNumber numberWithFloat:toValue];//目标大小
    
    CAAnimationGroup * aniGroup = [CAAnimationGroup animation];
    aniGroup.duration = 0.1;//设置动画持续时间
    aniGroup.repeatCount = 1;//设置动画执行次数
    aniGroup.delegate = self;
    aniGroup.animations = @[aniMove,aniScale];
    aniGroup.removedOnCompletion = NO;
    aniGroup.fillMode = kCAFillModeForwards;  //防止动画结束后回到原位
    //    [lable.layer removeAllAnimations];
    [_webTitle.layer addAnimation:aniGroup forKey:@"aniMove_aniScale_groupAnimation"];
    
}
- (void)popBackAction
{
//    [GiFHUD dismiss];
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    // 计算用户手指划了多远
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        [GiFHUD dismiss];
        // 创建过渡对象，弹出viewController
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // 更新 interactive transition 的进度
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // 完成或者取消过渡
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}

#pragma mark - LMJDropdownMenu Delegate

- (void)dropdownMenu:(LMJDropdownMenu *)menu selectedCellNumber:(NSInteger)number{
    NSLog(@"你选择了：%ld",number);
    switch (number) {
            case 0:
            [self reloadRequest];
            break;
            case 1:
            [self copylinkBtnClick];
            break;
            case 2:
            [[UIApplication sharedApplication] openURL:self.currentUrl];
            break;
            case 3:
            [self kefuAction];
            break;
        default:
            break;
    }
}

//topBtnBlock
-(void)topBtnClick:(UIButton *)sender{
    if (self.newTopBtnBlock) {
        self.newTopBtnBlock(sender);
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [sender locationInView:self.webview];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    // 执行对应的JS代码 获取url
    [self.webview evaluateJavaScript:imgJS completionHandler:^(id _Nullable imgUrl, NSError * _Nullable error) {
        if (imgUrl) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
            UIImage *image = [UIImage imageWithData:data];
            if (!image) {
                NSLog(@"读取图片失败");
                return;
            }
            _saveImage = image;
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImageWriteToSavedPhotosAlbum(_saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }];
            UIAlertAction *scan = [UIAlertAction actionWithTitle:@"扫描二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *qrUrl = [NSURL URLWithString:_qrCodeString];
                // Safari打开
                if ([[UIApplication sharedApplication] canOpenURL:qrUrl]) {
                    [self.webview stopLoading];
                    [[UIApplication sharedApplication] openURL:qrUrl];
                }
                // 内部应用打开
                [self.webview loadRequest:[NSURLRequest requestWithURL:qrUrl]];
                
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了取消");
            }];
            
            [actionSheet addAction:save];
            if ([self isAvailableQRcodeIn:image]) {
                [actionSheet addAction:scan];
            }
            [actionSheet addAction:cancel];
            
            [self presentViewController:actionSheet animated:YES completion:nil];
            
        }
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message = @"Succeed";
    if (error) {
        message = @"Fail";
    }
    NSLog(@"save result :%@", message);
//    [SVProgressHUD showSuccessWithStatus:@"保存成功"];
}

- (BOOL)isAvailableQRcodeIn:(UIImage *)img{
    UIImage *image = [img imageByInsetEdge:UIEdgeInsetsMake(-20, -20, -20, -20) withColor:[UIColor lightGrayColor]];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        _qrCodeString = [feature.messageString copy];
        NSLog(@"二维码信息:%@", _qrCodeString);
        return YES;
    } else {
        NSLog(@"无可识别的二维码");
        return NO;
    }
}

/**
 * 复制链接
 */
- (void)copylinkBtnClick {
//    [SVProgressHUD showSuccessWithStatus:@"复制成功!"];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.currentUrl.absoluteString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Viewdealloc {
    @try {
        [self.webview removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    @catch (NSException *exception) {
        NSLog(@"多次删除了");
    }
    
    self.progressView = nil;
    [self.webview stopLoading];
    [self.webview setNavigationDelegate:nil];
    [self.webview.scrollView setDelegate:nil];
    [self.webview setUIDelegate:nil];
//    AppLog(@"jiesu");
}

-(void)viewWillDisappear:(BOOL)animated{
    @try {
        [self.webview removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    @catch (NSException *exception) {
        NSLog(@"多次删除了");
    }
    
    [self.webview.scrollView setDelegate:nil];
    self.progressView = nil;
    [self.webview stopLoading];
    [self.webview setNavigationDelegate:nil];
    [self.webview setUIDelegate:nil];
}

/*!
 *   @author nic, 16-10-24 09:10:10
 *
 *   @brief 客服聊天
 */
- (void)configCustomerService
{
//    HFCMineAssetsModel *user = [GlobalCommen CurrentUser];
//
//    //获取唯一设备标识
//    NSString *deviceIdentifier = [HDeviceIdentifier deviceIdentifier];
//    NSLog(@"唯一设备标识:%@",deviceIdentifier);
//
//    UdeskCustomer *customer = [UdeskCustomer new];
//    customer.sdkToken = deviceIdentifier;
//    customer.cellphone = user.cellphone;
//    customer.customerDescription = @"ios端登录用户";
//
//    //    //初始化sdk
//    [UdeskManager initWithOrganization:APP.organization customer:customer];
}

/**
 在线客服
 */
- (void)kefuAction
{
//    if (IsEmpty(self.verifyLoginStatusStr))
//    {
//        [self presentToLoginActionCurrentVc:self];
//    }else{
//
//        [self configCustomerService];
//        //使用push
//        UdeskSDKManager *chat = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
//        [chat pushUdeskInViewController:self completion:^{
//
//        }];
//    }
}

@end
