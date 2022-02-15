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
        insideMethodExpectation.expectedFulfillmentCount = 3
        
        
        let op = MySafeOperationTaskMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        op.onCompleted = {
            XCTAssertEqual(self.queue?.operationCount, 0)
        }
        
        try op.enqueue()
        wait(for: [insideMethodExpectation], timeout: 6)
    }
    
    func testFinish() throws {
        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 5
        
        let op = MySafeOperationFinishMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        try op.enqueue()
        op.onExecutingOperationAction = {
            try? op.finishOperation()
        }
        
        op.onFinishedOperationAction = {
            XCTAssertEqual(self.queue?.operationCount, 0)
        }
    }
    
    func testCancelOperation() throws {

        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 5
        
        
        let op = MySafeOperationCancelMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        try op.enqueue()
        
        op.onExecutingOperationAction = {
            try? op.cancelOperation()
        }
        
        op.onCanceledOperationAction = {
            XCTAssertEqual(self.queue?.operationCount, 0)
            XCTAssertEqual(op.isFinished, true)
            XCTAssertEqual(op.isExecuting, false)
            XCTAssertEqual(op.isCancelled, true)
        }
    }
    
    func testCancel() throws {
        let insideMethodExpectation = XCTestExpectation()
        insideMethodExpectation.expectedFulfillmentCount = 5
        
        
        let op = MySafeOperationCancelMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation)
        
        try op.enqueue()
        
        op.cancel()
        XCTAssertEqual(op.isFinished, true)
        XCTAssertEqual(op.isExecuting, false)
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(self.queue?.operationCount, 0)
    }
    
    func testWaitForAllOperation() throws {
        let insideMethodExpectation1 = XCTestExpectation()
        insideMethodExpectation1.expectedFulfillmentCount = 2

        let insideMethodExpectation2 = XCTestExpectation()
        insideMethodExpectation2.expectedFulfillmentCount = 2
        
        let op1 = MySafeOperationWaitingMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation1)
        let op2 = MySafeOperationWaitingMock(operationQueue: queue, configuration: .init(), expectation: insideMethodExpectation2)
        
        try op1.enqueue()
        try op2.enqueue()
        
        try op1.waitUntilAllOperationAreFinished()
        try op2.waitUntilAllOperationAreFinished()
        
        wait(for: [insideMethodExpectation1, insideMethodExpectation2], timeout: 0)
    }
    
    func testDependency() throws {
        let insideMethodExpectation1 = XCTestExpectation(description: "test 1")
        insideMethodExpectation1.expectedFulfillmentCount = 2

        let insideMethodExpectation2 = XCTestExpectation(description: "test 2")
        insideMethodExpectation2.expectedFulfillmentCount = 2
        
        let op1 = MySafeOperationDependencyMock(operationQueue: queue,
                                                configuration: .init(),
                                                expectation: insideMethodExpectation1)
        
        let op2 = MySafeOperationDependencyMock(operationQueue: queue,
                                                configuration: .init(),
                                                expectation: insideMethodExpectation2)
        
        try op2.dependsOn(op1)
        
        try op1.enqueue()
        
        try op2.enqueue()
        
        
        wait(for: [insideMethodExpectation1, insideMethodExpectation2], timeout: 10 + 0.5)
    }
    
    func testNilQueueForWaiting() throws {
        
        let op1 = MySafeOperationMock(operationQueue: queue, configuration: .init())
        
        try op1.enqueue()
        
        op1.operationQueue = nil
        
        XCTAssertThrowsError(try op1.waitUntilAllOperationAreFinished())
    }

    func testnilQueue() throws {
        let op = MySafeOperationMock(operationQueue: nil, configuration: .init())
        
        XCTAssertThrowsError(try op.enqueue())
    }
    
    func testBlockTask() {
        
        let expectation = XCTestExpectation(description: "test 1")
        expectation.expectedFulfillmentCount = 2
        
        let op = MySafeOperationMock(operationQueue: queue, configuration: .init())
        
        op.operationExecutable = { finished in
            expectation.fulfill()
            Thread.sleep(forTimeInterval: 2)
            expectation.fulfill()
        }
        
        XCTAssertNoThrow(try op.enqueue())
        
        wait(for: [expectation], timeout: 2.5)
        
//        XCTAssertTrue(op.isFinished)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
