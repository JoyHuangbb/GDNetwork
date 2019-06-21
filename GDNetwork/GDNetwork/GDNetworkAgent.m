//
//  GDNetworkAgent.m
//  GDoys
//
//  Created by 黄彬彬 on 17/8/17.
//  Copyright © 2017年 GDoys. All rights reserved.
//

#import "GDNetworkAgent.h"
#import "AFNetworking.h"
#import "GDNetworkConfig.h"
#import "GDNetworkResponse.h"
#import "GDNetworkRequest.h"
#import "GDNetworkLogger.h"

@interface GDNetworkAgent()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

//存放所有的请求对象，以此判断是否存在重复请求
@property (nonatomic, strong) NSMutableDictionary <NSString*, __kindof GDNetworkRequest*>*requestRecordDict;

@end

@implementation GDNetworkAgent

+ (GDNetworkAgent *)sharedInstance {
    static GDNetworkAgent *networkAgentInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkAgentInstance = [[self alloc] init];
    });
    return networkAgentInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestRecordDict = [NSMutableDictionary dictionary];
        //开始监控网络可达性的变化状态。
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
    }
    return self;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 3;//并发最大值
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        jsonResponseSerializer.removesKeysWithNullValues = YES;
        _sessionManager.responseSerializer = jsonResponseSerializer;
        if ([[GDNetworkConfig sharedInstance] acceptableContentTypesForResponseSerializerType:GDResponseSerializerTypeJSON]) {
            _sessionManager.responseSerializer.acceptableContentTypes = [[GDNetworkConfig sharedInstance] acceptableContentTypesForResponseSerializerType:GDResponseSerializerTypeJSON];
        }
    }
    return _sessionManager;
}

#pragma mark-
#pragma mark-处理Request
- (void)addRequest:(__kindof GDNetworkRequest *)request {
    NSString *requestURLString = [self urlStringByRequest:request];
    NSDictionary *requestParam = [self requestParamByRequest:request];
    
    //检查参数
    if (![self isCorrectByRequestParams:requestParam request:request]) {
        NSLog(@"参数配置有误！请查看isCorrectWithRequestParams: !");
        [request stopRequest];
        [request accessoryFinishByStatus:GDNetworkAccessoryFinishStatusCancel];
        GDNetworkResponse *paramIncorrectResponse = [[GDNetworkResponse alloc] initWithResponseData:nil
                                                                                           requestTag:request.tag
                                                                                        networkStatus:GDNetworkRequestParamIncorrectStatus];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:paramIncorrectResponse];
        }
        return;
    }
    
    GDRequestHandleSameRequestType handleSameRequestType = [self handleSameRequestTypeByRequest:request];
    if (handleSameRequestType != GDRequestHandleSameRequestBothContinueType) {
        //检查是否存在相同的请求方法未完成，并根据协议接口决定是否结束某个请求
        BOOL isContinuePerform = YES;
        for (GDNetworkRequest<GDNetworkRequestConfigProtocol> *requestingObj in self.requestRecordDict.allValues) {
            if ([[self urlStringByRequest:requestingObj] isEqualToString:requestURLString]) {
                switch (handleSameRequestType) {
                    case GDRequestHandleSameRequestCancelCurrentType: {
                        isContinuePerform = NO;
                    } break;
                        
                    case GDRequestHandleSameRequestCancelPreviousType: {
                        [requestingObj stopRequest];
                        [requestingObj accessoryFinishByStatus:GDNetworkAccessoryFinishStatusCancel];
                    } break;
                        
                    default: break;
                }
                break;
            }
        }
        
        if (isContinuePerform == NO){
            NSLog(@"有个相同URL请求未完成，这个请求被取消了（可设置handleSameRequestType）");
            [request stopRequest];
            [request accessoryFinishByStatus:GDNetworkAccessoryFinishStatusCancel];
            return;
        }
    }
    
    //定制是否输出log日志(单独的接口定制和全局定制)
    if ([request respondsToSelector:@selector(enableDebug)]) {
        if ([request enableDebugLog]) {
            [GDNetworkLogger logDebugRequestInfoWithURL:requestURLString
                                              httpMethod:[self requestMethodByRequest:request]
                                                  params:requestParam
                                      reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
        }
    }else if ([GDNetworkConfig sharedInstance].enableDebug) {
        [GDNetworkLogger logDebugRequestInfoWithURL:requestURLString
                                          httpMethod:[self requestMethodByRequest:request]
                                              params:requestParam
                                  reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
    }
    
    //开始调用AF发起请求
    __weak typeof(self)weakSelf = self;
    [self setupSessionManagerRequestSerializerByRequest:request];
    __block GDNetworkRequest<GDNetworkRequestConfigProtocol> *blockRequest = request;
    switch ([self requestMethodByRequest:request]) {
        case GDRequestMethodGet:{
            request.sessionDataTask = [self.sessionManager GET:requestURLString
                                                    parameters:requestParam
                                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                                          [weakSelf handleRequestProgress:downloadProgress request:blockRequest];
                                                      }
                                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                           [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                       }
                                                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                           [weakSelf handleRequestFailure:task error:error];
                                                       }];
        } break;
            
        case GDRequestMethodPost:{
            AFConstructingBlock constructingBlock = [self constructingBlockByRequest:request];
            if (constructingBlock) {
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                          constructingBodyWithBlock:constructingBlock
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                               [weakSelf handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [weakSelf handleRequestFailure:task error:error];
                                                            }];
            }else{
                request.sessionDataTask = [self.sessionManager POST:requestURLString
                                                         parameters:requestParam
                                                           progress:^(NSProgress * _Nonnull uploadProgress) {
                                                               [weakSelf handleRequestProgress:uploadProgress request:blockRequest];
                                                           }
                                                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [weakSelf handleRequestSuccess:task responseObject:responseObject];
                                                            }
                                                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [weakSelf handleRequestFailure:task error:error];
                                                            }];
            }
        } break;
            
        default: break;
    }
    [self addRequestObject:request];
}


