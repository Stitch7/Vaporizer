//
//  User+Preparations.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Fluent

extension User {
    public static func prepare(_ database: Database) throws {
        try database.create(entity) { users in
            users.id()
            users.string("username")
            users.string("password")
            users.string("firstname")
            users.string("lastname")
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}
