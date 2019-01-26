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

extension UILabel: Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UILabel {
        return UILabel()
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByStringLiteral {

        public typealias View = UILabel

        public let text: String?
        public let textColor: UIColor?
        public let font: UIFont?
        public let numberOfLines: Int?

        public init(
            _ text: String? = nil,
            height: CGFloat? = nil,
            font: UIFont? = nil,
            textColor: UIColor? = nil,
            numberOfLines: Int? = nil,
            backgroundColor: UIColor? = nil
            ) {
            self.text = text
            self.textColor = textColor
            self.font = font
            self.numberOfLines = numberOfLines
            super.init(height: height, backgroundColor: backgroundColor)
        }

        public convenience init(stringLiteral title: String) {
            self.init(title)
        }

        static var `default`: Style {
            return Style()
        }

        public func merged(other: Style, mode: MergeMode) -> Style {
            func merge<T>(_ attributePath: KeyPath<Style, T?>) -> T? {
                return mergeAttribute(other: other, path: attributePath, mode: mode)
            }

            return Style(
                merge(\.text),
                height: merge(\.height),
                font: merge(\.font),
                textColor: merge(\.textColor),
                numberOfLines: merge(\.numberOfLines),
                backgroundColor: merge(\.backgroundColor)
            )
        }
    }

    public func apply(style: Style) {
        text = style.text
        font = style.font ?? .default
        textColor = style.textColor ?? .defaultText
        numberOfLines = style.numberOfLines ?? 1
    }
}
public enum MergeMode {
    case overrideOther
    case yieldToOther
}

extension Optional where Wrapped: Makeable {
    func merged(other: Wrapped, mode: MergeMode) -> Wrapped {
        guard let `self` = self else { return other }
        return `self`.merged(other: other, mode: mode)
    }
}
