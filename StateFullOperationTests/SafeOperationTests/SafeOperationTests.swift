//
//  SafeOperationTests.swift
//  StateFullOperationTests
//
//  Created by Kiarash Vosough on 8/16/1400 AP.
//

import XCTest
@testable import StateFullOperation

class SafeOperationTests: XCTestCase {
    
    var queue: OperationQueue?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        queue = OperationQueue()
        queue?.underlyingQueue = DispatchQueue.global(qos: .default)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFinishAuto() throws {
        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 4
        
        
        let op = MySafeOperationMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        op.onCompleted = {
            XCTAssertEqual(self.queue?.operationCount, 0)
        }
        
        try op.enqueueSelf()
        wait(for: [insideMethodExpectation], timeout: 6)
    }
    
    func testFinish() throws {
        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 4
        
        let StartMethodExpectation = XCTestExpectation()
        StartMethodExpectation.expectedFulfillmentCount = 1
        
        let op = MySafeOperationMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation, startExpectation: StartMethodExpectation)
        
        op.onCompleted = {
            XCTAssertEqual(self.queue?.operationCount, 0)
        }
        
        try op.enqueueSelf()
        try op.finishRunnable()
    }
    
    func testCancelRunnable() throws {

        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 3
        
        
        let op = MySafeOperationMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        try op.enqueueSelf()
        try op.cancelRunnable()
        XCTAssertEqual(queue?.operationCount, 0)
    }
    
    func testCancel() throws {
        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 3
        
        
        let op = MySafeOperationMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        try op.enqueueSelf()
        op.cancel()
        print(op.isExecuting,
              op.isFinished,
              op.isCancelled)
        XCTAssertEqual(queue?.operationCount, 0)
    }
    
    func testWaitForAllOperation() throws {
        let insideMethodExpectation1 = XCTestExpectation()
        insideMethodExpectation1.expectedFulfillmentCount = 1

        let insideMethodExpectation2 = XCTestExpectation()
        insideMethodExpectation2.expectedFulfillmentCount = 1
        
        let op1 = MySafeOperationMock(operationQueue: queue, configuration: .init(waitUntilAllOperationsAreFinished: true), expectation: insideMethodExpectation1)
        let op2 = MySafeOperationMock(operationQueue: queue, configuration: .init(waitUntilAllOperationsAreFinished: true), expectation: insideMethodExpectation2)
        
        try op1.enqueueSelf()
        try op2.enqueueSelf()
        
        try op1.waitUntilAllOperationsAreFinished()
        try op2.waitUntilAllOperationsAreFinished()
        
        wait(for: [insideMethodExpectation1, insideMethodExpectation2], timeout: 5)
        
    }
    
    func testDependency() throws {
        let insideMethodExpectation1 = XCTestExpectation(description: "test 1")
        insideMethodExpectation1.expectedFulfillmentCount = 1

        let insideMethodExpectation2 = XCTestExpectation(description: "test 2")
        insideMethodExpectation2.expectedFulfillmentCount = 1
        
        let op1 = MySafeOperationMock(operationQueue: queue, configuration: .init(waitUntilAllOperationsAreFinished: true), expectation: insideMethodExpectation1)
        let op2 = MySafeOperationMock(operationQueue: queue, configuration: .init(waitUntilAllOperationsAreFinished: true), expectation: insideMethodExpectation2)
        
        try op2.dependsOn(op1)
        
        try op1.enqueueSelf()
        try op2.enqueueSelf()
        
        try op1.waitUntilAllOperationsAreFinished()
        try op2.waitUntilAllOperationsAreFinished()
        wait(for: [insideMethodExpectation1, insideMethodExpectation2], timeout: 10)
    }
    
    func testNilQueueForWaiting() throws {
        
        let insideMethodExpectation1 = XCTestExpectation(description: "test 1")
        insideMethodExpectation1.expectedFulfillmentCount = 1
        
        let op1 = MySafeOperationMock(operationQueue: queue, configuration: .init(waitUntilAllOperationsAreFinished: false), expectation: insideMethodExpectation1)
        
        
        try op1.enqueueSelf()
        
        op1.operationQueue = nil
        
        XCTAssertThrowsError(try op1.waitUntilAllOperationsAreFinished())
    }

    func testnilQueue() throws {
        let op = MySafeOperationMock(operationQueue: nil, configuration: .init())
        
        XCTAssertThrowsError(try op.enqueueSelf())
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
