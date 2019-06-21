//
//  GDNetworkHUDAccessory.m
//  GoldenCloud
//
//  Created by 黄彬彬 on 2018/3/14.
//  Copyright © 2018年 golden. All rights reserved.
//


#import "GDNetworkHUDAccessory.h"
#import "MBProgressHUD.h"

@interface GDNetworkHUDAccessory()
@property (nonatomic, strong) UIView *supView;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation GDNetworkHUDAccessory

- (instancetype)initWithShowInView:(UIView *)view text:(NSString *)text{
    self = [super init];
    if (self) {
        _hud = [[MBProgressHUD alloc] initWithView:view];
        _hud.removeFromSuperViewOnHide = YES;
        [view addSubview:_hud];
        _supView = view;
        if (text) {
            _hud.label.text = text;
        }
    }
    return self;
}

- (void)networkRequestAccessoryWillStart {
    [_supView addSubview:_hud];
    [self.hud showAnimated:YES];
}

- (void)networkRequestAccessoryDidStop {
    [self.hud hideAnimated:YES afterDelay:0.3f];
}
@end