- (void)removeRequest:(__kindof GDNetworkRequest *)request {
    [request.sessionDataTask cancel];
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        [_requestRecordDict removeObjectForKey:taskKey];
    }
}

#pragma mark-
#pragma mark-处理请求响应结果

//在响应失败之前
- (void)beforePerformFailWithResponse:(GDNetworkResponse *)response request:(GDNetworkRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformFailWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request beforePerformFailWithResponse:response];
    }
}

//在响应失败后
- (void)afterPerformFailWithResponse:(GDNetworkResponse *)response request:(GDNetworkRequest *)request{
    if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformFailWithResponse:)]) {
        [request.interceptorDelegate networkRequest:request afterPerformFailWithResponse:response];
    }
}

//回调进度时
- (void)handleRequestProgress:(NSProgress *)progress request:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:requestingByProgress:)]) {
        [request.responseDelegate networkRequest:request requestingByProgress:progress];
    }
}

//根据AF返回的请求成功的Task响应
- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)response {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    GDNetworkRequest<GDNetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    [request stopRequest];
    if (request == nil){
        NSLog(@"请求实例被意外释放!");
        return;
    }
    
    //验证请求头和请求数据
    BOOL isAuthentication = YES;
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseAuthentication)] || [request.requestConfigProtocol useBaseAuthentication]) && [GDNetworkConfig sharedInstance].baseAuthenticationBlock) {
        isAuthentication = [GDNetworkConfig sharedInstance].baseAuthenticationBlock(request,response);
    }
    
    if(isAuthentication && [request.requestConfigProtocol isCorrectWithResponseData:response]) {
        [request accessoryFinishByStatus:GDNetworkAccessoryFinishStatusSuccess];
        GDNetworkResponse *successResponse = [[GDNetworkResponse alloc] initWithResponseData:response
                                                                                    requestTag:request.tag
                                                                                 networkStatus:GDNetworkResponseDataSuccessStatus];
        if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:beforePerformSuccessWithResponse:)]) {
            [request.interceptorDelegate networkRequest:request beforePerformSuccessWithResponse:response];
        }
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:succeedByResponse:)]) {
            [request.responseDelegate networkRequest:request succeedByResponse:successResponse];
        }
        if ([request.interceptorDelegate respondsToSelector:@selector(networkRequest:afterPerformSuccessWithResponse:)]) {
            [request.interceptorDelegate networkRequest:request afterPerformSuccessWithResponse:response];
        }
    } else {
        [request accessoryFinishByStatus:GDNetworkAccessoryFinishStatusFailure];
        GDNetworkResponse *dataErrorResponse = [[GDNetworkResponse alloc] initWithResponseData:response
                                                                                      requestTag:request.tag
                                                                                   networkStatus:isAuthentication ? GDNetworkResponseDataIncorrectStatus : GDNetworkResponseDataAuthenticationFailStatus];
        [self beforePerformFailWithResponse:dataErrorResponse request:request];
        if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
            [request.responseDelegate networkRequest:request failedByResponse:dataErrorResponse];
        }
        [self afterPerformFailWithResponse:dataErrorResponse request:request];
    }
    
    //打印成功的信息
    if ([request respondsToSelector:@selector(enableDebug)]) {
        if ([request enableDebugLog]) {
            [GDNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask
                                                       responseObject:response
                                                       authentication:isAuthentication
                                                                error:nil];
        }
    }else if ([GDNetworkConfig sharedInstance].enableDebug) {
        [GDNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask
                                                   responseObject:response
                                                   authentication:isAuthentication
                                                            error:nil];
    }
}

