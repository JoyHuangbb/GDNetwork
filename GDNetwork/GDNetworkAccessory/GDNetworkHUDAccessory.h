//
//  GDNetworkHUDAccessory.h
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//
//
//  定制请求的hud

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GDNetworkAccessoryProtocol.h"

@interface GDNetworkHUDAccessory : NSObject<GDNetworkAccessoryProtocol>

- (instancetype)initWithShowInView:(UIView *)view text:(NSString *)text;

@end
