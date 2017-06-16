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
// Created: 2017-06-16 by Ronaldo Faria Lima
// This file purpose: Syslog log appender

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif
    
import Core

// Used to map syslog levels with Logger levels
extension Logger.Level: Hashable {
    public var hashValue: Int {
        return rawValue.hashValue
    }
}

// Wrapper for syslog. 
func syslog(priority : Int32, _ message : String, _ args : CVarArg...) {
    withVaList(args) { vsyslog(priority, message.cString(using: String.Encoding.utf8), $0) }
}

/// Log appender for Syslog integration 
public final class SyslogAppender: LogAppender {
    static let levelMapping: [Logger.Level: Int32] = [
      Logger.Level.trace  : LOG_DEBUG,
      Logger.Level.debug  : LOG_DEBUG,
      Logger.Level.info   : LOG_INFO,
      Logger.Level.warning: LOG_WARNING,
      Logger.Level.error  : LOG_ERR,
      Logger.Level.fatal  : LOG_EMERG,
      Logger.Level.all    : LOG_INFO
    ]
    public let levels: Logger.Level

    public init(levels: Logger.Level = .all, ident: String) {
        self.levels = levels
        openlog(ident, LOG_CONS|LOG_NDELAY|LOG_PID, LOG_USER)
    }

    deinit {
        closelog()
    }
    
    public func append(event: Logger.Event) {
        var logMessage = event.locationInfo.description
        if let message = event.message {
            logMessage = "\(logMessage): \(String(describing: message))"
        }
        syslog(priority: SyslogAppender.levelMapping[event.level]!, logMessage)
    }
}
