//
//  ViewModelConvertible.swift
//  ZilliqaSDKiOSExample
//
//  Created by Alexander Cyon on 2018-09-08.
//  Copyright © 2018 Open Zesame. All rights reserved.
//

import Foundation

protocol ViewModelInput {
    associatedtype ViewInput
    associatedtype ControllerInput
    var viewInput: ViewInput { get }
    var controllerInput: ControllerInput { get }
    init(viewInput: ViewInput, controllerInput: ControllerInput)
}

struct NotUsed: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {}
}

extension ViewModelInput {
    var controllerInput: NotUsed {
        return nil
    }
}

extension ViewModelInput where ControllerInput == NotUsed {
    init(viewInput: ViewInput) {
        self.init(viewInput: viewInput, controllerInput: nil)
    }
}


protocol ViewModelConvertible {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

protocol ViewModelType: ViewModelConvertible where Input: ViewModelInput {}
