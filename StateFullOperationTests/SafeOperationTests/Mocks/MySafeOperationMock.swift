//
//  MySafeOperationMock.swift
//  StateFullOperationTests
//
//  Created by Kiarash Vosough on 8/22/1400 AP.
//

import XCTest
@testable import StateFullOperation

class MySafeOperationMock: SafeOperation {
    
    let expectation: XCTestExpectation
    
    let startExpectation: XCTestExpectation
    
    init(operationQueue: OperationQueue?,
         configuration: SafeOperationConfiguration,
         expectation: XCTestExpectation = .init(),
         startExpectation: XCTestExpectation = .init()) {
        self.expectation = expectation
        self.startExpectation = startExpectation
        super.init(operationQueue: operationQueue, configuration: configuration)
    }
    
    override func start() {
        do {
            try shouldStartRunnable()
        } catch {
            startExpectation.fulfill()
        }
    }
    
    override func shouldStartRunnable() throws {
        try super.shouldStartRunnable()
        /// do some pre-requireties before the runnable start
    }
    
    override func runnable() throws {
        /// impelement your task here
        /// call `cancelRunnable()` whenever the task finish
        try super.runnable()
        print("start operation with expectation description", expectation.description)
        let sDate = Date()
        expectation.fulfill()
        Thread.sleep(forTimeInterval: 5)
        let eDate = Date()
        XCTAssertEqual(round(eDate.timeIntervalSince(sDate)), 5)
        print("end operation with expectation description", expectation.description)
        expectation.fulfill()
        try finishRunnable()
    }
    
    override func finishRunnable() throws {
        try super.finishRunnable()
        expectation.fulfill()
    }
    
    override func didFinishRunnable() {
        super.didFinishRunnable()
        expectation.fulfill()
    }
    
    override func cancelRunnable() throws {
        try super.cancelRunnable()
        /// make sure you call `super.cancelRunnable()` in order to change operation flag
        expectation.fulfill()
    }
    
    override func didCancelRunnable() {
        super.didCancelRunnable()
        /// after operation canceled and before the operation is poped from queue this method will be called
        expectation.fulfill()
    }
    
    override func waitUntilAllOperationsAreFinished() throws {
        try super.waitUntilAllOperationsAreFinished()
        expectation.fulfill()
    }
}
