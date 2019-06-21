//
//  GDNetworkChainRequest.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
/*************************************
 
 链式请求
 
 **************************************/

#import <Foundation/Foundation.h>
#import "GDNetworkAccessoryProtocol.h"

@class GDNetworkChainRequest;
@class GDNetworkRequest;
@class GDNetworkResponse;

@protocol GDNetworkChainRequestResponseDelegate <NSObject>

@optional
- (__kindof GDNetworkRequest *)networkChainRequest:(GDNetworkChainRequest *)chainRequest nextNetworkRequestByNetworkRequest:(__kindof GDNetworkRequest *)request finishedByResponse:(GDNetworkResponse *)response;

- (void)networkChainRequest:(GDNetworkChainRequest *)chainRequest networkRequest:(__kindof GDNetworkRequest *)request failedByResponse:(GDNetworkResponse *)response;

@end

@interface GDNetworkChainRequest : NSObject

@property (nonatomic, weak) id<GDNetworkChainRequestResponseDelegate> delegate;

/**
 初始化链式请求，并且配置一个根请求
 
 @param networkRequest 第一个请求（根请求）
 @return 链式请求对象
 */
- (instancetype)initWithRootNetworkRequest:(__kindof GDNetworkRequest *)networkRequest;

/**
 启动链式请求
 */
- (void)startChainRequest;

/**
 停止链式请求
 */
- (void)stopChainRequest;

/**
 添加实现了GDNetworkAccessoryProtocol的插件对象
 
 @param accessoryDelegate 插件对象
 @warning 务必在启动请求之前就添加插件
 */
- (void)addNetworkAccessoryObject:(id<GDNetworkAccessoryProtocol>)accessoryDelegate;

@end
