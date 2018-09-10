//
//  ViewModelConvertible.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

protocol ViewModelConvertible {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

protocol ViewModelType: ViewModelConvertible where Input: InputType {}

protocol InputType {
    associatedtype FromView
    associatedtype FromController
    var fromView: FromView { get }
    var fromController: FromController { get }
    init(fromView: FromView, fromController: FromController)
}

struct NotUsed: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {}
}

extension InputType {
    var fromController: NotUsed {
        return nil
    }
}

extension InputType where FromController == NotUsed {
    init(fromView: FromView) {
        self.init(fromView: fromView, fromController: nil)
    }
}
