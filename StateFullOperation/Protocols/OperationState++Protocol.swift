//
//  OperationState++Protocol.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 5/24/1400 AP.
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

/*
 
 Provide an interface to handle state of an operation and control over them.
 Every state of the operation should impelement this protocol,
 State managment inside Operation is handled by `OperationContextStateProvider`
 
 */

public protocol OperationStateBase: AnyObject { }

public protocol OperationState: OperationStateBase {
    
    typealias Context = StateSupplementaryActionProvider &
    OperationController &
    OperationContextStateProvider &
    IdentifiableOperation &
    OperationLifeCycleProvider &
    OperationControlable
    
    init(context: Context?, queueState: OperationStateInfoModel)
    
    /// A delegate to AsynchronousOperation for handeling state chnages
    var context: Context? { get set }
    
    var isExecuting: Bool { get }
    var isFinished: Bool { get }
    var isCanceled: Bool { get }
    var isSuspended: Bool { get }
    var queueState: OperationStateInfoModel { get }
    var state: OperationStates { get }
    
    /// Indicating whether user can change the operation configuration or not.
    /// This getter will return true only if the operation state is on `ready`
    var canModifyOperationConfig: Bool { get }
    
    /// Complete operation by calling
    /// 1. `onFinish` block
    /// 2. Changing state to `OperationFinishState`
    /// - Parameter execute: onFinish block which was provoded by overriding it on subclasses
    /// - Throws: OperationControllerError.dealocatedOperation or
    func completeOperation() throws
    
    /// Call this method when you want to start the operation and your task
    /// default implementation calls main() on operation and change state to executing
    /// also the `start` method on operation should call this method
    func start() throws
    
    func await() throws
    
    func cancelOperation() throws
    
    /// Suspend should only be called on download or upload task.
    /// Calling this method on other tasksmay result in crash, leak and unexpected usage of network data.
    /// - Parameters:
    ///   - deadline: execute suspend request after an amount of time.
    ///   - execute: suspend block which will be executed after changing the state.
    /// - Throws:
    ///   - `OperationControllerError.nilBlock ` when `execute` is nil.
    ///   - `OperationControllerError.dealocatedOperation` when context is nil.
    func suspend() throws
}

extension OperationState {
    
    public var canModifyOperationConfig: Bool {
        !isExecuting && !isFinished && !isSuspended
    }
}
