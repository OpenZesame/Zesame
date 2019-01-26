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

extension UITextField: EmptyInitializable, Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UITextField {
        return UITextField(frame: .zero)
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByStringLiteral {

        public typealias View = UITextField

        public let placeholder: String?
        public let text: String?
        public let textColor: UIColor?
        public let font: UIFont?

        public init(
            _ placeholder: String? = nil,
            text: String? = nil,
            height: CGFloat? = nil,
            font: UIFont? = nil,
            textColor: UIColor? = nil,
            backgroundColor: UIColor? = nil
            ) {
            self.placeholder = placeholder
            self.text = text
            self.font = font
            self.textColor = textColor
            super.init(height: height ?? .defaultHeight, backgroundColor: backgroundColor)
        }

        public convenience init(stringLiteral placeholder: String) {
            self.init(placeholder)
        }

        public func merged(other: Style, mode: MergeMode) -> Style {
            func merge<T>(_ attributePath: KeyPath<Style, T?>) -> T? {
                return mergeAttribute(other: other, path: attributePath, mode: mode)
            }

            return Style(
                merge(\.placeholder),
                text: merge(\.text),
                height: merge(\.height),
                font: merge(\.font),
                textColor: merge(\.textColor),
                backgroundColor: merge(\.backgroundColor)
            )
        }
    }

    public func apply(style: Style) {
        placeholder = style.placeholder
        textColor = style.textColor ?? .defaultText
        font = style.font ?? .default
        text = style.text
        layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        layer.borderWidth = 0.5
    }
}

public extension CGFloat {
    static var defaultHeight: CGFloat { return 44 }
}