//根据AF返回的请求失败的Task响应
- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *taskKey = [self keyForSessionDataTask:sessionDataTask];
    GDNetworkRequest<GDNetworkRequestConfigProtocol> *request = _requestRecordDict[taskKey];
    [request stopRequest];
    [request accessoryFinishByStatus:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable ? GDNetworkAccessoryFinishStatusNotReachable : GDNetworkAccessoryFinishStatusFailure];
    if (request == nil) {
        NSLog(@"请求实例被意外释放!");
        return;
    }
    GDNetworkResponse *failureResponse = [[GDNetworkResponse alloc] initWithResponseData:nil requestTag:request.tag networkStatus:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable ? GDNetworkNotReachableStatus : GDNetworkResponseFailureStatus];    
    
    [self beforePerformFailWithResponse:failureResponse request:request];
    if ([request.responseDelegate respondsToSelector:@selector(networkRequest:failedByResponse:)]) {
        [request.responseDelegate networkRequest:request failedByResponse:failureResponse];
    }
    [self afterPerformFailWithResponse:failureResponse request:request];
    
    //打印错误的信息
    if ([request respondsToSelector:@selector(enableDebug)]) {
        if ([request enableDebugLog]) {
            [GDNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask
                                                       responseObject:nil
                                                       authentication:NO
                                                                error:error];
        }
    }else if ([GDNetworkConfig sharedInstance].enableDebug) {
        [GDNetworkLogger logDebugResponseInfoWithSessionDataTask:sessionDataTask
                                                   responseObject:nil
                                                   authentication:NO
                                                            error:error];
    }
}

#pragma mark-
#pragma mark-处理 请求集合
- (NSString *)keyForSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    return [@(sessionDataTask.taskIdentifier) stringValue];
}

- (void)addRequestObject:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if (request.sessionDataTask == nil)    return;
    
    NSString *taskKey = [self keyForSessionDataTask:request.sessionDataTask];
    @synchronized(self) {
        _requestRecordDict[taskKey] = request;
    }
}


#pragma mark-
#pragma mark-Getter

/**
 获取完整的请求URL
 
 @param request 封装好了的请求对象
 @return 完整的请求URL
 */
