//
//  WPToastControlInfo.m
//  WPToastManager
//
//  Created by weiping.lii on 2021/12/7.
//

#import "WPToastControlInfo.h"

@implementation WPToastControlInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = @"default";
        _interval = 3;
        _expiration = 30;
    }
    return self;
}

- (NSDate *)expirationDate {
    NSAssert(self.receiveAt != nil, @"receiveAt should be set before check expirationDate");
    if (self.receiveAt == nil) {
        return [NSDate dateWithTimeIntervalSinceNow:-1];
    }
    NSDate *date = [self.receiveAt dateByAddingTimeInterval:self.expiration];
    return date;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    if ([dic[@"isDeleted"] boolValue]) {
        return NO;
    }
    self.receiveAt = nil;
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

+ (NSString *)version {
    return @"1.0";
}

@end

