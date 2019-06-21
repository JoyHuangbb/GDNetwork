//
//  GDNetworkRequest.m
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import "GDNetworkRequest.h"
#import "GDNetworkAgent.h"

@interface GDNetworkRequest()

@property (nonatomic, weak) id <GDNetworkRequestConfigProtocol> requestConfigProtocol;

@property (nonatomic, strong) NSMutableArray *accessoryArray;

@end

@implementation GDNetworkRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(GDNetworkRequestConfigProtocol)]) {
            _requestConfigProtocol = (id <GDNetworkRequestConfigProtocol>)self;
        }else{
            NSAssert(NO, @"子类必须实现GDNetworkConfigProtocol协议");
        }
    }
    return self;
}

- (void)startRequest {
    [self accessoryWillStart];
    [[GDNetworkAgent sharedInstance] addRequest:self];
    [self accessoryDidStart];
}


- (void)stopRequest {
    [[GDNetworkAgent sharedInstance] removeRequest:self];
    [self accessoryDidStop];
}

#pragma mark-
#pragma mark-Accessory

- (void)addNetworkAccessoryObject:(id<GDNetworkAccessoryProtocol>)accessoryDelegate {
    if (_accessoryArray == nil) {
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
