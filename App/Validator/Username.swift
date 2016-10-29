//
//  Username.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import Fluent

final class Username: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(3)
            && Count.max(20)

        try evaluation.validate(input: value)
    }
}
