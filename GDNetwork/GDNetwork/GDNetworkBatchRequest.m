//
//  GDNetworkBatchRequest.m
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import "GDNetworkBatchRequest.h"
#import "GDNetworkResponseProtocol.h"
#import "GDNetworkRequest.h"
#import "GDNetworkAgent.h"
#import "GDNetworkResponse.h"

@interface GDNetworkBatchRequest()<GDNetworkResponseProtocol>

@property (nonatomic) NSInteger completedCount;
@property (nonatomic, strong) NSArray<GDNetworkRequest *> *requestArray;
@property (nonatomic, strong) NSMutableArray *accessoryArray;
@property (nonatomic, strong) NSMutableArray<GDNetworkResponse *> *responseArray;

@end

@implementation GDNetworkBatchRequest{
    BOOL _isHandleDoneWhenNoContinueByFailResponse;
}

- (instancetype)initWithRequestArray:(NSArray<GDNetworkRequest *> *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = requestArray;
        _responseArray = [NSMutableArray array];
        _completedCount = 0;
        _isContinueByFailResponse = YES;
        _isHandleDoneWhenNoContinueByFailResponse = NO;
    }
    return self;
}


#pragma mark - 开启、结束请求
- (void)startBatchRequest {
    if (self.completedCount > 0) {//该批量请求仍在持续请求中，已有部分请求返回了数据
        NSLog(@"批量请求正在进行中，请勿重复启动 ！");
        return;
    }
    [self accessoryWillStart];
    for (GDNetworkRequest *request in self.requestArray) {
        request.responseDelegate = self;
        [[GDNetworkAgent sharedInstance] addRequest:request];
    }
    [self accessoryDidStart];
}

- (void)stopBatchRequest {
    _delegate = nil;
    for (GDNetworkRequest *request in self.requestArray) {
        [[GDNetworkAgent sharedInstance] removeRequest:request];
    }
    [self accessoryDidStop];
}


#pragma mark - GDNetworkResponseProtocol
- (void)networkRequest:(GDNetworkRequest *)networkRequest succeedByResponse:(GDNetworkResponse *)response {
    if (response.networkStatus == GDNetworkResponseDataCacheStatus) {
        return;
    }
    self.completedCount ++;
    [self.responseArray addObject:response];
    if (self.completedCount == self.requestArray.count) {
        [self accessoryFinishByStatus:GDNetworkAccessoryFinishStatusSuccess];
        [self networkBatchRequestCompleted];
    }
}

- (void)networkRequest:(GDNetworkRequest *)networkRequest failedByResponse:(GDNetworkResponse *)response {
    if (response.networkStatus == GDNetworkResponseDataCacheStatus) {
        return;
    }
    [self.responseArray addObject:response];
    
    if (self.isContinueByFailResponse) {
        self.completedCount ++;
        if (self.completedCount == self.requestArray.count) {
            [self accessoryFinishByStatus:GDNetworkAccessoryFinishStatusFailure];
        }
    }else if (_isHandleDoneWhenNoContinueByFailResponse == NO) {
        for (GDNetworkRequest *request in self.requestArray) {
            [request stopRequest];
        }
        [self accessoryFinishByStatus:GDNetworkAccessoryFinishStatusFailure];
        [self networkBatchRequestCompleted];
        _isHandleDoneWhenNoContinueByFailResponse = YES;
    }
}

- (void)networkBatchRequestCompleted {
    [self accessoryDidStop];
    if ([self.delegate respondsToSelector:@selector(networkBatchRequest:completedByResponseArray:)]) {
        [self.delegate networkBatchRequest:self completedByResponseArray:self.responseArray];
    }
    self.completedCount = 0;
}

- (void)dealloc {
    [self stopBatchRequest];
}


#pragma mark - 插入插件
- (void)addNetworkAccessoryObject:(id<GDNetworkAccessoryProtocol>)accessoryDelegate {
    if (!_accessoryArray) {
        _accessoryArray = [NSMutableArray array];
    }
    [self.accessoryArray addObject:accessoryDelegate];
}

- (void)accessoryWillStart {
    for (id<GDNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryWillStart)]) {
            [accessory networkRequestAccessoryWillStart];
        }
    }
}

- (void)accessoryDidStart {
    for (id<GDNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStart)]) {
            [accessory networkRequestAccessoryDidStart];
        }
    }
}

- (void)accessoryDidStop {
    for (id<GDNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryDidStop)]) {
            [accessory networkRequestAccessoryDidStop];
        }
    }
}

- (void)accessoryFinishByStatus:(GDNetworkAccessoryFinishStatus)finishStatus {
    for (id<GDNetworkAccessoryProtocol>accessory in self.accessoryArray) {
        if ([accessory respondsToSelector:@selector(networkRequestAccessoryByStatus:)]) {
            [accessory networkRequestAccessoryByStatus:finishStatus];
        }
    }
}

@end