- (NSString *)urlStringByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    NSString *detailUrl = @"";
    
    //提取GDNetworkRequest派生的子类中的url
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethodName)]) {
        detailUrl = [request.requestConfigProtocol requestMethodName];
    }
    
    //如果返回的是带有http的请求地址,将自动忽略GDNetworkConfig设置的url
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    
    //如果是域名下发的机制
    NSString *serviceURLString = nil;
    if ([GDNetworkConfig sharedInstance].urlSeriveDictionary && [request.requestConfigProtocol respondsToSelector:@selector(serviceKey)]) {
        NSString *serviceKey = [request.requestConfigProtocol serviceKey];
        serviceURLString = [GDNetworkConfig sharedInstance].urlSeriveDictionary[serviceKey];
        if ([serviceURLString hasPrefix:@"http"]) {
            return [serviceURLString stringByAppendingPathComponent:detailUrl];
        }
    }
    
    //正常情况下去获取统一的主域名或副域名
    NSString *baseUrlString = nil;
    if ([request.requestConfigProtocol respondsToSelector:@selector(useViceURL)] && [request.requestConfigProtocol useViceURL]) {
        baseUrlString = [GDNetworkConfig sharedInstance].viceBaseUrlString;
    }else{
        baseUrlString = [GDNetworkConfig sharedInstance].mainBaseUrlString;
    }
    
    if (baseUrlString == nil || ![baseUrlString hasPrefix:@"http"]){
        NSLog(@"\n\n\n请设置正确的URL\n\n\n");
        return nil;
    }else if (serviceURLString.length) {
        baseUrlString = [baseUrlString stringByAppendingString:serviceURLString];
    }
    
    return [NSString stringWithFormat:@"%@%@", baseUrlString, detailUrl];
}


/**
 获取完整的的请求参数
 
 @param request 封装好了的请求对象
 @return 完整的的请求参数
 */
- (NSDictionary *)requestParamByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    //从派生的子类中取出接口指定的参数
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (request.requestParamSourceDelegate) {
        NSDictionary *paramDict = [request.requestParamSourceDelegate requestParamDictionary];
        if (paramDict != nil) {
            [tempDict addEntriesFromDictionary:paramDict];
        }
    }
    
    //拼接base参数
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseRequestParamSource)] || [request.requestConfigProtocol useBaseRequestParamSource]) && [GDNetworkConfig sharedInstance].baseParamSourceBlock) {
        NSDictionary *baseRequestParamSource = [GDNetworkConfig sharedInstance].baseParamSourceBlock();
        if (baseRequestParamSource != nil) {
            [tempDict addEntriesFromDictionary:baseRequestParamSource];
        }
    }
    if (tempDict.count == 0) {
        return nil;
    }
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

//判断子类是否有判断参数是否符合要求
- (BOOL)isCorrectByRequestParams:(NSDictionary *)requestParams request:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(isCorrectWithRequestParams:)]) {
        return [request.requestConfigProtocol isCorrectWithRequestParams:requestParams];
    }
    return YES;
}

//获取处理正在执行相同方法的请求的处理方式
- (GDRequestHandleSameRequestType)handleSameRequestTypeByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(handleSameRequestType)]) {
        return [request.requestConfigProtocol handleSameRequestType];
    }
    return GDRequestHandleSameRequestCancelCurrentType;
}

//请求方式,默认POST请求
- (GDRequestMethod)requestMethodByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestMethod)]) {
        return [request.requestConfigProtocol requestMethod];
    }
    return GDRequestMethodPost;
}

//缓存策略
- (NSURLRequestCachePolicy)cachePolicyByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(cachePolicy)]) {
        NSURLRequestCachePolicy cachePolicy = [request.requestConfigProtocol cachePolicy];
        if (cachePolicy == NSURLRequestUseProtocolCachePolicy) {
            if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
                return NSURLRequestReturnCacheDataDontLoad;
            }
            return NSURLRequestUseProtocolCachePolicy;
        }
        return cachePolicy;
    }
    return NSURLRequestReloadIgnoringCacheData;
}


#pragma mark-
#pragma mark-Setter

