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

import UIKit

public protocol Styling {
    associatedtype Style: ViewStyling
    func apply(style: Style)
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self {

    init(style: Style) {
        self = Self.createEmpty()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = style.backgroundColor ?? .white
        if let height = style.height {
            self.height(height)
        }
        apply(style: style)
    }
}

extension Styling where Self: UIView, Self: StaticEmptyInitializable, Self.Empty == Self, Style: ExpressibleByStringLiteral, Self.Style.StringLiteralType == String  {

    public init(stringLiteral value: String) {
        let style = Style.init(stringLiteral: value)
        self = Self.init(style: style)
    }
}
