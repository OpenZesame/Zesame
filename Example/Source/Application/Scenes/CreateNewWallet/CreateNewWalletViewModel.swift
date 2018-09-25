//
//  CreateNewWalletViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FormValidatorSwift
import ZilliqaSDK

extension Validator {
    func validate(text: String?) -> Bool {
        if let cond = checkConditions(text) {
            return cond.isEmpty
        } else {
            return true
        }
    }
}

extension String {
    func validates(by valididator: Validator) -> Bool {
        return valididator.validate(text: self)
    }
}

extension Optional where Wrapped == String {
    func validates(by valididator: Validator) -> Bool {
        return valididator.validate(text: self)
    }
}

struct CreateNewWalletViewModel {
    private let bag = DisposeBag()
    private let navigator: CreateNewWalletNavigator
    private let service: ZilliqaServiceReactive

    init(navigator: CreateNewWalletNavigator, service: ZilliqaServiceReactive) {
        self.navigator = navigator
        self.service = service
    }
}

extension CreateNewWalletViewModel: ViewModelType {

    struct Input {
        let emailAddress: Driver<String?>
        let sendBackupTrigger: Driver<Void>
    }

    struct Output {
        let canSendBackup: Driver<Bool>
        let wallet: Driver<Wallet>
    }

    func transform(input: Input) -> Output {
        let emailValidator = EmailValidator()

        let isEmailValid = input.emailAddress.map { $0.validates(by: emailValidator) }.startWith(false)

        let wallet = service.createNewWallet()
        let keystore = wallet.flatMapLatest { newWallet -> Observable<Keystore> in
            return self.service.exportKeystore(from: newWallet, encryptWalletBy: "apa")
        }.asDriverOnErrorReturnEmpty()

        keystore.do(onNext: { print("Successfully created keystore: \($0.toJson())")}).drive().disposed(by: bag)

        return Output(
            canSendBackup: isEmailValid,
            wallet: wallet.asDriverOnErrorReturnEmpty()
        )
    }

}
