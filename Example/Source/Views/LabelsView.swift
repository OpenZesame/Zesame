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
import RxSwift
import RxCocoa

final class LabelsView: UIStackView {

    fileprivate let titleLabel: UILabel
    fileprivate let valueTextView: UITextView

    init(
        titleStyle: UILabel.Style? = nil,
        valueStyle: UITextView.Style? = nil,
        stackViewStyle: UIStackView.Style? = nil
        ) {

        let defaultTitleStyle = UILabel.Style(font: .boldSystemFont(ofSize: 16), textColor: .black)
        let defaultvalueStyle = UITextView.Style(
            font: .systemFont(ofSize: 12),
            textColor: .darkGray,
            isEditable: false,
            isScrollEnabled: false
        )
        let defaultStackViewStyle = UIStackView.Style(spacing: 8, margin: 0)

        self.titleLabel = titleStyle.merged(other: defaultTitleStyle, mode: .overrideOther).make()
        self.valueTextView = valueStyle.merged(other: defaultvalueStyle, mode: .overrideOther).make()

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        apply(style: stackViewStyle.merged(other: defaultStackViewStyle, mode: .overrideOther))
        [valueTextView, titleLabel].forEach { insertArrangedSubview($0, at: 0) }
    }

    required init(coder: NSCoder) { interfaceBuilderSucks }
}

extension LabelsView {

    func setValue(_ value: CustomStringConvertible) {
        valueTextView.text = value.description
    }

}

extension Reactive where Base == LabelsView {
    var title: Binder<String?> { return base.titleLabel.rx.text }
    var value: ControlProperty<String?> { return base.valueTextView.rx.text }
}
