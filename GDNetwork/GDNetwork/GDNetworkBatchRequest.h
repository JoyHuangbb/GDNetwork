//
//  GDNetworkBatchRequest.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
/*************************************
 
 批量请求，批量请求返回的数据将会忽略缓存！
 
 **************************************/

#import <Foundation/Foundation.h>
#import "GDNetworkAccessoryProtocol.h"

@class GDNetworkBatchRequest;
@class GDNetworkResponse;
@class GDNetworkRequest;

@protocol GDNetworkBatchRequestResponseDelegate <NSObject>

@optional
- (void)networkBatchRequest:(GDNetworkBatchRequest *)batchRequest completedByResponseArray:(NSArray<GDNetworkResponse *> *)responseArray;

@end


@interface GDNetworkBatchRequest : NSObject

/**
 初始化一个批量请求
 
 @param requestArray 一个请求的集合
 @return 一个批量请求的操作对象
 */
- (instancetype)initWithRequestArray:(NSArray<GDNetworkRequest *> *)requestArray;


/**
 批量请求的数据返回代理
 */
@property (nonatomic, weak) id<GDNetworkBatchRequestResponseDelegate> delegate;


/**
 当某一个请求错误的时候，其他的请求是否继续，默认YES继续
 */
@property (nonatomic, assign) BOOL isContinueByFailResponse;


/**
 开始网络请求
 */
- (void)startBatchRequest;


/**
 结束网络请求
 */
- (void)stopBatchRequest;


/**
 添加实现了GDNetworkAccessoryProtocol的插件对象
 
 @param accessoryDelegate 插件对象
 @warning 务必在启动请求之前就添加插件
 */
- (void)addNetworkAccessoryObject:(id<GDNetworkAccessoryProtocol>)accessoryDelegate;

@end
