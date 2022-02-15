//
//  OperationReadyState.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 5/16/1400 AP.
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

final public class OperationReadyState: OperationState {
    
    public weak var context: Context?
    
    public var isFinished: Bool { false }
    
    public var isExecuting: Bool { false }
    
    public var isCanceled: Bool { false }
    
    public var isSuspended: Bool { false }
    
    public var state: OperationStates { .ready }
    
    public var queueState:OperationStateInfoModel
    
    required public init(context: Context? = nil, queueState: OperationStateInfoModel = .init(enqueued: false)) {
        self.context = context
        self.queueState = queueState
    }
    
    
    public func cancelOperation() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        context.changeState(new: OperationCancelState(context: context, queueState: queueState))
        context.onCanceled?()
    }
    
    /// First the `await` method should be called  then
    /// This method will be called on overided method `start` (when OperationQueue attemp to call it)
    /// on operation subclass in order to start task and change its state
    /// `enqueued.enqueued` is `true` on this state
    /// - Throws: Throws OperationControllerError.dealocatedOperation if the context is nil
    public func start() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        // handle complete and cancel event when deadline is more than 0.0 and operation is waiting to be enqueued
        self.queueState.enqueued = true
        context.changeState(new: OperationExecutingState(context: context, queueState: queueState))
        try context.startOperation()
        context.onExecuting?()
    }
    
    public func completeOperation() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is not executing to complete.
            only executing operation can be completed with `completeOperation` method.
            try to cancel if you want to prevent it from execution.
            """
        ))
    }
    
    public func suspend() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is not executing to suspend.
            only executing operation can be suspended with `suspendOperation` method.
            try to cancel if you want to prevent it from execution.
            """
        ))
    }
    
    /// Each time calling `await` on an operation will result in async adding  the operation to `OperationQueue` within its `underlyingQueue`
    /// This method should not be called when operation is already on a queue
    /// The state of the operation won't be afected until `start` triggering
    /// `start` method will be called ofter the deadline
    /// - Parameter after: amount of time to tolerate until the operation will be added
    /// - Throws: Throws OperationControllerError.dealocatedOperation if the context is nil
    
    public func await() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        
        /// from suspend to ready
        if queueState.enqueued {
            try context.startOperation()
            return
        }
        
        try context.enqueue()
    }
}
