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

import RxCocoa
import RxSwift
import Zesame

final class RestoreWalletViewModel {
    private let bag = DisposeBag()

    private weak var navigator: RestoreWalletNavigator?
    private let service: ZilliqaServiceReactive

    init(navigator: RestoreWalletNavigator, service: ZilliqaServiceReactive) {
        self.navigator = navigator
        self.service = service
    }
}

extension RestoreWalletViewModel: ViewModelType {

    struct Input {
        let privateKey: Driver<String?>
        let encryptionPassphrase: Driver<String?>
        let confirmEncryptionPassphrase: Driver<String?>
        let restoreTrigger: Driver<Void>
    }

    struct Output {
        let isRestoreButtonEnabled: Driver<Bool>
    }

    func transform(input: Input) -> Output {

        let validEncryptionPassphrase: Driver<String?> = Driver.combineLatest(input.encryptionPassphrase, input.confirmEncryptionPassphrase) {
            guard
                $0 == $1,
                let newPassphrase = $0,
                newPassphrase.count >= 3
                else { return nil }
            return newPassphrase
        }

        let validPrivateKey: Driver<String?> = input.privateKey.map {
            guard
                let key = $0,
                key.count == 64
                else { return nil }
            return key
        }

        let isRestoreButtonEnabled = Driver.combineLatest(validEncryptionPassphrase, validPrivateKey) { ($0, $1) }.map { $0 != nil && $1 != nil }

        let wallet = Driver.combineLatest(validPrivateKey.filterNil(), validEncryptionPassphrase.filterNil()) {
            try? KeyRestoration(privateKeyHexString: $0, encryptBy: $1)
        }.filterNil()
        .flatMapLatest {
            self.service.restoreWallet(from: $0)
                .asDriverOnErrorReturnEmpty()
        }

        input.restoreTrigger
            .withLatestFrom(wallet).do(onNext: {
                self.navigator?.toMain(restoredWallet: $0)
            }).drive().disposed(by: bag)

        return Output(
            isRestoreButtonEnabled: isRestoreButtonEnabled
        )
    }
}
