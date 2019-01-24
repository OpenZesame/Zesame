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
