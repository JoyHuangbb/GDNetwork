//
//  GDNetworkRequestConfigProtocol.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
//  网络请求的请求配置代理管理类

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"

/**
 请求方式
 */
typedef NS_ENUM(NSInteger , GDRequestMethod) {
    GDRequestMethodPost = 0,
    GDRequestMethodGet,
};

/**
 服务端接受数据类型
 */
typedef NS_ENUM(NSInteger , GDRequestSerializerType) {
    GDRequestSerializerTypeHTTP = 0,
    GDRequestSerializerTypeJSON,//
    GDRequestSerializerTypePropertyList,
};

/**
 服务端返回的数据类型
 */
typedef NS_ENUM(NSInteger , GDResponseSerializerType) {
    GDResponseSerializerTypeJSON = 0,//
    GDResponseSerializerTypeHTTP,
    GDResponseSerializerTypeXMLParser,
    GDResponseSerializerTypePropertyList,
    GDResponseSerializerTypeImage,
};


/**
 处理正在执行的前一个相同的请求的方式
 
 - GDRequestHandleSameRequestCancelCurrentType: 取消当前的,保留上一个（默认）
 - GDRequestHandleSameRequestCancelPreviousType: 取消上一个,进行当前的
 - GDRequestHandleSameRequestBothContinueType: 保留二者
 */
typedef NS_ENUM(NSInteger , GDRequestHandleSameRequestType) {
    GDRequestHandleSameRequestCancelCurrentType = 0,
    GDRequestHandleSameRequestCancelPreviousType,
    GDRequestHandleSameRequestBothContinueType,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol GDNetworkRequestConfigProtocol <NSObject>


@required

/**
 接口地址,如果返回的是带有http的请求地址,讲自动忽略GDNetworkConfig设置的url
 
 @return 接口地址  ---> @"user/login"
 */
- (NSString *)requestMethodName;

/**
 检查返回数据是否符合与后台约定的结构,这样将在response里的success和failed里面直接使用数据
 
 @param responseData 返回的完整数据
 @return 是否检查
 */
- (BOOL)isCorrectWithResponseData:(id)responseData;


@optional

/**
 属于哪个服务，看具体服务端怎么写，简单的话，不用使用。
 
 @warning 需要注意的是若想取到这个key对应的服务，要配置GDNetworkConfig的urlSeriveDictionary。若取到值以http开头，将忽略GDNetworkConfig的mainBaseUrlString及viceBaseUrlString。
 @return 服务的key
 */
- (NSString *)serviceKey;

/**
 请求方式,默认POST请求
 
 @return 新的请求方式
 */
- (GDRequestMethod)requestMethod;


/**
 定制缓存策略,默认NSURLRequestUseProtocolCachePolicy,建议不用去设置
 
 @return 缓存策略
 */
- (NSURLRequestCachePolicy)cachePolicy;


/**
 请求链接的超时时间,默认为20.0秒
 
 @return 超时时长
 */
- (NSTimeInterval)requestTimeoutInterval;


/**
 检查请求参数,在这个方法里面可以判断请求参数是否符合我们的预期，这么做就是为了VC更大胆的传入参数
 
 @param params 请求参数
 @return 是否执行请求
 */
- (BOOL)isCorrectWithRequestParams:(NSDictionary *)params;


/**
 请求的SerializerType 默认GDRequestSerializerTypeJSON,即服务端接收到的将是json格式,可通过GDNetworkConfig设置默认值
 
 @return 服务端接受数据类型
 */
- (GDRequestSerializerType)requestSerializerType;


/**
 响应数据的responseSerializerType，默认SAResponseSerializerTypeJSON，可通过GDNetworkConfig设置默认值
 
 @return 服务端返回的数据类型
 */
- (GDResponseSerializerType)responseSerializerType;


/**
 请求策略
 
 @return 请求策略
 */
- (NSSet <NSString *> *)responseAcceptableContentTypes;


/**
 当POST的内容带有文件等富文本时使用
 
 @return ConstructingBlock
 */
- (AFConstructingBlock)constructingBodyBlock;


/**
 处理正在执行相同方法的请求的处理方式（参数可能不同）
 
 @warning 最好是在请求的时候阻断用户的页面操作，等待请求返回结构
 @return 处理方式
 */
- (GDRequestHandleSameRequestType)handleSameRequestType;

/**
 *  @brief 可以使用两个根地址，比如可能会用到 CDN 地址、https之类的。默认NO
 *
 *  @return 是否使用副Url
 */

/**
 可以使用两个根地址，比如可能会用到 CDN 地址、https之类的。默认NO
 
 @return 是否使用副Url
 */
- (BOOL)useViceURL;


/**
 很多请求都会需要相同的请求参数,例如token等,可设置GDNetworkConfig的baseParamSourceBlock，这个block会返回你所设置的基础参数。默认YES
 
 @return 是否使用基础参数
 */
- (BOOL)useBaseRequestParamSource;


/**
 GDNetworkConfig设置过baseHTTPRequestHeadersBlock后，可通过此协议方法决定是否使用baseHTTPRequestHeaders，默认使用（YES）
 
 @return 是否使用baseHTTPRequestHeaders
 */
- (BOOL)useBaseHTTPRequestHeaders;


/**
 定制请求头，将摈弃GDNetworkConfig设置过的请求头
 
 @return 新的请求头数据
 */
- (NSDictionary *)customHTTPRequestHeaders;


/**
 是否启用GDNetworkConfig设定的请求验证，若设定了验证的Block，默认使用YES
 
 @return 是否使用基础的请求验证
 */
- (BOOL)useBaseAuthentication;


/**
 定制是否输出log日志
 
 @return 是否输出
 @warning 定制，将忽略GDNetworkConfig的enableDebug
 */
- (BOOL)enableDebugLog;

@end
