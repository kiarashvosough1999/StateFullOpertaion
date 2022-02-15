//
//  QueueableOperation++Protocol.swift
//  StateFullOperation
//
//  Created by Kiarash Vosough on 2/15/22.
//

import Foundation

public protocol QueueableOperation {
    
    associatedtype Queue: AnyObject
    
    /// The `Queue` which this operation work with
    /// Any unconsidered manipulation on this reference will results in unexcpected behavior on queue
    /// Queue is attached to this operation as an associated object with objc runtime feature
    var operationQueue: Queue? { get set }
}
