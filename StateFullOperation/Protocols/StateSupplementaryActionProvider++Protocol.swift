//
//  StateSupplementaryActionProvider.swift
//  StateFullOpertaion
//
//  Created by Kiarash Vosough on 8/11/1400 AP.
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
 
 Provide StateFull Operation some settable actions
 
 this could be handy if some extra actions is needed after state change
 as it is not possible to access state directly(bu vice-versa) this protocol make it possible for
 states to execute the block which is provided.
 
 */

public protocol StateSupplementaryActionProvider: AnyObject {
    
    typealias WorkerBlock = () -> Void
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `finished`.
    var onFinished: WorkerBlock? { get }
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `canceled`.
    /// instead of overriding main() function, override this property and provide a block of what you want when the operation start.
    var onCanceled: WorkerBlock? { get }
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `executing`.
    var onExecuting: WorkerBlock? { get }
    
    /// Could be provided by any subclass to execute some code after the operation state changes to `suspended`.
    /// The operation itself does not support suspending.
    /// This extra state help some task to be paused and be resumed when the user asked
    /// The operation will remain on queue but not executing
    /// For URLSessionDataTasks:
    /// - Provide block only on download and upload tasks
    /// - Providing block on other tasks and using it may result in crash, leak and unexpected usage of network data.
    var onSuspended: WorkerBlock? { get }
}
