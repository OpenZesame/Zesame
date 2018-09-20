//
//  Scene.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

import RxSwift
import TinyConstraints

/// Use typealias when you don't require a subclass. If your use case requires subclass, inherit from `SceneController`.
typealias Scene<View: UIView & ViewModelled> = SceneController<View>

/// The "Single-Line Controller" base class
class SceneController<View>: UIViewController where View: UIView & ViewModelled {
    typealias ViewModel = View.ViewModel

    private let bag = DisposeBag()

    private let contentView: View
    private let viewModel: ViewModel

    init(view contentView: View = View(), viewModel: ViewModel) {
        self.contentView = contentView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { interfaceBuilderSucks }
}

private extension Scene {

    func setup() {
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        edgesForExtendedLayout = .bottom
        contentView.edgesToSuperview()
        bind()
    }

    func bind() {
        let output = viewModel.transform(input: contentView.inputFromView)
        contentView.populate(with: output).forEach { $0.disposed(by: bag) }
    }
}
