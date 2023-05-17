//
//  WPToastManagerTests.m
//  WPToastManagerTests
//
//  Created by weiping.lii@icloud.com on 04/26/2023.
//  Copyright (c) 2023 weiping.lii@icloud.com. All rights reserved.
//

@import XCTest;
@import WPToastManager;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testHeapPush {
    NSArray *input = @[@1,@5,@6,@2,@7,@4,@3,@8];
    NSMutableArray *heap = [NSMutableArray array];
    for (NSNumber *a in input) {
        [heap wp_heapPush:a];
    }
    XCTAssertTrue([heap wp_isValidHeap]);
    NSArray *result  = @[@8, @7,@5,@6,@2,@4,@3,@1];
    for (NSInteger i = 0; i < result.count; i++) {
        XCTAssertEqualObjects(heap[i], result[i]);
    }
}

- (void)test_heapPopFirst {
    
    NSMutableArray *heap = [@[@8, @7,@5,@6,@2,@4,@3,@1] mutableCopy];
    
    [heap wp_heapPopFirst];
    XCTAssertTrue([heap wp_isValidHeap]);
    
    NSArray *result = @[@7,@6,@5,@1,@2,@4,@3];
    for (NSInteger i = 0; i < result.count; i++) {
        XCTAssertEqualObjects(heap[i], result[i]);
    }
}

- (void)test_heapPopByIndex {
    NSMutableArray *heap = [@[@8, @7,@5,@6,@2,@4,@3,@1] mutableCopy];
    [heap wp_heapPopByIndex:2];
    XCTAssertTrue([heap wp_isValidHeap]);
    
    NSArray *result = @[@8,@7,@4,@6,@2,@1,@3];
    for (NSInteger i = 0; i < result.count; i++) {
        XCTAssertEqualObjects(heap[i], result[i]);
    }
}

@end

