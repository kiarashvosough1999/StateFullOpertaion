//
//  OperationQueue++Extension.swift
//  StateFullOperation
//
//  Created by Kiarash Vosough on 8/18/1400 AP.
//

import Foundation

extension OperationQueue {
    
    @discardableResult
    public func addTask(identifier: OperationIdentifier = .unique(),
                        queuePriority: Operation.QueuePriority = .normal,
                        qualityOfService: QualityOfService = .default,
                        _ operationBlock: @escaping SFOAlias.OperationBlock,
                        onCompleted: SFOAlias.OnOperationCompltion?,
                        onCanceled: SFOAlias.OnOperationCanceled? = nil,
                        onFinished: SFOAlias.OnOperationFinished? = nil,
                        onExecuting: SFOAlias.OnOperationExecuting? = nil) throws -> SafeOperation {
        let operation = SafeOperation(operationQueue: self,
                                      configuration: .init(identifier: identifier,
                                                           queuePriority: queuePriority,
                                                           qualityOfService: qualityOfService))
        operation.operationExecutable = operationBlock
        operation.onCompleted = onCompleted
        operation.onCanceledOperationAction = onCanceled
        operation.onFinishedOperationAction = onFinished
        operation.onExecutingOperationAction = onExecuting
        try operation.enqueue()
        return operation
    }
}
