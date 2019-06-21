//
//  GDNetworkRequest.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDNetworkAccessoryProtocol.h"
#import "GDNetworkInterceptorProtocol.h"
#import "GDNetworkRequestConfigProtocol.h"
#import "GDNetworkRequestParamSourceProtocol.h"
#import "GDNetworkResponseProtocol.h"

@interface GDNetworkRequest : NSObject

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, weak, readonly) NSObject<GDNetworkRequestConfigProtocol> *requestConfigProtocol;//请求配置代理
@property (nonatomic, weak) id <GDNetworkRequestParamSourceProtocol>requestParamSourceDelegate;//请求参数代理
@property (nonatomic, weak) id <GDNetworkResponseProtocol>responseDelegate;//请求回调代理
@property (nonatomic, weak) id <GDNetworkInterceptorProtocol>interceptorDelegate;//请求插件代理
@property (nonatomic, weak) id <GDNetworkAccessoryProtocol>accessoryDelegate;//请求插件代理


/**
 开始网络请求，使用delegate 方式使用这个方法
 */
- (void)startRequest;


/**
 停止网络请求
 */
- (void)stopRequest;


/**
 添加实现了GDNetworkAccessoryProtocol的插件对象
 
 @param accessoryDelegate 插件对象
 @warning 务必在启动请求之前添加插件。
 */
- (void)addNetworkAccessoryObject:(id<GDNetworkAccessoryProtocol>)accessoryDelegate;

- (void)accessoryFinishByStatus:(GDNetworkAccessoryFinishStatus)status;

@end
