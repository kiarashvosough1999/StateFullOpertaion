//
//  SafeOperation++OperationDependencyProtocol.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 5/21/1400 AP.
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


extension SafeOperation: OperationDependencyController {
    
    //MARK: - Dependencies
    
    /// Remove dependency from this operation,
    /// - Parameter identifier: Operation which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given identifier
    /// - Returns: `Self`
    @discardableResult
    public func removeDependency(with identifier: OperationIdentifier) throws -> Self {
        guard let op = self.dependencies.first(where: { OperationIdentifier(rawValue: $0.name!) == identifier }) else {
            throw SFOError.safeOperationError(reason:
                                            .operationNotFound(
                                                """
                                                operation with identifier\(identifier) not found to remove
                                                """
                                            )
            )
        }
        self.removeDependency(op)
        return self
    }
    
    /// Remove dependency from this operation,
    /// - Parameter name: Operation name which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    public func removeDependency(with name: String) throws -> Self {
        guard let op = self.dependencies.filter({ $0.name == name }).first else {
            throw SFOError.safeOperationError(reason:
                                            .operationNotFound(
                                                """
                                                operation with identifier\(identifier) not found to remove
                                                """
                                            )
            )
        }
        self.removeDependency(op)
        return self
    }
    
    /// Remove dependency from this operation and cancel target operation
    /// - Parameter name: Operation which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    public func removeDependencyAndCancelTraget(with name: String) throws -> Self {
        guard let op:Operation = dependencies.filter({ $0.name == name }).first else {
            throw SFOError.safeOperationError(reason:
                                            .operationNotFound(
                                                """
                                                operation with identifier\(identifier) not found to remove
                                                """
                                            )
            )
        }
        self.removeDependency(op)
        op.cancel()
        return self
    }
    
    /// Remove dependency from this operation and cancel source operation
    /// - Parameter name: Operation which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    public func removeDependencyAndCancel(with name: String) throws -> Self {
        guard let op:Operation = dependencies.filter({ $0.name == name }).first else {
            throw SFOError.safeOperationError(reason:
                                            .operationNotFound(
                                                """
                                                operation with identifier\(identifier) not found to remove
                                                """
                                            )
            )
        }
        self.removeDependency(op)
        self.cancel()
        return self
    }
    
    /// make this operation depend on another
    /// - Parameter op: Operation which this Operation will be depend on
    /// - Throws: OperationControllerError.canNotAddDependency if Target or Source Operation was canceled or finished
    /// - Returns: `Self`
    @discardableResult
    public func dependsOn(_ op: Operation) throws -> Self {
        if op.isFinished || op.isCancelled {
            throw SFOError.safeOperationError(reason:
                                            .canNotAddDependency(
                                            """
                                             destenation operation with identifier\(identifier) can not have dependency,
                                            it is canceled or finished
                                            """
                                            )
            )
        }
        if isFinished || isCancelled {
            throw SFOError.safeOperationError(reason:
                                            .canNotAddDependency(
                                            """
                                            operation with identifier\(identifier) can not have dependency,
                                            it is canceled or finished
                                            """
                                            )
            )
        }
        self.addDependency(op)
        return self
    }
    
    /// make this operation depend on another with given identifier
    /// - Parameter identifier: Target Operation which this operation will be depend on
    /// - Throws: OperationControllerError.canNotAddDependency if Target or Source Operation was canceled or finished or `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    public func dependsOnOperation(with identifier: OperationIdentifier) throws -> Self {
        guard let op = self.dependencies.first(where: { OperationIdentifier(rawValue: $0.name!) == identifier }) else {
            throw SFOError.safeOperationError(reason: .operationNotFound(
                """
                operation with identifier\(identifier) not found to remove
                """
            ))
        }
        if op.isFinished || op.isCancelled {
            throw SFOError.safeOperationError(reason:
                                            .canNotAddDependency(
                                            """
                                            destenation operation with identifier\(identifier) can not have dependency,
                                            it is canceled or finished
                                            """
                                            )
            )
        }
        if isFinished || isCancelled {
            throw SFOError.safeOperationError(reason:
                                            .canNotAddDependency(
                                            """
                                            this operation with identifier\(identifier) can not have dependency,
                                            it is canceled or finished
                                            """
                                            )
            )
        }
        self.addDependency(op)
        return self
    }
}


public protocol OperationDependencyController: AnyObject {
    
    /// make this operation depend on another with given identifier
    /// - Parameter identifier: Target Operation which this operation will be depend on
    /// - Throws: OperationControllerError.canNotAddDependency if Target or Source Operation was canceled or finished or `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    func dependsOnOperation(with identifier: OperationIdentifier) throws -> Self
    
    /// Remove dependency from current operation,
    /// - Parameter identifier: Operation which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given identifier
    /// - Returns: `Self`
    @discardableResult
    func removeDependency(with identifier: OperationIdentifier) throws -> Self
    
    /*
    
    /// Remove dependency from this operation,
    /// - Parameter name: Operation name which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    func removeDependency(with name: String) throws -> Self
    
    /// Remove dependency from this operation and cancel target operation
    /// - Parameter name: Operation which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    func removeDependencyAndCancelTraget(with name: String) throws -> Self
    
    /// make this operation depend on another
    /// - Parameter op: Operation which this Operation will be depend on
    /// - Throws: OperationControllerError.canNotAddDependency if Target or Source Operation was canceled or finished
    /// - Returns: `Self`
    @discardableResult
    func dependsOn(_ op: Operation) throws -> Self
    
    /// Remove dependency from this operation and cancel source operation
    /// - Parameter name: Operation which `this` operation depends on
    /// - Throws: `OperationControllerError.operationNotFound` if no operation found with the given name
    /// - Returns: `Self`
    @discardableResult
    func removeDependencyAndCancel(with name: String) throws -> Self
     */
}
