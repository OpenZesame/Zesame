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
