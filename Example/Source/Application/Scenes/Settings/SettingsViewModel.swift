//
//  SettingsViewModel.swift
//  ZesameiOSExample
//
//  Created by Alexander Cyon on 2018-09-09.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Zesame

final class SettingsViewModel {
    private let bag = DisposeBag()
    
    private weak var navigation: SettingsNavigator?
    private let service: ZilliqaServiceReactive
    private let wallet: Driver<Wallet>

    init(navigation: SettingsNavigator, wallet: Observable<Wallet>, service: ZilliqaServiceReactive) {
        self.navigation = navigation
        self.service = service
        self.wallet = wallet.asDriverOnErrorReturnEmpty()
    }
}

extension SettingsViewModel: ViewModelType {

    struct Input {
        let passphrase: Driver<String>
        let revealPrivateKeyTrigger: Driver<Void>
        let removeWalletTrigger: Driver<Void>
    }

    struct Output {
        let appVersion: Driver<String>
        let privateKey: Driver<String>
    }

    func transform(input: Input) -> Output {

        input.removeWalletTrigger
            .do(onNext: {
                self.navigation?.toChooseWallet()
            }).drive().disposed(by: bag)

        let appVersionString: String? = {
            guard
                let info = Bundle.main.infoDictionary,
                let version = info["CFBundleShortVersionString"] as? String,
                let build = info["CFBundleVersion"] as? String
                else { return nil }
            return "\(version) (\(build))"
        }()
        let appVersion = Driver<String?>.just(appVersionString).filterNil()

        let privateKey = input.revealPrivateKeyTrigger.withLatestFrom(input.passphrase).withLatestFrom(wallet) { (passphrase: $0, wallet: $1) }.flatMapLatest { [unowned self] in
            self.service.extractKeyPairFrom(wallet: $0.wallet, encryptedBy: $0.passphrase).asDriverOnErrorReturnEmpty()
            }.map { $0.privateKey.asHexStringLength64() }

        return Output(
            appVersion: appVersion,
            privateKey: privateKey
        )
    }
}
