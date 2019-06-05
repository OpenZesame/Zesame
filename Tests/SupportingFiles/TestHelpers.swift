//
// MIT License
//
// Copyright (c) 2018-2019 Open Zesame (https://github.com/OpenZesame)
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
import XCTest

func XCTAssertThrowsSpecificError<ReturnValue, ExpectedError>(
    _ codeThatThrows: @autoclosure () throws -> ReturnValue,
    _ error: ExpectedError,
    _ message: String = ""
    ) where ExpectedError: Swift.Error & Equatable {
    
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        guard let expectedErrorType = someError as? ExpectedError else {
            XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
            return
        }
        XCTAssertEqual(expectedErrorType, error)
    }
}

func XCTAssertThrowsSpecificError<ExpectedError>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ error: ExpectedError,
    _ message: String = ""
    ) where ExpectedError: Swift.Error & Equatable {
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        guard let expectedErrorType = someError as? ExpectedError else {
            XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
            return
        }
        XCTAssertEqual(expectedErrorType, error)
    }
}

func XCTAssertThrowsSpecificErrorType<E>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ errorType: E.Type,
    _ message: String = ""
    ) where E: Swift.Error & Equatable {
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        XCTAssertTrue(someError is E, "Expected code to throw error of type: <\(E.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
    }
}

func XCTAssertAllEqual<Item>(_ items: Item...) where Item: Equatable {
    forAll(items) {
        XCTAssertEqual($0, $1)
    }
}

func XCTAssertAllInequal<Item>(_ items: Item...) where Item: Equatable {
    forAll(items) {
        XCTAssertNotEqual($0, $1)
    }
}

private func forAll<Item>(_ items: [Item], compareElemenets: (Item, Item) -> Void) where Item: Equatable {
    var lastIndex: Array<Item>.Index?
    for index in items.indices {
        defer { lastIndex = index }
        guard let last = lastIndex else { continue }
        let fooElement: Item = items[last]
        let barElement: Item = items[index]
        compareElemenets(fooElement, barElement)
    }
}
