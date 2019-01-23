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
