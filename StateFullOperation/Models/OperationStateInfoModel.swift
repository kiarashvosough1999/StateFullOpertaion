//
//  QueueState.swift
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

public struct OperationStateInfoModel {
    
    public var enqueued: Bool
    public var enqueuedAfter: TimeInterval
    public var suspendedAfter: TimeInterval
    public var willEnqueue: Bool { !enqueued && enqueuedAfter > 0.0 }
    
    public init(enqueued: Bool, enqueuedAfter: TimeInterval = 0.0, suspendedAfter: TimeInterval = 0.0) {
        self.enqueued = enqueued
        self.enqueuedAfter = enqueuedAfter
        self.suspendedAfter = suspendedAfter
    }
    
}
