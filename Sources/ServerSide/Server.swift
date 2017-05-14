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
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

/// Arguments used internally for process control
///
/// - child: Process is a child process
/// - daemonize: Force daemonization of the process
enum ServerArguments: String {
    case child = "child"
    case daemonize = "daemonize"
}

public final class Server {
    static var server: Server?
    var serverProcess: Process?
    var isChild: Bool {
        return CommandLine.arguments.contains(ServerArguments.child.rawValue)
    }
    var shouldDaemonize: Bool {
        return CommandLine.arguments.contains(ServerArguments.daemonize.rawValue)
    }
    var serverExecutable: String {
        return CommandLine.arguments[0]
    }
    var arguments: [String] {
        return CommandLine.arguments
    }
    
    /// Application delegate. Here, you provide your application entry-point.
    public var delegate: (([String])->Void)?
    
    /// This is called when your server is about to terminate, for instance, after receiving a termination signal.
    public var terminationHandler: ((Process)->Void)?
    
    /// Singleton pattern. There must be only a single instance of this class at any given time.
    public static var current: Server {
        if server == nil {
            server = Server()
        }
        return server!
    }

    init() {}
}

// MARK: - Server Lifecycle
public extension Server {
    /// Starts your server. This method returns only when your code has ended.
    public func start() {
        guard serverProcess == nil else {
            // If we have already started, don't do it again.
            return
        }
        if isChild {
            // Starts the child instance, effectivelly
            delegate?(CommandLine.arguments)
            return
        }
        var arguments = [ServerArguments.child.rawValue]
        arguments.append(contentsOf: CommandLine.arguments)
        if shouldDaemonize {
            // Daemonize it 😈.
            // Check if daemonization argument is on command line. If so, get it out to send a 
            // clean argument line to the child server.
            if let idx = arguments.index(of: ServerArguments.daemonize.rawValue) {
                arguments.remove(at: idx)
            }
            serverProcess = Process.launchedProcess(launchPath: serverExecutable, arguments: CommandLine.arguments)
            serverProcess?.waitUntilExit()
            return
        }
        // No. We don't need to daemonize. So, make it happen.
        delegate?(arguments)
    }
    
    /// Stops your server. Terminate will send a TERM signal to it.
    public func stop() {
        guard let process = serverProcess else {
            // There is nothing to stop. So, quit.
            return
        }
        if process.isRunning {
            process.terminate()
        }
    }
}
