//
//  OpenWalletController.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-05-26.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import UIKit
import ZilliqaSDK
import TinyConstraints
import RxSwift
import RxCocoa
//import ViewComposer

protocol OpenWalletUseCase {
    func createNewWallet() -> Observable<Wallet>
    func restoreWallet(from restoration: KeyRestoration) -> Observable<Wallet>
}

public struct KeyRestoration {}

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

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

public final class OpenWalletController: SingleContentViewController<OpenWalletView, OpenWalletViewModel> {

    public init(viewModel: OpenWalletViewModel) {
        let contentView = OpenWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func input() -> Input {
        return Input(createNewTrigger: contentView.createNewWalletButton.rx.tap.asDriver(), restoreTrigger: contentView.restoreWalletButton.rx.tap.asDriver())
    }

    public override func bound(output: Output) {
        print("nothing to do with bound")
    }
}



public protocol OpenWalletNavigator {
    func toOpenWallet()
    func toCreateNewWallet()
    func toRestoreWallet()
}
public final class DefaultOpenWalletNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
extension DefaultOpenWalletNavigator: OpenWalletNavigator {}
public extension DefaultOpenWalletNavigator {
    func toOpenWallet() {
        let viewModel = OpenWalletViewModel(navigator: self)
        let vc = OpenWalletController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    func toCreateNewWallet() {
        let navigator = DefaultCreateNewWalletNavigator(navigationController: navigationController)
        let viewModel = CreateNewWalletViewModel(navigator: navigator)
        let vc = CreateNewWalletController(viewModel: viewModel)
        let nc = UINavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true, completion: nil)
    }
    
    func toRestoreWallet() {}
}



public protocol CreateNewWalletNavigator {
    func toOpenWallet()
}

public final class DefaultCreateNewWalletNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
extension DefaultCreateNewWalletNavigator: CreateNewWalletNavigator {}
public extension DefaultCreateNewWalletNavigator {
    func toOpenWallet() {
        navigationController.dismiss(animated: true)
    }
}

public protocol ViewModelled {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

public struct OpenWalletViewModel {
    private let navigator: OpenWalletNavigator
    public init(navigator: OpenWalletNavigator) {
        self.navigator = navigator
    }
}

extension OpenWalletViewModel: ViewModelled {}
public extension OpenWalletViewModel {
    struct Input {
        fileprivate let createNewTrigger: Driver<Void>
        fileprivate let restoreTrigger: Driver<Void>
    }
    struct Output {
        public let createNew: Driver<Void>
        public let restore: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let createNewWallet = input.createNewTrigger.do(onNext: { [navigator] in
            navigator.toCreateNewWallet()
        })

        let restoreWallet = input.restoreTrigger.do(onNext: { [navigator] in
            navigator.toRestoreWallet()
        })

        return Output(createNew: createNewWallet, restore: restoreWallet)
    }
}

public struct CreateNewWalletViewModel {
    private let navigator: CreateNewWalletNavigator
    public init(navigator: CreateNewWalletNavigator) {
        self.navigator = navigator
    }
}
extension CreateNewWalletViewModel: ViewModelled {}
public extension CreateNewWalletViewModel {
    struct Input {}
    struct Output {}
    public func transform(input: Input) -> Output {
        fatalError()
    }
}

public final class CreateNewWalletController: SingleContentViewController<CreateNewWalletView, CreateNewWalletViewModel> {

    public init(viewModel: CreateNewWalletViewModel) {
        let contentView = CreateNewWalletView()
        super.init(view: contentView, viewModel: viewModel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func input() -> Input {
        fatalError()
    }
}

public final class CreateNewWalletView: StackViewOwningView {
    lazy var createNewWalletButton: UIButton = .make("New Wallet")
    lazy var stackViewStyle = Style.StackView([createNewWalletButton])
}
extension CreateNewWalletView: SingleContentView {}
public extension CreateNewWalletView {
    typealias ViewModel = CreateNewWalletViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        fatalError()
    }
}


public protocol EmptyInitializable {
    init()
}


public protocol SingleContentView: EmptyInitializable, AnyObject {
    associatedtype ViewModel: ViewModelled
    func populate(with viewModel: ViewModel.Output) -> [Disposable]
}


public class StackViewOwningView: UIView {
//    var stackViewStyle: Style.StackView { fatalError("Abstract, override me please") }
    func makeStackView() -> UIStackView {
        fatalError("override me")
    }

