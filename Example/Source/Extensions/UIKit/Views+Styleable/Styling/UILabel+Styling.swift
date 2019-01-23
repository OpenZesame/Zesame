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
