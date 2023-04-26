//
//  WPToastMessage.m
//  WPToastManager
//
//  Created by weiping.lii on 2021/11/18.
//

#import "WPToastMessage.h"

@import YYModel;

@implementation WPToastMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        _displayTime = 3.0;
        _type = @"default";
    }
    return self;
}

- (void)setClickAction:(WPToastClickAction)clickAction {
    _clickAction = [clickAction copy];
}

- (void)setLifeCycleCallback:(WPToastLifeCycleCallback)lifeCycleCallback {
    _lifeCycleCallback = [lifeCycleCallback copy];
}

- (NSString *)description {
    return [self yy_modelDescription];
}

@end
