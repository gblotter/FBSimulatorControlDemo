//
//  SingleViewAppTests.m
//  SingleViewAppTests
//
//  Created by Arpad Zalan on 18/09/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface SingleViewAppTests : XCTestCase

@end

@implementation SingleViewAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	NSLog( @"In here!! (and by HERE, I mean SingleViewAppTest Setup()!!" );
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
	NSLog( @"In here!! (and by HERE, I mean SingleViewAppTest!!" );
    [NSThread sleepForTimeInterval:5];
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
