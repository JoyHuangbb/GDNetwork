//
//  GDNetworkConfig.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.

#import <Foundation/Foundation.h>
#import "GDNetworkRequest.h"


typedef NSDictionary<NSString *,NSString *>* (^GDNetworkRequestBaseHTTPRequestHeadersBlock)();
typedef NSDictionary<NSString *,NSString *>* (^GDNetworkRequestBaseParamSourceBlock)();
typedef BOOL (^GDNetworkResponseBaseAuthenticationBlock)(GDNetworkRequest *networkRequest, id response);


/******************************************************
 网络配置类（单例）
 *******************************************************/
@interface GDNetworkConfig : NSObject

+ (GDNetworkConfig *)sharedInstance;

@property (nonatomic, copy) NSString *mainBaseUrlString;// 主url
@property (nonatomic, copy) NSString *viceBaseUrlString;// 副url

@property (nonatomic, copy) GDNetworkRequestBaseHTTPRequestHeadersBlock baseHTTPRequestHeadersBlock;
@property (nonatomic, copy) GDNetworkRequestBaseParamSourceBlock baseParamSourceBlock;
@property (nonatomic, copy) GDNetworkResponseBaseAuthenticationBlock baseAuthenticationBlock;


/**
 设置请求的服务列表，如销冠的分布式服务器(针对后台配置定制，简单的话，就不需要)
 
 多服务的时候通过传入该值和调用接口的serviceKey获取不同的服务
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *urlSeriveDictionary;


/**
 默认GDRequestSerializerTypeHTTP（即：[AFHTTPRequestSerializer serializer]）
 */
@property (nonatomic, assign) GDRequestSerializerType requestSerializerType;

/**
 默认SAResponseSerializerTypeJSON (即：[AFJSONResponseSerializer serializer])
 */
@property (nonatomic, assign) GDResponseSerializerType responseSerializerType;

/*** 下面这两个东西我也不知道该怎么说，传输类型？***/
- (void)setAcceptableContentTypes:(NSSet<NSString *> *)acceptableContentTypes
        forResponseSerializerType:(GDResponseSerializerType)responseSerializerType;

- (NSSet<NSString *> *)acceptableContentTypesForResponseSerializerType:(GDResponseSerializerType)responseSerializerType;

/**
 请求超时时间，默认20秒
 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/**
 是否打开debug日志，默认关闭
 */
@property (nonatomic, assign) BOOL enableDebug;

/*******以下属性的设定用于服务端返回数据的第一层格式统一，设定后，便于更深一层的取到数据 *********/
/*** 目前四季青并不支持这么做，销冠可以 ***/
@property (nonatomic, strong) NSString *responseMessageKey;
@property (nonatomic, strong) NSString *responseCodeKey;
@property (nonatomic, strong) NSString *responseContentDataKey;

@end
