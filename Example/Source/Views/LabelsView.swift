//
//  LabelsView.swift
//  ZesameiOSExample
//
//  Created by Alexander Cyon on 2018-09-14.
//  Copyright © 2018 Open Zesame. All rights reserved.
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
