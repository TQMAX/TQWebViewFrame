//
//  WKProcessPool+SharedProcessPool.m
//  HFC
//
//  Created by FangRongJie on 2018/7/25.
//  Copyright © 2018年 net.xfxb. All rights reserved.
//

#import "WKProcessPool+SharedProcessPool.h"

@implementation WKProcessPool (SharedProcessPool)
+ (WKProcessPool*)sharedProcessPool {
    
    static WKProcessPool* SharedProcessPool;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        SharedProcessPool = [[WKProcessPool alloc] init];
        
    });
    
    return SharedProcessPool;
    
}
@end
