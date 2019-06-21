//
//  GDNetworkRequestParamSourceProtocol.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
//  网络请求的请求参数代理管理类

#import <Foundation/Foundation.h>

@protocol GDNetworkRequestParamSourceProtocol <NSObject>

@required

/**
 请求所需的参数
 通常不建议将自定直接传入自定义的继承自GDNetworkRequest的子类
 因为可能会对这些参数做其他加工,建议将参数加工也放到GDNetworkRequest子类中
 
 @return 参数字典
 */
- (NSDictionary *)requestParamDictionary;
@end
