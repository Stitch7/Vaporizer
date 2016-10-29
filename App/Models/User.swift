//
//  User.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import Auth
import HTTP

final class User: Model {

    // MARK: - Properties

    var id: Node?
    var exists = false
    var username: Valid<Username>
    var password: Valid<Password>
    var salt: String
    var firstname: Valid<Firstname>
    var lastname: Valid<Lastname>

    // MARK: - Initializers

    init(node: Node, in context: Context) throws {
        guard
            let username = node["username"],
            let password = node["password"],
            let salt = node["salt"]?.string,
            let firstname = node["firstname"],
            let lastname = node["lastname"]
        else {
            throw TypeSafeRoutingError.missingParameter
        }

        self.id = try node.extract("id")
        self.username = try username.validated()
        self.password = try password.validated()
        self.salt = salt
        self.firstname = try firstname.validated()
        self.lastname = try lastname.validated()
    }
}

// MARK: - NodeRepresentable

extension User {
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username.value,
            "password": password.value,
            "salt": salt,
            "firstname": firstname.value,
            "lastname": lastname.value
        ])
    }
}

// MARK: - JSONRepresentable

extension User {
    func makeJSON() throws -> JSON {
        return JSON([
            "id": id!,
            "username": Node(username.value),
            "firstname": Node(firstname.value),
            "lastname": Node(lastname.value)
        ])
    }
}

// MARK: - Auth

extension User: Auth.User {
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        let invalidCredentials = Abort.custom(status: .badRequest, message: "Invalid credentials")

        guard let apiKey = credentials as? APIKey else {
            throw invalidCredentials
        }

        guard let user = try User.query().filter("username", apiKey.id).first() else {
            throw invalidCredentials
        }

        let password = try Password(hash: user.password.value, salt: user.salt)
        guard password.verifyPassword(withPassword: apiKey.secret) else {
            throw invalidCredentials
        }

        return user
    }

    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.custom(status: .badRequest, message: "Register not supported")
    }
}

extension Request {
    func user() throws -> User {
        guard let user = try auth.user() as? User else {
            throw Abort.custom(status: .badRequest, message: "Invalid user type")
        }

        return user
    }
}
