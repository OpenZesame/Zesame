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

extension UIStackView: Styling, StaticEmptyInitializable {

    public static func createEmpty() -> UIStackView {
        return UIStackView(arrangedSubviews: [])
    }

    public final class Style: ViewStyle, Makeable, ExpressibleByArrayLiteral {

        public typealias View = UIStackView

        let axis: NSLayoutConstraint.Axis?
        let alignment: UIStackView.Alignment?
        let distribution: UIStackView.Distribution?
        let views: [UIView]?
        let spacing: CGFloat?
        let margin: CGFloat?


        public init(
            _ views: [UIView]? = nil,
            axis: NSLayoutConstraint.Axis? = nil,
            alignment: UIStackView.Alignment? = nil,
            distribution: UIStackView.Distribution? = nil,
            spacing: CGFloat? = 16,
            margin: CGFloat? = 16
        ) {
            self.views = views
            self.axis = axis
            self.alignment = alignment
            self.distribution = distribution
            self.spacing = spacing
            self.margin = margin

            // background color is irrelevant for stackviews
            super.init(height: nil, backgroundColor: nil)
        }

        public convenience init(arrayLiteral views: UIView...) {
            self.init(views)
        }

        public static var `default`: Style {
            return Style()
        }

        public func merged(other: Style, mode: MergeMode) -> Style {
            func merge<T>(_ attributePath: KeyPath<Style, T?>) -> T? {
                return mergeAttribute(other: other, path: attributePath, mode: mode)
            }

            return Style(
                merge(\.views),
                axis: merge(\.axis),
                alignment: merge(\.alignment),
                distribution: merge(\.distribution),
                spacing: merge(\.spacing)
            )
        }
    }

    public func apply(style: Style) {
        if let views = style.views, !views.isEmpty {
            views.reversed().forEach { self.insertArrangedSubview($0, at: 0) }
        }
        axis = style.axis ?? .vertical
        alignment = style.alignment ?? .fill
        distribution = style.distribution ?? .fill
        spacing = style.spacing ?? 0
        if let margin = style.margin {
            layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
            isLayoutMarginsRelativeArrangement = true
        }
    }
}
