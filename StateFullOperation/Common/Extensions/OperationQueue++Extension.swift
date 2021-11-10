//
//  OperationQueue++Extension.swift
//  StateFullOperation
//
//  Created by Kiarash Vosough on 8/18/1400 AP.
//

import Foundation

extension OperationQueue {
    
    @discardableResult
    public func addOperation(identifier: OperationIdentifier = .unique(),
                             queuePriority: Operation.QueuePriority = .normal,
                             qualityOfService: QualityOfService = .default,
                             _ operationBlock: @escaping SFOAlias.OperationBlock,
                             onCompleted: SFOAlias.OnOperationCompltion?,
                             onCanceled: SFOAlias.OnOperationCanceled? = nil,
                             onFinished: SFOAlias.OnOperationFinished? = nil,
                             onExecuting: SFOAlias.OnOperationExecuting? = nil) throws -> SafeOperation {
        let operation = SafeOperation(operationQueue: self, configuration: .init(identifier: identifier, queuePriority: queuePriority, qualityOfService: qualityOfService))
        operation.operationExecutable = operationBlock
        operation.onCompleted = onCompleted
        operation.onCanceledAction = onCanceled
        operation.onFinishedAction = onFinished
        operation.onExecutingAction = onExecuting
        try operation.enqueueSelf()
        return operation
    }
}
