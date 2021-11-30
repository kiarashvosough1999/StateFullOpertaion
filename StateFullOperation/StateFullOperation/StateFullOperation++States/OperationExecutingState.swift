//
//  OperationExecutingState.swift
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

internal final class OperationExecutingState: OperationState  {
    
    internal weak var context: Context?
    
    internal var isFinished: Bool { false }
    
    internal var isExecuting: Bool { true }
    
    internal var isCanceled: Bool { false }
    
    internal var isSuspended: Bool { false }
    
    internal var state: OperationStates { .executing }
    
    internal var queueState: OperationStateInfoModel
    
    internal init(context: Context? = nil, queueState: OperationStateInfoModel) {
        self.context = context
        self.queueState = queueState
        self.queueState.enqueued = true
    }
    
    internal func start() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is already Executing
            Could not be started
            """
        ))
    }
    
    /// This Method is just handeling await request when an operation should be suspended after an amount of time
    /// and user request to await before that time reachs,
    /// it will make async recursive block to call await when the state changes to Suspended
    /// - Parameter deadline: amount of time to tolerate until the operation will be added
    /// - Throws:
    ///  - OperationControllerError.dealocatedOperation on context nil
    ///  - OperationControllerError.operationQueueIsNil on underlyingQueue nil
    internal func await() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        throw SFOError.operationStateError(reason: .misUseError(
            """
            unable to suspend operation with identifier \(context.identifier) on \(state) state
            await method should only be called once or after suspension.
            """
        ))
    }
    
    /// Complete operation by calling
    /// 1. `onFinish` block
    /// 2. Changing state to `OperationFinishState`
    /// - Parameter execute: onFinish block which was provoded by overriding it on subclasses
    /// - Throws: OperationControllerError.dealocatedOperation or
    internal func completeOperation() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        context.changeState(new: OperationFinishState(context: context, queueState: queueState))
        context.onFinished?()
        
    }
    internal func cancelOperation() throws {
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
    
    
    internal func suspend() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        context
            .changeState(new: OperationSuspendState(context: context,
                                                    queueState: queueState))
        context.onSuspended?()
    }
}