    lazy var stackView: UIStackView = {
        return makeStackView()
    }()

    public init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.edgesToSuperview()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

public final class OpenWalletView: StackViewOwningView {

    lazy var createNewWalletButton: UIButton = .make("New Wallet")
    lazy var restoreWalletButton: UIButton = .make("Restore Wallet")
    override func makeStackView() -> UIStackView { return .make([createNewWalletButton, restoreWalletButton]) }
}
extension OpenWalletView: SingleContentView {}
public extension OpenWalletView {
    typealias ViewModel = OpenWalletViewModel
    func populate(with viewModel: ViewModel.Output) -> [Disposable] {
        return [
            viewModel.createNew.drive(),
            viewModel.restore.drive()
        ]
    }
}

public extension UIFont {
    static var `default`: UIFont {
        return .systemFont(ofSize: 16)
    }
}
public extension UIColor {
    enum `default` {
        static var text: UIColor {
            return .black
        }
    }
}

public enum Style {
    public struct Title {
        let text: String
        let color: UIColor
        let font: UIFont
        init(_ text: String, color: UIColor = UIColor.default.text, font: UIFont = .default) {
            self.text = text
            self.color = color
            self.font = font
        }

        static func button(_ text: String) -> Title {
            return Title(text)
        }
    }

    public struct StackView {
        let axis: NSLayoutConstraint.Axis
        let alignment: UIStackView.Alignment
        let distribution: UIStackView.Distribution
        let views: [UIView]
        init(_ views: [UIView], axis: NSLayoutConstraint.Axis = .vertical, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) {
            self.views = views
            self.axis = axis
            self.alignment = alignment
            self.distribution = distribution
        }
    }
}

public extension UIButton {

    convenience init(style: Style.Title) {
        self.init(type: .custom)
        setTitle(style.text, for: UIControlState())
        setTitleColor(style.color, for: UIControlState())
        titleLabel?.font = style.font
    }

    static func make(_ title: String) -> UIButton {
        return UIButton(style: .button(title))
    }
}

public extension UIStackView {
    convenience init(style: Style.StackView) {
        self.init(arrangedSubviews: style.views)
        self.axis = style.axis
        self.alignment = style.alignment
        self.distribution = style.distribution
    }

    static func make(_ views: [UIView], axis: NSLayoutConstraint.Axis = .vertical) -> UIStackView {
        return UIStackView(style: Style.StackView(views, axis: axis))
    }
}

//public extension UIView {
//
//    func edges(to view: UIView) {
//        top(to: view)
//        bottom(to: view)
//        leading(to: view)
//        trailing(to: view)
//    }
//
//    func edgesToSuperview() {
//        guard let superview = superview else { return }
//        edges(to: superview)
//    }
//
//    func top(to view: UIView) {
//        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//    }
//
//    func topToSuperview() {
//        guard let superview = superview else { return }
//        top(to: superview)
//    }
//
//    func bottom(to view: UIView) {
//        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//    }
//
//    func bottomToSuperview() {
//        guard let superview = superview else { return }
//        bottom(to: superview)
//    }
//
//    func leading(to view: UIView) {
//        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//    }
//
//    func leadingToSuperview() {
//        guard let superview = superview else { return }
//        leading(to: superview)
//    }
//
//    func trailing(to view: UIView) {
//        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//    }
//
//    func trailingToSuperview() {
//        guard let superview = superview else { return }
//        trailing(to: superview)
//    }
//}
