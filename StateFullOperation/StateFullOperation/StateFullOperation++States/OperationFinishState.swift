//
//  OperationFinishState.swift
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

internal final class OperationFinishState: OperationState {
    
    internal weak var context: Context?
    
    internal var isFinished: Bool { true }
    
    internal var isExecuting: Bool { false }
    
    internal var state: OperationStates { .finished }
    
    internal var isCanceled: Bool { false }
    
    internal var isSuspended: Bool { false }
    
    internal var queueState: OperationStateInfoModel
    
    internal init(context: Context?, queueState: OperationStateInfoModel) {
        self.context = context
        self.queueState = queueState
        self.queueState.enqueued = false
    }
    
    internal func await() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
        }
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is already finished
            Could not be awaited
            """
        ))
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
            Operation with identifier: \(context.identifier) is already finished
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
            Operation with identifier: \(context.identifier) is already finished
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
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is already finished
            Could not be canceled
            """
        ))
    }
    
    internal func completeOperation() throws {
        guard let context = context else {
            throw SFOError.operationStateError(reason: .dealocatedOperation(
                """
                context was dealocated on\(String(describing: self)), cannot change state
                """
            ))
            
        }
        throw SFOError.operationStateError(reason: .operationIsNotExecutingToFinish(
            """
            Operation with identifier: \(context.identifier) is already finished,
            Could not be finished again
            """
        ))
    }
}
