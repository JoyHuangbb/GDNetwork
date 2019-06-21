//
//  GDNetworkInterceptorProtocol.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
//  附加的网络请求的插件代理管理类

#import <Foundation/Foundation.h>

@class GDNetworkRequest;
@class GDNetworkResponse;

@protocol GDNetworkInterceptorProtocol <NSObject>

@optional

//得知请求调用成功后先调用该方法通知控制器
- (void)networkRequest:(GDNetworkRequest *)networkRequest beforePerformSuccessWithResponse:(GDNetworkResponse *)networkResponse;

- (void)networkRequest:(GDNetworkRequest *)networkRequest afterPerformSuccessWithResponse:(GDNetworkResponse *)networkResponse;

- (void)networkRequest:(GDNetworkRequest *)networkRequest beforePerformFailWithResponse:(GDNetworkResponse *)networkResponse;

- (void)networkRequest:(GDNetworkRequest *)networkRequest afterPerformFailWithResponse:(GDNetworkResponse *)networkResponse;

@end
