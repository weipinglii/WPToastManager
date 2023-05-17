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

- (NSUInteger)hash {
    return [self yy_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}

- (NSComparisonResult)compare:(id<WPToastMessage>)message {
    if (self.controlInfo.priority > message.controlInfo.priority) {
        return NSOrderedAscending;
    } else if (self.controlInfo.priority == message.controlInfo.priority) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

@end
