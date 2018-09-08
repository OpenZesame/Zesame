//
//  SingleContentViewController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit

import RxSwift
import TinyConstraints

class SingleContentViewController<View, ViewModel>: UIViewController where View: UIView & SingleContentView, View.ViewModel == ViewModel {
    typealias Input = ViewModel.Input
    typealias Output = ViewModel.Output

    private let bag = DisposeBag()

    let contentView: View
    let viewModel: ViewModel

    init(view contentView: View, viewModel: ViewModel) {
        self.contentView = contentView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.addSubview(contentView)
        contentView.edgesToSuperview()
        bind()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        contentView.backgroundColor = .white
    }

    // MARK: - Overrideable Methods
    func input() -> Input {
        fatalError("Abstract, override me please")
    }

    func bound(output: Output) {}
}

private extension SingleContentViewController {
    func bind() {
        let output = viewModel.transform(input: input())
        bound(output: output)
        contentView.populate(with: output).forEach { $0.disposed(by: bag) }
    }
}
