//
// MIT License
//
// Copyright (c) 2018-2026 Open Zesame (https://github.com/OpenZesame)
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

import Foundation

/// Thread-safe monotonic generator for JSON-RPC request `id` values. Marked
/// `@unchecked Sendable` because all mutable state is guarded by `NSLock`.
public final class RequestIdGenerator: @unchecked Sendable {
    /// Process-wide singleton. The Zilliqa JSON-RPC API only requires that a request's `id` be
    /// echoed back in the response, so a single counter for the whole process is sufficient.
    public static let shared = RequestIdGenerator()

    /// Monotonic counter. Mutated only under ``lock``.
    private var id: Int = 0

    /// Mutex guarding ``id``.
    private let lock = NSLock()

    /// Singleton; initialiser is private to prevent additional counters.
    private init() {}

    /// Returns the current ``id`` and post-increments under ``lock``.
    private func nextId() -> String {
        lock.withLock {
            defer { id += 1 }
            return id.description
        }
    }

    /// Returns the next sequential id as a decimal string (`"0"`, `"1"`, …).
    public static func nextId() -> String {
        shared.nextId()
    }
}
