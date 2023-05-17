//
//  NSMutableArray+wpUtil.m
//  WPToastManager
//
//  Created by weiping.lii on 2023/5/16.
//

#import "NSMutableArray+wpUtil.h"

@implementation NSMutableArray (wpUtil)

- (void)wp_heapPush:(id)object {
    [self addObject:object];
    NSUInteger index = self.count - 1;
    while (index > 0) {
        NSUInteger parentIndex = (index + 1)/2 - 1;
        if ([self[parentIndex] compare:object] == NSOrderedDescending) {
            break;
        }
        [self exchangeObjectAtIndex:parentIndex withObjectAtIndex:index];
        index = parentIndex;
    }
}

- (void)wp_heapifyFromIndex:(NSUInteger)index {
    NSUInteger cur = index;
    while (cur < self.count/2) {
        NSUInteger left = cur * 2 + 1;
        NSUInteger right = cur * 2 + 2;
        NSUInteger targetChild = left;
        if (right <= self.count-1 &&
            [self[right] compare:self[left]] == NSOrderedDescending)
        {
            targetChild = right;
        }
        [self exchangeObjectAtIndex:cur withObjectAtIndex:targetChild];
        cur = targetChild;
    }
}

- (id)wp_heapPopFirst {
    return [self wp_heapPopByIndex:0];
}

- (id)wp_heapPopByIndex:(NSUInteger)index {
    if (!self.firstObject) {
        return nil;
    }
    [self exchangeObjectAtIndex:index withObjectAtIndex:self.count-1];
    id object = [self lastObject];
    [self removeLastObject];
    [self wp_heapifyFromIndex:index];
    return object;
}

- (BOOL)wp_isValidHeap {
    if (self.count <= 1) return YES;
    return [self p_recurValidation:0];
}

- (BOOL)p_recurValidation:(NSUInteger)cur {
    if (cur >= self.count/2) return YES;
    NSUInteger left = cur*2 + 1;
    NSUInteger right = left + 1;
    if ([self[cur] compare:self[left]] == NSOrderedAscending) {
        return NO;
    }
    if (right < self.count && [self[cur] compare:self[right]] == NSOrderedAscending) {
        return NO;
    }
    if (right < self.count) {
        return [self p_recurValidation:left] && [self p_recurValidation:right];
    } else {
        return [self p_recurValidation:left];
    }
}

@end
