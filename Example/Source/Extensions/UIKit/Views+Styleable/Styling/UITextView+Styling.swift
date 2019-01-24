//
// Copyright 2019 Open Zesame
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under thexc License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
