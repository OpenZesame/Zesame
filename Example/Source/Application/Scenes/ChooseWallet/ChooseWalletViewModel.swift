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

import RxSwift
import RxCocoa

final class ChooseWalletViewModel {
    private let bag = DisposeBag()

    private weak var navigator: ChooseWalletNavigator?

    init(navigator: ChooseWalletNavigator) {
        self.navigator = navigator
    }
}

extension ChooseWalletViewModel: ViewModelType {

    struct Input {
        let createNewTrigger: Driver<Void>
        let restoreTrigger: Driver<Void>
    }

    struct Output {}

    func transform(input: Input) -> Output {

        input.createNewTrigger.do(onNext: {
            self.navigator?.toCreateNewWallet()
        }).drive().disposed(by: bag)

        input.restoreTrigger.do(onNext: {
            self.navigator?.toRestoreWallet()
        }).drive().disposed(by: bag)

        return Output()
    }
}
