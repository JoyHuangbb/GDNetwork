//
//  GDNetworkLogger.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDNetworkLogger : NSObject

// 打印请求报文信息
+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        httpMethod:(NSInteger)httpMethod
                            params:(NSDictionary *)params reachabilityStatus:(NSInteger)reachabilityStatus;

// 打印服务端回调的相关信息
+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask
                                 responseObject:(id)response
                                 authentication:(BOOL)authentication
                                          error:(NSError *)error;

@end
