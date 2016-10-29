//
//  Form+Preparations.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.10.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Fluent

extension Form {
    public static func prepare(_ database: Database) throws {
        try database.create(entity) { forms in
            forms.id()
            forms.int("user_id")
            forms.string("question1")
            forms.string("question2")
            forms.string("question3")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
