//
//  GDNetworkAgent.h
//  GDoys
//
//  Created by 黄彬彬 on 17/8/17.
//  Copyright © 2017年 GDoys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDNetworkRequest;
@protocol GDNetworkRequestConfigProtocol;

@interface GDNetworkAgent : NSObject

/**
 获取请求操作对象
 
 @return 请求操作对象
 */
+ (GDNetworkAgent *)sharedInstance;


/**
 添加 request 到请求栈中并启动
 
 @param request  请求对象
 */
- (void)addRequest:(__kindof GDNetworkRequest *)request;


/**
 结束 request 请求,并从请求栈中移除
 
 @param request 请求对象
 */
- (void)removeRequest:(__kindof GDNetworkRequest *)request;

@end
