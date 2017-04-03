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

/// Possible running states for a server process
public enum ServerState {
    /// Server was created but is not yet running
    case created
    /// Server is running
    case running
    /// Server was stopped
    case stopped
    /// Server is restarting
    case restarting
}

/// This class is an abstraction for a server instance. Each instance runs in
/// its own address space, i.e., in a child process.
public final class Server {
    /// This instance PPID
    let ppid: PID
    /// This instance PID
    let pid: PID
    /// Server delegate
    public weak var delegate: ServerDelegate?
    /// Server state
    public var state = ServerState.created
    /// Default, and only instance, of the server
    static let `default` = Server()
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
        state = .running
        delegate?.loadConfiguration?()
        delegate?.start(arguments: CommandLine.arguments)
    }

    /// Stops this instance execution
    public func stop() {
        delegate?.stop()
        state = .stopped
    }

    /// Kills this instance by sending a KILL signal to it.
    ///
    /// - remarks: Use this only in extreme situations. This will make your
    /// process end without notice. Any pending buffers will not be flushed and
    /// all resources will be lost.
    func kill() {
        Signal.killPid(signal: .kill)
    }

    /// Restarts the server, refreshing it. In fact, this is a convenience
    /// method that stops and starts the server again.
    public func restart() {
        state = .restarting
        stop()
        start()
    }
}

/// Handles signals.
///
/// - comments: It is supposed to have only a single instance of this struct. It
/// was designed with this in mind.
struct SignalHandler: SignalHandlerDelegate {
    /// Dependency injected through initializer
    weak var server: Server?
    
    /// Installs it as a signal handler delegate
    init(server: Server) {
        Signal.delegate = self
        let signals: [SignalType] = [.hup, .int, .segv, .term, .abrt]
        for signal in signals {
            Signal.setTrap(signal: signal, action: .handle)
        }
        self.server = server
    }

    // MARK: SignalHandlerDelegate

    /// Handles a signal received by the process
    mutating func handleSignal(signal: SignalType?) {
        guard signal != nil else {
            return
        }
        switch signal! {
        case .hup:
            server?.restart()
        case .int, .term:
            server?.stop()
        case .abrt:
            // TODO: Log here what happened and kill the process
            server?.kill()
        default:
            // Do nothing.
            break
        }
    }
}
