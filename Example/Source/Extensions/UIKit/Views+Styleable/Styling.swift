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

import UIKit

public protocol Styling {
    associatedtype Style: ViewStyling
    func apply(style: Style)
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self {

    init(style: Style) {
        self = Self.createEmpty()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = style.backgroundColor ?? .white
        if let height = style.height {
            self.height(height)
        }
        apply(style: style)
    }
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self, Style: ExpressibleByStringLiteral, Self.Style.StringLiteralType == String  {

    public init(stringLiteral value: String) {
        let style = Style.init(stringLiteral: value)
        self = Self.init(style: style)
    }
}
