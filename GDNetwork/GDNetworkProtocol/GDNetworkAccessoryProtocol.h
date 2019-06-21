//
//  GDNetworkAccessoryProtocol.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
//  网络请求的请求插件代理管理类

#import <Foundation/Foundation.h>

/**
 请求插件枚举
 
 - GDNetworkAccessoryFinishStatusSuccess: 成功
 - GDNetworkAccessoryFinishStatusFailure: 失败
 - GDNetworkAccessoryFinishStatusCancel: 取消
 - GDNetworkAccessoryFinishStatusNotReachable: 无法连接
 */
typedef NS_ENUM(NSUInteger, GDNetworkAccessoryFinishStatus) {
    GDNetworkAccessoryFinishStatusSuccess,
    GDNetworkAccessoryFinishStatusFailure,
    GDNetworkAccessoryFinishStatusCancel,
    GDNetworkAccessoryFinishStatusNotReachable
};


/**
 请求插件协议
 */
@protocol GDNetworkAccessoryProtocol <NSObject>

@optional

/**
 请求将要执行
 */
- (void)networkRequestAccessoryWillStart;

/**
 请求已经被执行
 */
- (void)networkRequestAccessoryDidStart;

/**
 请求已经停止
 */
- (void)networkRequestAccessoryDidStop;

/**
 返回请求插件枚举值
 
 @param accessoryStatus 请求插件枚举
 */
- (void)networkRequestAccessoryByStatus:(GDNetworkAccessoryFinishStatus)accessoryStatus;

@end
