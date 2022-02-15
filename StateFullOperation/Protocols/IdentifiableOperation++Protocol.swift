//
//  IdentifiableOperation++Protocol.swift
//  StateFullOperation
//
//  Created by Kiarash Vosough on 2/15/22.
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

public protocol IdentifiableOperation: AnyObject {
    var identifier: OperationIdentifier { get }
}

extension IdentifiableOperation where Self: Operation {
    
    /// `Unique` identifier for this operation
    /// This identifier shold stay unique or it will results in crash or mis behavior
    /// if attemting to add or remove dependency
    public var identifier: OperationIdentifier {
        precondition(name != nil, "")
        guard let name = name,
              let id = OperationIdentifier(rawValue: name) else {
            fatalError("operation has no identifier")
        }
        return id
    }
}
