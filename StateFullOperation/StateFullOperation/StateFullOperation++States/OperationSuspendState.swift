//
//  OperationSuspendState.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 5/19/1400 AP.
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

internal final class OperationSuspendState: OperationState {
    
    internal var state: OperationStates { .suspended }
    
    internal weak var context: Context?
    
    internal var isExecuting: Bool { false }
    
    internal var isFinished: Bool { false }
    
    internal var isCanceled: Bool { true }
    
    internal var isSuspended: Bool { true }
    
    internal var queueState: OperationStateInfoModel
    
    
    internal init(context: Context? = nil, queueState: OperationStateInfoModel) {
        self.context = context
        self.queueState = queueState
    }
    
    internal func await() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        try context
            .changeState(new: OperationReadyState(context: context,
                                                  queueState: queueState))
            .await()
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
            Operation with identifier: \(context.identifier) is already Suspended
            Could not be started
            """
        ))
    }
    
    internal func suspend() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is already Suspended
            Could not be suspended
            """
        ))
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
}
