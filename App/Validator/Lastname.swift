//
//  Lastname.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//
//

import Vapor
import Fluent

final class Lastname: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(5)
            && Count.max(20)

        try evaluation.validate(input: value)
    }
}
