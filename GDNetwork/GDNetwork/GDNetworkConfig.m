//
//  GDNetworkConfig.m
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//

#import "GDNetworkConfig.h"

static inline NSString *kAcceptableContentTypesKey(GDResponseSerializerType responseSerializerType) {
    return [NSString stringWithFormat:@"com.sanetwork.responseSerializerType-%ld",(long)responseSerializerType];
}

@interface GDNetworkConfig()

@property (nonatomic, strong) NSMutableDictionary *acceptableContentTypesDict;

@end

@implementation GDNetworkConfig

+ (GDNetworkConfig *)sharedInstance {
    static GDNetworkConfig *networkConfigInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkConfigInstance = [[GDNetworkConfig alloc] init];
    });
    return networkConfigInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestSerializerType = GDRequestSerializerTypeHTTP;
        _responseSerializerType = GDResponseSerializerTypeJSON;
        _requestTimeoutInterval = 20.0f;
        _enableDebug = NO;
        _acceptableContentTypesDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setAcceptableContentTypes:(NSSet<NSString *> *)acceptableContentTypes
        forResponseSerializerType:(GDResponseSerializerType)responseSerializerType {
    if ([acceptableContentTypes count]) {
        [self.acceptableContentTypesDict setObject:acceptableContentTypes
                                            forKey:kAcceptableContentTypesKey(responseSerializerType)];
    }
}

- (NSSet<NSString *> *)acceptableContentTypesForResponseSerializerType:(GDResponseSerializerType)responseSerializerType {
    return self.acceptableContentTypesDict[kAcceptableContentTypesKey(responseSerializerType)];
}
@end
