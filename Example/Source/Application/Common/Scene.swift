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
import TinyConstraints

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
