//
//  ScrollViewOwner.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-20.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

typealias ScrollingStackView = ScrollViewOwner & StackViewStyling

class ScrollViewOwner: UIView {

    lazy var scrollView: UIScrollView = {
        let contentView = makeView()
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.edgesToSuperview()
        contentView.widthToSuperview()
        return scrollView
    }()

    init() {
        super.init(frame: .zero)
        addSubview(scrollView)
        scrollView.edgesToSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

private extension ScrollViewOwner {
    func makeView() -> UIView {
        guard let viewProvider = self as? ContentViewProvider else { fatalError("should conform to `ContentViewProvider`") }
        return viewProvider.makeContentView()
    }
}
