//
//  GDNetworkResponse.m
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import "GDNetworkResponse.h"
#import "GDNetworkConfig.h"

@implementation GDNetworkResponse

- (instancetype)initWithResponseData:(id)responseData
                          requestTag:(NSInteger)requestTag
                       networkStatus:(GDNetworkStatus)networkStatus {
    self = [super init];
    if (self) {
        _responseData = responseData;
        _requestTag = requestTag;
        _isCache = networkStatus == GDNetworkResponseDataCacheStatus ? YES:NO;
        _networkStatus = networkStatus;
        
        _responseCode = NSNotFound;
        switch (networkStatus) {
            case GDNetworkResponseDataSuccessStatus:
            case GDNetworkResponseDataCacheStatus:
            case GDNetworkResponseDataIncorrectStatus: {
                if ([responseData isKindOfClass:[NSDictionary class]]) {
                    if ([GDNetworkConfig sharedInstance].responseCodeKey && responseData[[GDNetworkConfig sharedInstance].responseCodeKey]) {
                        _responseCode = [responseData[[GDNetworkConfig sharedInstance].responseCodeKey] integerValue];
                    }
                    if ([GDNetworkConfig sharedInstance].responseMessageKey) {
                        _responseMessage = responseData[[GDNetworkConfig sharedInstance].responseMessageKey];
                    }
                    if ([GDNetworkConfig sharedInstance].responseContentDataKey) {
                        _responseContentData = responseData[[GDNetworkConfig sharedInstance].responseContentDataKey];
                    }
                }
            } break;
                
            default: {
                _responseMessage = [self responseMsgByNetworkStatus:networkStatus];
            }  break;
        }
    }
    return self;
}

- (NSString *)responseMsgByNetworkStatus:(GDNetworkStatus)networkStatus {
    /**
     若做国际化的话，因为AFNetworking的国际化文件使用的是AFNetworking.strings，这个类库又是依赖AFNetworking的。为了少创建一个 .strings 文件。这里就复用“AFNetworking”了。
     */
    switch (networkStatus) {
        case GDNetworkNotReachableStatus:
            return NSLocalizedStringFromTable(@"暂无网络连接", @"AFNetworking", nil);
        case GDNetworkResponseDataAuthenticationFailStatus:
            return NSLocalizedStringFromTable(@"数据验证失败", @"AFNetworking", nil);
        case GDNetworkRequestParamIncorrectStatus:
            return NSLocalizedStringFromTable(@"请求参数有误", @"AFNetworking", nil);
        case GDNetworkResponseFailureStatus:
            return NSLocalizedStringFromTable(@"请求数据失败", @"AFNetworking", nil);
        default:
            return nil;
    }
}

@end
