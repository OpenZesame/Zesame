//
//  SingleContentView.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import RxSwift

protocol SingleContentView: EmptyInitializable, AnyObject {
    associatedtype ViewModel: ViewModelled
    func populate(with viewModel: ViewModel.Output) -> [Disposable]
}
