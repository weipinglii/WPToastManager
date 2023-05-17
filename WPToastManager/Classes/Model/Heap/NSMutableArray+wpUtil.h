//
//  NSMutableArray+wpUtil.h
//  WPToastManager
//
//  Created by weiping.lii on 2023/5/16.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSArray.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (wpUtil)

- (void)wp_heapPush:(id)object;
- (void)wp_heapifyFromIndex:(NSUInteger)index;
- (id)wp_heapPopFirst;
- (id)wp_heapPopByIndex:(NSUInteger)index;

- (BOOL)wp_isValidHeap;

@end

NS_ASSUME_NONNULL_END
