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
import Security

/// Closure shape for a CSPRNG byte filler. Mirrors `SecRandomCopyBytes`'s contract: writes
/// `count` bytes into `bytes` and returns an OSStatus. Tests inject a failing variant to
/// exercise the error path; production keeps the default ``defaultRandomBytesProvider``.
typealias RandomBytesProvider = (
    _ count: Int,
    _ bytes: UnsafeMutablePointer<UInt8>
) -> Int32

/// Default provider — calls `SecRandomCopyBytes` against the platform CSPRNG. On Apple
/// platforms with valid arguments this never fails in practice.
let defaultRandomBytesProvider: RandomBytesProvider = { count, bytes in
    SecRandomCopyBytes(kSecRandomDefault, count, bytes)
}

/// Generates `count` cryptographically-secure random bytes using the platform CSPRNG
/// (`SecRandomCopyBytes`).
///
/// Used for keystore IVs, salts, and similar non-deterministic material. Throws an `NSError` in
/// the `Zesame.SecureRandom` domain (with the OSStatus code) if the underlying call fails — which
/// in practice indicates a serious system fault, not a recoverable error.
///
/// - Parameters:
///   - count: Number of random bytes to produce.
///   - provider: Override the byte source. Tests pass a failing closure to exercise the
///     error branch; production code should leave this at its default.
func securelyGenerateBytes(
    count: Int,
    provider: RandomBytesProvider = defaultRandomBytesProvider
) throws -> Data {
    var bytes = [UInt8](repeating: 0, count: count)
    let status = provider(count, &bytes)
    guard status == errSecSuccess else {
        throw NSError(domain: "Zesame.SecureRandom", code: Int(status))
    }
    return Data(bytes)
}
