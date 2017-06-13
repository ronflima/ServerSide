// -*-swift-*-
// The MIT License (MIT)
//
// Copyright (c) 2017 - Nineteen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Created: 2017-06-09 by Ronaldo Faria Lima
// This file purpose: Simple lock implementation to work with co-routines.

import Venice

/// Simple lock mechanism to synchronize two different co-routines.
///
/// - Remarks: This is a simple locking mechanism. It uses channels to
/// sychronize two or more co-routines waiting for a lock to be released.
///
/// - Important: This simple implementation is not a owned lock. Any coroutine
/// can lock/unlock. For now, it is sufficient for Server Side purposes.
class Lock {
    /// Channel used for coroutine synchronization
    let channel: Channel<Bool>!
    /// Predicate
    fileprivate var locked = false

    /// Returns true if this lock is locked
    var isLocked: Bool {
        return locked
    }

    /// Failable initializer. Returns nil if a channel could not be created.
    init? () {
        channel = try? Channel<Bool>()
        guard channel != nil else {
            return nil
        }
    }

    deinit {
        locked = false
        channel.done()
    }

    /// Tries to acquire a lock.
    ///
    /// - Returns: true, if the lock could be acquired. False, otherwise.
    @discardableResult func lock() -> Bool {
        guard !locked else {
            return false
        }
        locked = true
        return true
    }

    /// Tries to unlock a previously acquired lock.
    @discardableResult func unlock() -> Bool {
        guard locked else {
            return false
        }
        do {
            try channel.send(true, deadline: 1.seconds.fromNow())
        } catch VeniceError.deadlineReached {
            // no one listening. Its okay
        } catch {
            return false
        }
        locked = false
        return true
    }

    /// Wait for a lock to be unlocked.
    func wait(until: Deadline) -> Bool {
        guard locked else {
            return false
        }
        var quitWaiting = false
        while !quitWaiting {
            do {
                quitWaiting = try channel.receive(deadline: until)
            } catch {
                do { try Coroutine.yield() } catch { }
                // Returns the predicate since it could be changed elsewhere.
                return locked
            }
        }
        return true
    }
}
