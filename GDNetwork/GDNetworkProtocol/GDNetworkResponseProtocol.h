//
//  GDNetworkResponseProtocol.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
//  网络请求的回调代理管理类

#import <Foundation/Foundation.h>

@class GDNetworkRequest;
@class GDNetworkResponse;

@protocol GDNetworkResponseProtocol <NSObject>

@optional

/**
 请求成功的回调
 
 @param networkRequest 请求对象
 @param response 响应的参数
 @warning 若此请求允许缓存，请在此回调中根据response 的isCache 或 networkStatus 属性 做判断处理
 */
- (void)networkRequest:(GDNetworkRequest *)networkRequest succeedByResponse:(GDNetworkResponse *)response;


/**
 请求失败的回调
 
 @param networkRequest 请求对象
 @param response 响应的数据
 */
- (void)networkRequest:(GDNetworkRequest *)networkRequest failedByResponse:(GDNetworkResponse *)response;


/**
 请求进度的回调，一般适用于上传文件
 
 @param networkRequest 请求对象
 @param progress 进度
 */
- (void)networkRequest:(GDNetworkRequest *)networkRequest requestingByProgress:(NSProgress *)progress;

@end
