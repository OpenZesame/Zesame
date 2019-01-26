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
        let encryptionPassword: Driver<String?>
        let confirmEncryptionPassword: Driver<String?>
        let restoreTrigger: Driver<Void>
    }

    struct Output {
        let isRestoreButtonEnabled: Driver<Bool>
    }

    func transform(input: Input) -> Output {

        let validEncryptionPassword: Driver<String?> = Driver.combineLatest(input.encryptionPassword, input.confirmEncryptionPassword) {
            guard
                $0 == $1,
                let newPassword = $0,
                newPassword.count >= 3
                else { return nil }
            return newPassword
        }

        let validPrivateKey: Driver<String?> = input.privateKey.map {
            guard
                let key = $0,
                key.count == 64
                else { return nil }
            return key
        }

        let isRestoreButtonEnabled = Driver.combineLatest(validEncryptionPassword, validPrivateKey) { ($0, $1) }.map { $0 != nil && $1 != nil }

        let wallet = Driver.combineLatest(validPrivateKey.filterNil(), validEncryptionPassword.filterNil()) {
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
