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
// Created: 2017-02-10 by Ronaldo Faria Lima
// This file purpose: Protocol for swift server delegates

/// The ServerDelegate protocol is the entry-point of your server. ServerSide
/// runtime will call your code in certain points in order to change several
/// states that would be necessary for proper operation.
public protocol ServerDelegate: class {
    /// Load configuration. Your server must implement this method if it depend
    /// on some configuration stored on files somewhere. This is called by the
    /// run-time during server bootstrap and reload.
    func loadConfiguration()
    
    /// Entry point for your server. It is the main execution routine.
    func start(arguments: [String])
    
    /// Called by the run-time in order to stop your server. Use this entry
    /// point to do a cleanup before exiting.
    func stop()
}

extension ServerDelegate {
    func loadConfiguration() {}
}
