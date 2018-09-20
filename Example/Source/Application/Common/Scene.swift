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

/// The "Single-Line Controller" base class
class Scene<View, ViewModel>: UIViewController where View: UIView & ViewModelled, View.ViewModel == ViewModel {

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
