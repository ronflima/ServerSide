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
// Created: 2017-06-12 by Ronaldo Faria Lima
// This file purpose: Server side exceptions and errors


/// Errors thrown by ServerSide software
public enum ServerSideError: Error {
    /// Failed to start main server co-routine
    case cannotStartCoroutine
    /// Server is already running. Tried to start another server coroutine.
    case alreadyRunning
    /// Tried to stop a server that is not running
    case notRunning
    /// Tried to start a server without an entry point
    case noMainRoutine
}
