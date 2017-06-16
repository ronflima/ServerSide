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
// Created: 2017-03-26 by Ronaldo Faria Lima
// This file purpose: Server main process

import Foundation
import Venice

/// Arguments used internally for process control
///
/// - child: Process is a child process
/// - daemonize: Force daemonization of the process
enum ServerArguments: String {
    case child = "child"
    case daemonize = "daemonize"
}

/// Main coroutine related type. A server use it as an entry point.
public typealias MainCoroutine = (([String]) throws -> Void)

/// Secondary co-routine, called when the server is about to stop
public typealias AtExitCoroutine = ()->Void

/// Server. This class represents your server and provides initial services like
/// signal handling for proper integration with System V and upstart
/// initialization schemes.
public final class Server {
    fileprivate var serverCoroutine: Coroutine?
    fileprivate let lock: Lock! = Lock()
    fileprivate var exiting = false
    fileprivate var main: MainCoroutine?
    fileprivate var shouldDaemonize: Bool {
        return CommandLine.arguments.contains(ServerArguments.daemonize.rawValue)
    }

    /// Returns true if this server was started by another process.
    public var isChild: Bool {
        return CommandLine.arguments.contains(ServerArguments.child.rawValue)
    }
    /// Server executable
    public var serverExecutable: String {
        return CommandLine.arguments[0]
    }
    /// Command line arguments
    public var arguments: [String] {
        return CommandLine.arguments
    }
    /// At exit handler. Called when the server is about to finish its
    /// execution.
    public var atExit: AtExitCoroutine?
    /// Singleton pattern. There must be only a single instance of this class at
    /// any given time.
    public static let current = Server()

    private init() {
        // Signal.trap fails only if trying to trap .stop and .kill. So, we can
        // ignore it.
        try? Signal.trap(for: .term, .int, .hup) { [unowned self] (signal) in
            switch signal {
            case .term, .int: // Stop the process
                self.exiting = true
                try? self.stop()
            case .hup:        // Restart the process
                try? self.stop()
                try? self.start()
            default:
                break
            }
        }
    }
}

// MARK: - Server Lifecycle
public extension Server {
    /// Starts your server. This method returns only when your code has ended.
    ///
    /// - Remarks: This method returns only when daemonizing
    /// - Throws: 
    ///
    ///     - ServerSideError.alreadyRunning when trying to start the server a
    ///     second time.
    ///     - ServerSideError.noMainRoutine when trying to start a server
    ///     without a main routine
    public func start(main: @escaping MainCoroutine) throws {
        guard serverCoroutine == nil else {
            throw ServerSideError.alreadyRunning
        }
        if !isChild {
            var chldArgs = [ServerArguments.child.rawValue]
            chldArgs.append(contentsOf: arguments)
            if shouldDaemonize {
                Process.launchedProcess(launchPath: serverExecutable, arguments: chldArgs)
                return
            }
        }
        self.main = main
        try start()
    }

    fileprivate func start() throws {
        guard self.main != nil else {
            throw ServerSideError.noMainRoutine
        }
        serverCoroutine = try Coroutine { [unowned self] () in
            self.lock.lock()
            try? self.main?(self.arguments)
            self.lock.unlock()
        }
        waitLoop: while !lock.wait(until: 1.second.fromNow()) && serverCoroutine != nil {
            do {
                try Coroutine.yield()
            } catch {
                break waitLoop
            }
        }
        if serverCoroutine == nil {
            // Forced stop. The lock is probably still locked. If so, unlock
            // it.
            if lock.isLocked {
                lock.unlock()
            }
        }
    }

    /// Stops the server execution.
    ///
    /// - Throws:
    ///
    ///    - ServerSideError.notRunning if trying to stop the server a second
    ///    time.
    public func stop() throws {
        guard serverCoroutine != nil else {
            throw ServerSideError.notRunning
        }
        serverCoroutine?.cancel()
        serverCoroutine = nil
        if exiting {
            atExit?()
        }
    }
}

