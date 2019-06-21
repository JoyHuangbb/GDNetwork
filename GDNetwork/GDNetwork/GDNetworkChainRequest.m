//
//  GDNetworkChainRequest.m
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import "GDNetworkChainRequest.h"
#import "GDNetworkRequest.h"
#import "GDNetworkResponseProtocol.h"
#import "GDNetworkAgent.h"

@interface GDNetworkChainRequest()<GDNetworkResponseProtocol>

@property (nonatomic, strong) NSMutableArray *accessoryArray;
@property (nonatomic, strong) GDNetworkRequest *currentNetworkRequest;


@end

@implementation GDNetworkChainRequest

- (instancetype)initWithRootNetworkRequest:(__kindof GDNetworkRequest *)networkRequest {
    self = [super init];
    if (self) {
        _currentNetworkRequest = networkRequest;
    }
    return self;
}

- (void)startChainRequest {
    [self accessoryWillStart];
    _currentNetworkRequest.responseDelegate = self;
    [[GDNetworkAgent sharedInstance] addRequest:self.currentNetworkRequest];
    [self accessoryDidStart];
}

- (void)stopChainRequest {
    [[GDNetworkAgent sharedInstance] removeRequest:self.currentNetworkRequest];
    [self accessoryDidStop];
}

- (void)dealloc {
    [self stopChainRequest];
}

#pragma mark - GDNetworkChainRequestResponseDelegate
- (void)networkRequest:(GDNetworkRequest *)networkRequest succeedByResponse:(GDNetworkResponse *)response {
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:nextNetworkRequestByNetworkRequest:finishedByResponse:)]) {
        GDNetworkRequest *nextRequest = [self.delegate networkChainRequest:self nextNetworkRequestByNetworkRequest:networkRequest finishedByResponse:response];
        if (nextRequest != nil) {
            nextRequest.responseDelegate = self;
            [nextRequest startRequest];
            self.currentNetworkRequest = nextRequest;
            return;
        }
    }
    [self accessoryDidStop];
    [self accessoryFinishByStatus:GDNetworkAccessoryFinishStatusSuccess];
}

- (void)networkRequest:(GDNetworkRequest *)networkRequest failedByResponse:(GDNetworkResponse *)response {
    [self accessoryDidStop];
    [self accessoryFinishByStatus:GDNetworkAccessoryFinishStatusFailure];
    if ([self.delegate respondsToSelector:@selector(networkChainRequest:networkRequest:failedByResponse:)]) {
        [self.delegate networkChainRequest:self networkRequest:networkRequest failedByResponse:response];
    }
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
