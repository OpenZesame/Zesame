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

extension String {
    
    func decimalPlaces(
        decimalSeparator getDecimalSeparator: @autoclosure () -> String = { Locale.current.decimalSeparatorForSure }()
    ) -> Int {
        
        let decimalSeparator = getDecimalSeparator()
        
        guard containsDecimalSeparator(decimalSeparator: decimalSeparator) else { return 0 }
        
        let components = replacingIncorrectDecimalSeparatorIfNeeded(decimalSeparator: decimalSeparator).components(separatedBy: decimalSeparator)
        
        if components.count < 2 { // strange case, should have been covered by `guard containsDecimalSeparator`
            return 0 // integer => 0 decimal places
        } else if components.count > 2 { // contains double separator, not a valid number at all
            fatalError("invalid string")
        } else {
            assert(components.count == 2)
            let decimalStringPart = components.last!
            return decimalStringPart.components(separatedBy: "0").count
        }
    }
    
    func doesNotContainMoreThanOneDecimalSeparator(
        decimalSeparator getDecimalSeparator: @autoclosure () -> String = { Locale.current.decimalSeparatorForSure }()
    ) -> Bool {
        
         let decimalSeparator = getDecimalSeparator()
        
        guard replacingIncorrectDecimalSeparatorIfNeeded(decimalSeparator: decimalSeparator).components(separatedBy: decimalSeparator).count < 3 else {
            return false
        }
        return true
    }
    
    func replacingIncorrectDecimalSeparatorIfNeeded(
        decimalSeparator getDecimalSeparator: @autoclosure () -> String = { Locale.current.decimalSeparatorForSure }()
    ) -> String {
        
        let decimalSeparator = getDecimalSeparator()
        
        return self
            .replacingOccurrences(of: ".", with: decimalSeparator)
            .replacingOccurrences(of: ",", with: decimalSeparator)
    }
}



private extension String {
    
    func containsDecimalSeparator(
        decimalSeparator getDecimalSeparator: @autoclosure () -> String = { Locale.current.decimalSeparatorForSure }()
        ) -> Bool {
        
        let decimalSeparator = getDecimalSeparator()
        
        let incorrectDecimalSeparatorReplacedIfNeeded = replacingIncorrectDecimalSeparatorIfNeeded(decimalSeparator: decimalSeparator)
        
        return incorrectDecimalSeparatorReplacedIfNeeded.contains(decimalSeparator)
    }
}
