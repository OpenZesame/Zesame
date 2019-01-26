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

// MARK: - Style

extension UITextView: Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UITextView {
        return UITextView()
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByStringLiteral {
        public func merged(other: Style, mode: MergeMode) -> Style {
            func merge<T>(_ attributePath: KeyPath<UITextView.Style, T?>) -> T? {
                return mergeAttribute(other: other, path: attributePath, mode: mode)
            }

            return UITextView.Style(
                textAlignment: merge(\.textAlignment),
                font: merge(\.font),
                textColor: merge(\.textColor),
                backgroundColor: merge(\.backgroundColor),
                isEditable: merge(\.isEditable),
                isSelectable: merge(\.isSelectable),
                isScrollEnabled: merge(\.isScrollEnabled),
                contentInset: merge(\.contentInset)
            )
        }


        public typealias View = UITextView
        var text: String?
        var textAlignment: NSTextAlignment?
        var textColor: UIColor?
        var font: UIFont?
        var isEditable: Bool?
        var isSelectable: Bool?
        var contentInset: UIEdgeInsets?
        var isScrollEnabled: Bool?

        public init(
            text: String? = nil,
            textAlignment: NSTextAlignment? = nil,
            height: CGFloat? = nil,
            font: UIFont? = nil,
            textColor: UIColor? = nil,
            backgroundColor: UIColor? = nil,
            isEditable: Bool? = nil,
            isSelectable: Bool? = nil,
            isScrollEnabled: Bool? = nil,
            contentInset: UIEdgeInsets? = nil
            ) {
            self.text = text
            self.textAlignment = textAlignment
            self.textColor = textColor
            self.font = font
            self.isEditable = isEditable
            self.isSelectable = isSelectable
            self.isScrollEnabled = isScrollEnabled
            self.contentInset = contentInset
            super.init(height: height, backgroundColor: backgroundColor)
        }

        public convenience init(stringLiteral title: String) {
            self.init(text: title)
        }
    }
}

// MARK: Apply Style
extension UITextView {
    public func apply(style: UITextView.Style) {
        text = style.text
        textAlignment = style.textAlignment ?? .left
        font = style.font ?? UIFont.default
        textColor = style.textColor ?? .defaultText
        backgroundColor = style.backgroundColor ?? .clear
        isEditable = style.isEditable ?? true
        isSelectable = style.isSelectable ?? true
        isScrollEnabled = style.isScrollEnabled ?? true
        contentInset = style.contentInset ?? UIEdgeInsets.zero
    }

    @discardableResult
    func withStyle(_ style: UITextView.Style, customize: ((UITextView.Style) -> UITextView.Style)? = nil) -> UITextView {
        translatesAutoresizingMaskIntoConstraints = false
        let style = customize?(style) ?? style
        apply(style: style)
        return self
    }
}
