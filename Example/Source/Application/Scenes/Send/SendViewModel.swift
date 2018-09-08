//
//  SendViewModel.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SendViewModel {
    private let bag = DisposeBag()
    private let navigator: SendNavigator
    init(navigator: SendNavigator) {
        self.navigator = navigator
    }
}

extension SendViewModel: ViewModelled {
    struct Input {
        let sendTrigger: Driver<Void>
    }
    struct Output {
    }
    func transform(input: Input) -> Output {
        return Output()
    }
}
