//
//  OKThreadSafe.swift
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

protocol Lockable {
    func lock()
    func unlock()
}

extension Lockable {

    func synchronize<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
    
    func around<T>(_ closure: () throws-> T) rethrows-> T {
        lock(); defer { unlock() }
        return try closure()
    }

    func around(_ closure: () throws -> Void) rethrows {
        lock(); defer { unlock() }
        try closure()
    }
}

extension NSLock: Lockable {}

private final class RecursiveLock: Lockable {
    
    private var recursiveMutex = pthread_mutex_t()
    
    private var recursiveMutexAttr = pthread_mutexattr_t()
    
    init() {
        pthread_mutexattr_init(&recursiveMutexAttr)
        pthread_mutexattr_settype(&recursiveMutexAttr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&recursiveMutex, &recursiveMutexAttr)
    }
    
    @inline(__always)
    final func lock() {
        pthread_mutex_lock(&recursiveMutex)
    }
    
    @inline(__always)
    final func unlock() {
        pthread_mutex_unlock(&recursiveMutex)
    }
}

@propertyWrapper
@dynamicMemberLookup
public final class SFOThreadSafe<T> {
    
    private let lock = RecursiveLock()
    
    private var value: T

    public var wrappedValue: T {
        get { lock.around { value } }
        set { lock.around { value = newValue } }
    }

    public var projectedValue: SFOThreadSafe<T> { self }

    public init(_ value: T) {
        self.value = value
    }
    
    public init(wrappedValue: T) {
        value = wrappedValue
    }

    public func read<U>(_ closure: (T) throws -> U) rethrows -> U {
        try lock.around { try closure(self.value) }
    }

    @discardableResult
    public func write<U>(_ closure: (inout T) throws -> U) rethrows -> U {
        try lock.around { try closure(&self.value) }
    }
    
    public func write(_ closure: (inout T) throws -> Void) rethrows {
        try lock.around { try closure(&self.value) }
    }

    public subscript<Property>(dynamicMember keyPath: WritableKeyPath<T, Property>) -> Property {
        get { lock.around { value[keyPath: keyPath] } }
        set { lock.around { value[keyPath: keyPath] = newValue } }
    }
}
