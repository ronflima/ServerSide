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
// This file purpose: Server struct

import POSIX
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

/// This class is an abstraction for a server instance.
public final class Server {
    /// This instance PPID
    public let ppid: PID
    /// This instance PID
    public let pid: PID
    /// Server delegate
    public weak var delegate: ServerDelegate?
    /// Default, and only instance, of the server
    public static let `default` = Server()
    /// Signal delegate. This is a class variable since signal handling is done
    /// at the process level.
    static let signalHandler = SignalHandler(server: Server.default)
    
    /// Initializer. Adds a delegate to the running instance
    fileprivate init() {
        self.ppid = getppid()
        self.pid = getpid()
    }

    /// Starts this instance execution
    public func start() {
        delegate?.loadConfiguration()
        delegate?.start(arguments: CommandLine.arguments)
    }

    /// Stops this instance execution
    public func stop() {
        delegate?.stop()
    }

    /// Restarts the server, refreshing it. In fact, this is a convenience
    /// method that stops and starts the server again.
    public func restart() {
        stop()
        start()
    }
}

/// Handles signals.
///
/// - comments: It is supposed to have only a single instance of this class. It
/// was designed with this in mind.
class SignalHandler {
    /// Dependency injected through initializer
    weak var server: Server?
    
    /// Installs it as a signal handler delegate
    init(server: Server) {
        do {
            try Signal.trap(for: .hup, .int, .segv, .term, .abrt, handler: handleSignal(signal:))
        } catch { /* Do nothing */ }
        self.server = server
    }

    /// Handles a signal received by the process
    func handleSignal(signal: SignalType) {
        switch signal {
        case .hup:
            server?.restart()
        case .int, .term:
            server?.stop()
            exit(EXIT_SUCCESS)
        case .abrt, .segv:
            exit(EXIT_FAILURE)
        default:
            // Do nothing.
            break
        }
    }
}
