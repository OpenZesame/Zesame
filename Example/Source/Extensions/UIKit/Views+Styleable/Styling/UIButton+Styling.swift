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

extension UIButton: Styling, StaticEmptyInitializable, ExpressibleByStringLiteral {

    public static func createEmpty() -> UIButton {
        return UIButton(type: .custom)
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByStringLiteral {

        public typealias View = UIButton

        let text: String?
        let textColor: UIColor?
        let colorNormal: UIColor?
        let colorDisabled: UIColor?
        let font: UIFont?
        let isEnabled: Bool?

        init(
            _ text: String? = nil,
            height: CGFloat? = nil,
            font: UIFont? = nil,
            textColor: UIColor? = nil,
            colorNormal: UIColor? = nil,
            colorDisabled: UIColor? = nil,
            isEnabled: Bool? = nil
            ) {
            self.text = text
            self.textColor = textColor
            self.colorNormal = colorNormal
            self.colorDisabled = colorDisabled
            self.font = font
            self.isEnabled = isEnabled
            super.init(height: height ?? .defaultHeight, backgroundColor: nil)
        }

        public convenience init(stringLiteral title: String) {
            self.init(title)
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
                colorNormal: merge(\.colorNormal),
                colorDisabled: merge(\.colorDisabled),
                isEnabled:  merge(\.isEnabled)
            )
        }
    }

    public func apply(style: Style) {
        setTitle(style.text, for: UIControl.State())
        setTitleColor(style.textColor ?? .defaultText, for: UIControl.State())
        titleLabel?.font = style.font ?? .default
        let colorNormal = style.colorNormal ?? .green
        let colorDisabled = style.colorDisabled ?? .gray
        setBackgroundColor(colorNormal, for: .normal)
        setBackgroundColor(colorDisabled, for: .disabled)
        isEnabled = style.isEnabled ?? true
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: state)
    }

}
