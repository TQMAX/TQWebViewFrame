//
//  WKProcessPool+SharedProcessPool.h
//  HFC
//
//  Created by FangRongJie on 2018/7/25.
//  Copyright © 2018年 net.xfxb. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKProcessPool (SharedProcessPool)
+ (WKProcessPool*)sharedProcessPool;

@end
