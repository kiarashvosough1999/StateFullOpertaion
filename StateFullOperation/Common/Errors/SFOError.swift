//
//  OKError.swift
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

public enum SFOError: Error {
    case operationStateError(reason: SFOOperationStateError)
    case safeOperationError(reason: SFOSafeOperationError)
}

public enum SFOOperationStateError: Error {
    case dealocatedOperation(String)
    case operationIsNotExecutingToFinish(String)
    case cancelDuringWaitingForDeadline(String)
    case operationAlreadyCanceled(String)
    case misUseError(String)
}

public enum SFOSafeOperationError: Error {
    case operationAlreadyCanceled(String)
    case queueFoundNil(String, type:QueueType)
    case operationNotFound(String)
    case operationNotFoundNil
    case canNotAddDependency(String)
    case canNotWaitForOtherOperation(String)
}

public enum QueueType: Error {
    case operation(String?)
    case dispatch(String?)
}
