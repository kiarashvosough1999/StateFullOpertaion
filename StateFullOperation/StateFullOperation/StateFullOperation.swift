//
//  StateSupplementaryActionProvider.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 8/11/1400 AP.
//
//  Copyright 2020 KiarashVosough and other contributors
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/**
 
 A state managable operation which it inherited from `SafeOperation`
 
 * This is more or less how state changes
 
                                +---------------+
                                |               |
                 +--------------|     Ready     |--------------------------------+
                 |              |               |                                |
                 |              +---------------+                                |
                 |                              ↑                                |
                 |                              |                                |
                 |                              |                                |
                 ↓                              |                                ↓
         +---------------+                      |                         +------+--------+
         |               |-----------------------------------------------→+               |
         |   Executing   |-------------------+  |                         |   Canceled    |
         |               |                   |  |                         |               |
         +-------+-------+                   |  |                         +------+--------+
                 |                           |  |                                ↑
                 |                           |  |                                |
                 |                           |  |                                |
                 ↓                           ↓  |                                |
         +-------+---------+            +----+--+---------+                      |
         |                 |            |                 |                      |
         |    Finished     +←-----------|    Suspended    |----------------------+
         |                 |            |                 |
         +-----------------+            +-----------------+
 
 After any state changes, the `WorkItem` related to the new state will begin to perform.
 
 Each `WorkItem` can be overriden by the subclasses to implement their custom action
 
 
 
 */

public class StateFullOperation: SafeOperation,
                                 OperationController,
                                 OperationContextStateProvider,
                                 StateSupplementaryActionProvider {
    
    @SFOThreadSafe
    public var operationState: OperationState { 
        didSet {
            isExecuting = operationState.isExecuting
            isFinished = operationState.isFinished
            isCancelled = operationState.isCanceled
        }
    }
    
    public var state: OperationStates { $operationState.read { $0.state } }
    
    // MARK: -  Execution Blocks For Each State
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `finished`.
    open var onFinished: WorkerBlock?
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `executing`.
    /// override this property and provide a block of what you want when the operation start.
    open var onExecuting: WorkerBlock?
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `canceled`.
    open var onCanceled: WorkerBlock?
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `suspended`.
    /// The operation itself does not support suspending.
    /// This extra state help some task to be paused and be resumed when the user asked
    /// The operation will remain on queue but not executing
    /// For URLSessionDataTasks:
    /// - Provide block only on download and upload tasks
    /// - Providing block on other tasks and using it may result in crash, leak and unexpected usage of network data.
    open var onSuspended: WorkerBlock?
    
    //MARK: - init
    
    public init(operationState: OperationState = OperationReadyState()) {
        self.operationState = operationState
        super.init()
        self.operationState.context = self
    }
    
    public init(operationQueue: OperationQueue?,
                operationState: OperationState = OperationReadyState()) {
        self.operationState = operationState
        super.init(operationQueue: operationQueue)
        self.operationState.context = self
    }
    
    public init(configuration: SafeOperationConfiguration,
                operationState: OperationState = OperationReadyState()) {
        self.operationState = operationState
        super.init(configuration: configuration)
        self.operationState.context = self
    }
    
    //MARK: - Operation Control
    
    /// Change the state of opertaion
    /// - Parameter state: Next State
    /// - Returns: Return new state of the context
    @discardableResult
    open func changeState(new state: OperationState) -> OperationState {
        $operationState.write { obj -> OperationState in
            if state.state == obj.state { return obj }
            obj = state
            return obj
        }
    }
    
    open override func shouldStartOperation() throws {
        if self.isCancelled {
            try $operationState.read { state in
                try state.cancelOperation()
            }
            return
        }
        try $operationState.read { state in
            try state.start()
        }
    }
    
    @discardableResult
    open func completeOperation() throws -> Self {
        try $operationState.read { state in
            try state.completeOperation()
        }
        return self
    }
    
    @discardableResult
    open func cancelOperation() throws -> Self {
        try $operationState.read { state in
            try state.cancelOperation()
        }
        return self
    }
    
    @discardableResult
    open func suspend() throws -> Self {
        try $operationState.read { state in
            try state.suspend()
        }
        return self
    }
    
    /// Start operation by changing its `state`
    /// - Throws: Error of kind `OperationControllerError`
    /// - Returns: Self
    @discardableResult
    open func await() throws -> Self {
        try $operationState.read { state in
            try state.await()
        }
        return self
    }
}
