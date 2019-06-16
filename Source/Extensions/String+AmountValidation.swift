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
    
    var decimalPlaces: Int {
        guard containsDecimalSeparator else { return 0 }
        
        let components = replacingIncorrectDecimalSeparatorIfNeeded().components(separatedBy: Locale.decimalSeparatorForSure)
        
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
    
    var doesNotContainMoreThanOneDecimalSeparator: Bool {
        guard replacingIncorrectDecimalSeparatorIfNeeded().components(separatedBy: Locale.decimalSeparatorForSure).count < 3 else {
            return false
        }
        return true
    }
    
    func replacingIncorrectDecimalSeparatorIfNeeded() -> String {
        return replacingOccurrences(of: ".", with: Locale.decimalSeparatorForSure).replacingOccurrences(of: ",", with: Locale.decimalSeparatorForSure)
    }
}

private extension String {
    var containsDecimalSeparator: Bool {
        let incorrectDecimalSeparatorReplacedIfNeeded = replacingIncorrectDecimalSeparatorIfNeeded()
        return incorrectDecimalSeparatorReplacedIfNeeded.contains(Locale.decimalSeparatorForSure)
    }
}
