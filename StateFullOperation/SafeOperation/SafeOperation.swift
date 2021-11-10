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
 
 It offers new features which the operation itself does not support or could be so tricky to use
 
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
open class SafeOperation: Operation, OperationLifeCycleProvider, ConfigurableOperation {
    
    internal private(set) var configuration: SafeOperationConfiguration
    
    /// Any changes to operation flags will be stored on these variables
    public lazy var _executing: Bool = false
    
    public lazy var _finished: Bool = false
    
    public lazy var _canceled: Bool = false
    
    public lazy var _suspended: Bool = false
    
    /// `Thread Safe Readable and Settable` Variables Indicating Operation Flags
    
    /**
     
     `All these properties are observed (as key value) and any chnages should be informed`
     
     If you have the intent to override this variable, take care of two things:
     - Synchronize the setter and getter.
     - Informs the observed object that the value of a given property is about to change.
     
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
            willChangeValue(forKey: #keyPath(Operation.isFinished))
            lock.synchronize { _finished = newValue }
            didChangeValue(forKey: #keyPath(Operation.isFinished))
        }
    }
    
    open override var isCancelled: Bool {
        get {
            return lock.synchronize { _canceled }
        }
        set {
            willChangeValue(forKey: #keyPath(Operation.isCancelled))
            lock.synchronize { _canceled = newValue }
            didChangeValue(forKey: #keyPath(Operation.isCancelled))
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
    
    open var onCanceledAction: SFOAlias.OnOperationCanceled?
    
    open var onFinishedAction: SFOAlias.OnOperationFinished?
    
    open var onExecutingAction: SFOAlias.OnOperationExecuting?
    
    open var operationExecutable: SFOAlias.OperationBlock?
    
    /// Overridable property indicating whether the operation is `async` or not
    open override var isAsynchronous: Bool { return true }
    
    /// a `mutex lock` to `synchronize` Control properties between threads
    public let lock: NSLock
    
    /// The `OperationQueue` which this operation work with
    /// Any unconsidered manipulation on this reference will results in unexcpected behavior on queue
    public weak var operationQueue: OperationQueue?
    
    // MARK: - init
    public init(operationQueue: OperationQueue?,
                configuration: SafeOperationConfiguration) {
        self.lock = NSLock()
        self.operationQueue = operationQueue
        self.configuration = configuration
        super.init()
        setOperationConfigurationChanges()
    }
    
    private func setOperationConfigurationChanges() {
        self.queuePriority = configuration.queuePriority
        self.qualityOfService = configuration.qualityOfService
        self.name = configuration.identifier.rawValue
    }
    
    /// Do not override this method
    /// Override shouldStartRunnable instead
    public override func start() {
        do {
            onExecutingAction?()
            try shouldStartRunnable()
        } catch {
            fatalError()
        }
    }
    
    open func shouldStartRunnable() throws {
        if isCancelled || isFinished {
            isFinished = true
            isExecuting = false
            throw SFOError.safeOperationError(reason: .operationAlreadyCanceled("operation with identifier \(identifier) is already canceled, cannot start canceled operation")
            )
        }
        try startRunnable()
    }
    
    open func startRunnable() throws {
        try autoreleasepool {
            try runnable()
        }
    }
    
    open func runnable() throws {
        if operationExecutable == nil {
            didFinishRunnable()
        } else {
            operationExecutable?({ [weak self] in
                guard let self = self else {
                    throw SFOError.safeOperationError(reason: .operationNotFoundNil)
                }
                try self.finishRunnable()
            })
        }
    }
    
    open override func cancel() {
        super.cancel()
        do {
            try cancelRunnable()
            onCanceledAction?()
        } catch {
            fatalError()
        }
    }
    
    open func cancelRunnable() throws {
        isExecuting = false
        isFinished = true
        isCancelled = true
        didCancelRunnable()
        onCanceledAction?()
    }
    
    open func didCancelRunnable() {}
    
    open func finishRunnable() throws {
        isExecuting = false
        isFinished = true
        isCancelled = false
        didFinishRunnable()
        onFinishedAction?()
    }
    
    open func didFinishRunnable() {}
    
    open func enqueueSelf() throws {
        guard let queue = operationQueue else {
            throw SFOError
                .safeOperationError(reason: .queueFoundNil("Can not enqueue operation with identifier \(identifier)", type: .operation(" OperationQueue assosiatated with operation with identifier \(identifier) was found nil"))
            )
        }
        queue.addOperation(self)
    }
    
    open func waitUntilAllOperationsAreFinished() throws {
        guard let queue = operationQueue, configuration.waitUntilAllOperationsAreFinished else {
            throw SFOError.safeOperationError(reason: .canNotWaitForOtherOperation("""
                Could not wait for all operation to finish,
                OperationQueue associated on operation with identifier: \(name ?? "") was found nil
                """))
        }
        queue.waitUntilAllOperationsAreFinished()
    }
}
