//
//  MySafeOperationWaitingMock.swift
//  StateFullOperationTests
//
//  Created by Kiarash Vosough on 9/9/1400 AP.
//

import XCTest
import Foundation
@testable import StateFullOperation

final class MySafeOperationWaitingMock: SafeOperation {
    
    private let expectation: XCTestExpectation
    
    init(operationQueue: OperationQueue?,
         configuration: SafeOperationConfiguration,
         expectation: XCTestExpectation = .init()) {
        self.expectation = expectation
        super.init(operationQueue: operationQueue, configuration: configuration)
    }
    
    override func operation() throws {
        /// impelement your task here
        /// call `cancelRunnable()` whenever the task finish
        try super.operation()
        expectation.fulfill()
        Thread.sleep(forTimeInterval: 5)
        try finishOperation()
    }
    
    override func waitUntilAllOperationAreFinished() throws {
        try super.waitUntilAllOperationAreFinished()
        expectation.fulfill()
    }
}