//设置AFHTTPSessionManager
- (void)setupSessionManagerRequestSerializerByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    //配置requestSerializerType
    GDRequestSerializerType requestSerializerType;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestSerializerType)]) {
        requestSerializerType = [request.requestConfigProtocol requestSerializerType];
    }else{
        requestSerializerType = [GDNetworkConfig sharedInstance].requestSerializerType;
    }
    [self setSessionManagerRequestSerializerByRequestSerializerType:requestSerializerType];
    
    //配置请求头
    if ((![request.requestConfigProtocol respondsToSelector:@selector(useBaseHTTPRequestHeaders)] || [request.requestConfigProtocol useBaseHTTPRequestHeaders]) && [GDNetworkConfig sharedInstance].baseHTTPRequestHeadersBlock) {
        NSDictionary *requestHeaders = [GDNetworkConfig sharedInstance].baseHTTPRequestHeadersBlock();
        [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    if ([request.requestConfigProtocol respondsToSelector:@selector(customHTTPRequestHeaders)]) {
        NSDictionary *customRequestHeaders = [request.requestConfigProtocol customHTTPRequestHeaders];
        [customRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    
    //配置请求超时时间
    NSTimeInterval timeoutInterval = [GDNetworkConfig sharedInstance].requestTimeoutInterval;
    if ([request.requestConfigProtocol respondsToSelector:@selector(requestTimeoutInterval)]) {
        timeoutInterval = [request.requestConfigProtocol requestTimeoutInterval];
    }
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
    
    //配置responseSerializerType
    GDResponseSerializerType responseSerializerType;
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseSerializerType)]) {
        responseSerializerType = [request.requestConfigProtocol responseSerializerType];
    }else{
        responseSerializerType = [GDNetworkConfig sharedInstance].responseSerializerType;
    }
    [self setSessionManagerResponseSerializerByResponseSerializerType:responseSerializerType];
    
    if ([request.requestConfigProtocol respondsToSelector:@selector(responseAcceptableContentTypes)] && [request.requestConfigProtocol responseAcceptableContentTypes]) {
        self.sessionManager.responseSerializer.acceptableContentTypes = [request.requestConfigProtocol responseAcceptableContentTypes];
    }
    
    //配置请求缓存策略
    self.sessionManager.requestSerializer.cachePolicy = [self cachePolicyByRequest:request];
}

- (AFConstructingBlock)constructingBlockByRequest:(__kindof GDNetworkRequest<GDNetworkRequestConfigProtocol> *)request {
    if ([request.requestConfigProtocol respondsToSelector:@selector(constructingBodyBlock)]) {
        return [request.requestConfigProtocol constructingBodyBlock];
    }
    return nil;
}

//根据requestSerializerType 配置 requestSerializer
- (void)setSessionManagerRequestSerializerByRequestSerializerType:(GDRequestSerializerType)requestSerializerType {
    switch (requestSerializerType) {
        case GDRequestSerializerTypeHTTP:
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case GDRequestSerializerTypeJSON:
            if (![self.sessionManager.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
                self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            }
            break;
        case GDRequestSerializerTypePropertyList:
            if (![self.sessionManager.requestSerializer isKindOfClass:[AFPropertyListRequestSerializer class]]) {
                self.sessionManager.requestSerializer = [AFPropertyListRequestSerializer serializer];
            }
            break;
        default:
            break;
    }
    self.sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
}

//设置服务端返回的数据类型
- (void)setSessionManagerResponseSerializerByResponseSerializerType:(GDResponseSerializerType)responseSerializerType {
    switch (responseSerializerType) {
        case GDResponseSerializerTypeHTTP:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case GDResponseSerializerTypeJSON:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFJSONResponseSerializer class]]) {
                AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
                jsonResponseSerializer.removesKeysWithNullValues = YES;
                self.sessionManager.responseSerializer = jsonResponseSerializer;
            }
            break;
        case GDResponseSerializerTypeImage:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFImageResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
            }
            break;
        case GDResponseSerializerTypeXMLParser:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFXMLParserResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            }
            break;
        case GDResponseSerializerTypePropertyList:
            if (![self.sessionManager.responseSerializer isKindOfClass:[AFPropertyListResponseSerializer class]]) {
                self.sessionManager.responseSerializer = [AFPropertyListResponseSerializer serializer];
            }
            break;
        default:
            break;
    }
    
    //响应为空
    if ([[GDNetworkConfig sharedInstance] acceptableContentTypesForResponseSerializerType:responseSerializerType]) {
        self.sessionManager.responseSerializer.acceptableContentTypes = [[GDNetworkConfig sharedInstance] acceptableContentTypesForResponseSerializerType:responseSerializerType];
    }
}


@end
