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

public class SingleContentViewController<View, ViewModel>: UIViewController where View: UIView & SingleContentView, View.ViewModel == ViewModel {
    public typealias Input = ViewModel.Input
    public typealias Output = ViewModel.Output

    private let bag = DisposeBag()

    public let contentView: View
    public let viewModel: ViewModel

    public init(view contentView: View, viewModel: ViewModel) {
        self.contentView = contentView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.addSubview(contentView)
        contentView.edgesToSuperview()
        bind()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        contentView.backgroundColor = .white
    }

    public func input() -> Input {
        fatalError("Abstract, override me please")
    }

    public func bind() {
        let output = viewModel.transform(input: input())
        bound(output: output)
        contentView.populate(with: output).forEach { $0.disposed(by: bag) }
    }

    public func bound(output: Output) {
        fatalError("Abstract, override me")
    }


}
