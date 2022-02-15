//
//  StateFullOperation.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 5/22/1400 AP.
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
 
 `SafeOperation` offers new features which the operation itself does not support or could be so tricky to use
 
 It provide `thread safe` operation flags `setter` and `getter` and hold the flags on its own local variable
 
 All the flags are synchronized within a muetx lock of type `NSLock`,
 
 This can be handy when several threads trying to change the operation's flags at the same time
 
 If you want to access the `OperationQueue` which this operation was added to it
 
 No worry, it has and weak refrenence to its  `OperationQueue` (not thread safe)
 
 Use this refrence carefully, any misuse will result in crash or unexpected behavior.
 
 This class conforms to `IdentifiableOperation` protocol, which can be identified with unique identifier,
 
 This can be useful when adding or removing dependencies.
 
 Subclasses must not override any method of the base Opertaion Class
 , instead they can override the provided method on protocol `OperationLifeCycleProvider` to take control of what should be done
 
 */
open class SafeOperation: Operation, OperationLifeCycleProvider, OperationControlable, QueueableOperation ,ConfigurableOperation {
    
    public typealias Queue = OperationQueue
    
    internal var operationQueueAssociationKey: UInt8 = 0
    
    /// Any changes to operation flags will be stored on these variables to keep track of states
    public lazy var _executing: Bool = false
    
    public lazy var _finished: Bool = false
    
    public lazy var _canceled: Bool = false
    
    public lazy var _suspended: Bool = false
    
    /// `Thread Safe Readable and Settable` Variables Indicating Operation Flags
    
    /**
     These Properties are part of NSOperation and no changes should be applied to them in subclasses
     */
    
    open override var isExecuting: Bool {
        get {
            return lock.synchronize { _executing }
        }
        set {
            willChangeValue(forKey: #keyPath(Operation.isExecuting))
            lock.synchronize { _executing = newValue }
            didChangeValue(forKey: #keyPath(Operation.isExecuting))
        }
    }
    
    open override var isFinished: Bool {
        get {
            return lock.synchronize { _finished }
        }
        set {
            willFinishOperation()
            willChangeValue(forKey: #keyPath(Operation.isFinished))
            lock.synchronize { _finished = newValue }
            didChangeValue(forKey: #keyPath(Operation.isFinished))
            didFinishOperation()
            onFinishedOperationAction?()
        }
    }
    
    open override var isCancelled: Bool {
        get {
            return lock.synchronize { _canceled }
        }
        set {
            willCancelOperation()
            willChangeValue(forKey: #keyPath(Operation.isCancelled))
            lock.synchronize { _canceled = newValue }
            didChangeValue(forKey: #keyPath(Operation.isCancelled))
            didCancelOperation()
            onCanceledOperationAction?()
        }
    }
    
    // MARK: - Handler
    
    open var onCompleted: SFOAlias.OnOperationCompltion? {
        get {
            return completionBlock
        }
        set {
            completionBlock = newValue
        }
    }
    
    open var onCanceledOperationAction: SFOAlias.OnOperationCanceled?
    
    open var onFinishedOperationAction: SFOAlias.OnOperationFinished?
    
    open var onExecutingOperationAction: SFOAlias.OnOperationExecuting?
    
    open var operationExecutable: SFOAlias.OperationBlock?
    
    /// Overridable property indicating whether the operation is `async` or not
    open override var isAsynchronous: Bool { return true }
    
    /// a `mutex lock` to `synchronize` Control properties between threads
    public let lock: NSLock = NSLock()
    
    weak public var operationQueue: OperationQueue?
    
    // MARK: - LifeCycle
    
    public override init() {
        super.init()
    }
    
    public init(configuration: SafeOperationConfiguration) {
        super.init()
        setupOperation(with: configuration)
    }
    
    public init(operationQueue: OperationQueue?) {
        super.init()
        self.operationQueue = operationQueue
    }
    
    public init(operationQueue: OperationQueue?, configuration: SafeOperationConfiguration) {
        super.init()
        self.operationQueue = operationQueue
        setupOperation(with: configuration)
    }
    
    /// Do not override this method
    /// Override shouldStartRunnable instead
    public override func start() {
        do {
            try shouldStartOperation()
            onExecutingOperationAction?()
        } catch {
            debugPrint(error)
            fatalError(error.localizedDescription)
        }
    }
    
    /// overide this method to define your own implmentation
    /// default implementaion checks for cancled or finished operation and throws error
    /// - Throws : `SFOError.safeOperationError` with reason `operationAlreadyCanceled`
    open func shouldStartOperation() throws {
        precondition(isCancelled || isFinished,
                     "operation with identifier \(identifier) is already canceled or finished, cannot start operation")
        if isCancelled || isFinished {
            isFinished = true
            isExecuting = false
            throw SFOError.safeOperationError(reason: .operationAlreadyCanceled("operation with identifier \(identifier) is already canceled, cannot start canceled operation")
            )
        }
        try startOperation()
    }
    
    /// This method will be called right after the checks succeded inside `shouldStartRunnable()`
    /// It start `runnable` method inside `autorealsepool` block
    open func startOperation() throws {
        try autoreleasepool {
            try operation()
        }
    }
    
    open func operation() throws {
        if operationExecutable != nil {
            try operationExecutable?({ [weak self] in
                guard let self = self else {
                    throw SFOError.safeOperationError(reason: .operationNotFoundNil)
                }
                try self.finishOperation()
            })
        }
    }
    
    // MARK: - Cancelation Method
    
    /// Do not override this method or call
    open override func cancel() {
        do {
            try cancelOperation()
        } catch {
            fatalError()
        }
    }
    
    open func willCancelOperation() {}
    
    open func cancelOperation() throws {
        isCancelled = true
        isExecuting = false
        isFinished = true
    }
    
    open func didCancelOperation() {}
    
    // MARK: - Finish Methods
    
    open func willFinishOperation() {}
    
    open func finishOperation() throws {
        isFinished = true
        isExecuting = false
        isCancelled = false
    }
    
    open func didFinishOperation() {}
    
    // MARK: - Queue Methods
    
    open func enqueue() throws {
        guard let queue = operationQueue else {
            throw SFOError
                .safeOperationError(reason: .queueFoundNil("Can not enqueue operation with identifier \(identifier)", type: .operation(" OperationQueue assosiatated with operation with identifier \(identifier) was found nil"))
            )
        }
        queue.addOperation(self)
    }
    
    open func waitUntilAllOperationAreFinished() throws {
        guard let queue = operationQueue else {
            throw SFOError.safeOperationError(reason: .canNotWaitForOtherOperation("""
                Could not wait for all operation to finish,
                OperationQueue associated on operation with identifier: \(name ?? "") was found nil
                """))
        }
//        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
    }
}
