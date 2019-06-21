//
//  GDNetworkResponse.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 网络请求状态值
 
 - GDNetworkNotReachableStatus: 网络不可达
 - GDNetworkRequestParamIncorrectStatus: 请求参数错误
 - GDNetworkResponseFailureStatus: 请求失败
 - GDNetworkResponseDataCacheStatus: 允许缓存的接口，取到缓存数据
 - GDNetworkResponseDataIncorrectStatus: 请求返回的数据错误，可能是接口错误等等
 - GDNetworkResponseDataAuthenticationFailStatus: 请求返回的数据没有通过验证
 - GDNetworkResponseDataSuccessStatu: 数据请求成功
 */
typedef NS_ENUM(NSUInteger, GDNetworkStatus) {
    GDNetworkNotReachableStatus,
    GDNetworkRequestParamIncorrectStatus,
    GDNetworkResponseFailureStatus,
    GDNetworkResponseDataCacheStatus,
    GDNetworkResponseDataIncorrectStatus,
    GDNetworkResponseDataAuthenticationFailStatus,
    GDNetworkResponseDataSuccessStatus
};

@interface GDNetworkResponse : NSObject

/**
 请求得到的全部数据
 */
@property (nonatomic, copy,   readonly) id responseData;// 初始数据
@property (nonatomic, assign, readonly) GDNetworkStatus networkStatus;// 该请求的网络状态
@property (nonatomic, assign, readonly) NSInteger requestTag;// 请求的标识
@property (nonatomic, assign, readonly) BOOL isCache;// 是否是缓存数据
@property (nonatomic, copy,   readonly) NSString *responseMessage;//请求无网、失败、参数错误、验证失败的情况，此属性都有值


/**
 设置请求的服务列表(针对后台配置定制，简单的话，就不需要)
 
 如果采取的是后台URL下发机制，即服务端是分布式服务器多并发，可能APP会出现很多不同的域名，此时应将后台下发的URL的JSON传入，并且通过GDNetworkRequestConfigProtocol中的serviceKey去动态获取域名,那么僵忽略GDNetworkConfig的mainBaseUrlString及viceBaseUrlString。
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *urlSeriveDictionary;

- (instancetype)initWithResponseData:(id)responseData
                          requestTag:(NSInteger)requestTag
                       networkStatus:(GDNetworkStatus)networkStatus;

/***  以下属性取决于你服务端返回的数据格式，以及GDNetworkConfig是否设定了对应属性值的key值***/
@property (nonatomic, copy,   readonly) id responseContentData;
@property (nonatomic, assign, readonly) NSInteger responseCode;

@end
