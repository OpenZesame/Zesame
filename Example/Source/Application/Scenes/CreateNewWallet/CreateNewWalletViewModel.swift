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

import Foundation
import RxSwift
import RxCocoa
import FormValidatorSwift
import Zesame

final class CreateNewWalletViewModel {

    private let bag = DisposeBag()

    private weak var navigator: CreateNewWalletNavigator?

    private let service: ZilliqaServiceReactive

    init(navigator: CreateNewWalletNavigator, service: ZilliqaServiceReactive) {
        self.navigator = navigator
        self.service = service
    }
}

extension CreateNewWalletViewModel: ViewModelType {

    struct Input {
        let encryptionPassword: Driver<String?>
        let confirmedEncryptionPassword: Driver<String?>
        let createWalletTrigger: Driver<Void>
    }

    struct Output {
        let isCreateWalletButtonEnabled: Driver<Bool>
    }

    func transform(input: Input) -> Output {

        let validEncryptionPassword: Driver<String?> = Driver.combineLatest(input.encryptionPassword, input.confirmedEncryptionPassword) {
            guard
                $0 == $1,
                let newPassword = $0,
                newPassword.count >= 3
                else { return nil }
            return newPassword
        }

        let isCreateWalletButtonEnabled = validEncryptionPassword.map { $0 != nil }
        
        
        input.createWalletTrigger.withLatestFrom(validEncryptionPassword.filterNil()) { $1 } //.flatMapLatest { (password: String?) -> Driver<Wallet?> in
            .flatMapLatest {
                self.service.createNewWallet(encryptionPassword: $0)
                    .asDriverOnErrorReturnEmpty()
            }
            .do(onNext: { self.navigator?.toMain(wallet: $0) })
            .drive()
            .disposed(by: bag)
        
        
        return Output(
            isCreateWalletButtonEnabled: isCreateWalletButtonEnabled
        )
    }

}
