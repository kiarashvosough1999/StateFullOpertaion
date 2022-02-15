//
//  OperationControlable++Protocol.swift
//  StateFullOperation
//
//  Created by Kiarash Vosough on 2/15/22.
//

import Foundation

/*
 
 This is an abstract protocol for Operation
 It is impelemented by `SafeOperation` in order to provide an interface to use `Opreation` in more convinient way than the basic methods it has.
 
 Some of the methods are working behalf of Operation's original method.
 
 */

public protocol OperationControlable: AnyObject {
    
    var onCanceledOperationAction: SFOAlias.OnOperationCanceled? { get }
    
    var onFinishedOperationAction: SFOAlias.OnOperationFinished? { get }
    
    var onExecutingOperationAction: SFOAlias.OnOperationExecuting? { get }
    
    var operationExecutable: SFOAlias.OperationBlock? { get }
    
    /// Blocks the current thread until all of the receiver’s queued and executing operations finish executing.
    /// When called, this method blocks the current thread and waits for the receiver’s current and queued operations to finish executing.
    /// While the current thread is blocked, the receiver continues to launch already queued operations and monitor those that are executing.
    /// During this time, the current thread cannot add operations to the queue, but other threads may. Once all of the pending operations are finished, this method returns.
    /// If there are no operations in the queue, this method returns immediately.
    func waitUntilAllOperationAreFinished() throws
    
    /// ٍEnququ Self in `OperationQueue` to start
    /// This method should be called instead of `operationQueue.addOperation(self)`
    /// `operationQueue.addOperation(self)` was imeplemnted in super class with more safety
    ///  - Throws: queueFoundNil ---> if the `OperationQueue` is nil
    func enqueue() throws
    
    /// This method does not force your operation code to stop.
    /// Instead, it updates the object’s internal flags to reflect the change in state.
    /// If the operation has already finished executing, this method has no effect.
    /// Canceling an operation that is currently in an operation queue, but not yet executing,
    /// makes it possible to remove the operation from the queue sooner than usual.
    func cancelOperation() throws
    
    func finishOperation() throws
}
