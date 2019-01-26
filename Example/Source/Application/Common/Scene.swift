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

/// Use typealias when you don't require a subclass. If your use case requires subclass, inherit from `SceneController`.
typealias Scene<View: UIView & ViewModelled> = SceneController<View>

/// The "Single-Line Controller" base class
class SceneController<View>: UIViewController where View: UIView & ViewModelled {
    typealias ViewModel = View.ViewModel

    private let bag = DisposeBag()

    private let viewModel: ViewModel

    override func loadView() {
        view = View()
        view.backgroundColor = .white
        view.bounds = UIScreen.main.bounds
    }

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewToViewModel()
        edgesForExtendedLayout = .bottom
    }

    required init?(coder: NSCoder) { interfaceBuilderSucks }
}

private extension Scene {
    func bindViewToViewModel() {
        guard let contentView = view as? View else { return }
        let output = viewModel.transform(input: contentView.inputFromView)
        contentView.populate(with: output).forEach { $0.disposed(by: bag) }
    }
}
