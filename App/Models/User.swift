//
//  User.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor

final class User: Model {

    // MARK: - Properties

    var id: Node?
    var exists = false

    var username: Valid<Username>
    var password: Valid<Password>
    var firstname: Valid<Firstname>
    var lastname: Valid<Lastname>

    // MARK: - Initializers

    init(username: Valid<Username>,
         password: Valid<Password>,
         firstname: Valid<Firstname>,
         lastname: Valid<Lastname>
    ) {
        self.username = username
        self.password = password
        self.firstname = firstname
        self.lastname = lastname
    }

    init(node: Node, in context: Context) throws {
        guard
            let username = node["username"],
            let password = node["password"],
            let firstname = node["firstname"],
            let lastname = node["lastname"]
        else {
            throw TypeSafeRoutingError.missingParameter
        }

        self.id = try node.extract("id")

        self.username = try username.validated()
        self.password = try password.validated()
        self.firstname = try firstname.validated()
        self.lastname = try lastname.validated()
    }

    // MARK: - NodeRepresentable

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username.value,
            "password": password.value,
            "firstname": firstname.value,
            "lastname": lastname.value
        ])
    }
}
