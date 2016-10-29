//
//  Form.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.10.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP
import Fluent

final class Form: Model {

    // MARK: - Properties

    var id: Node?
    var exists = false
    var userId: Node
    var question1: String
    var question2: String
    var question3: String

    // MARK: - Initializers

    init(node: Node, in context: Context) throws {
        guard
            let question1 = node["question1"]?.string,
            let question2 = node["question2"]?.string,
            let question3 = node["question3"]?.string
        else {
            throw TypeSafeRoutingError.missingParameter
        }

        self.id = try node.extract("id")
        self.userId = try node.extract("user_id")
        self.question1 = question1
        self.question2 = question2
        self.question3 = question3
    }
}

// MARK: - NodeRepresentable

extension Form {
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "question1": question1,
            "question2": question2,
            "question3": question3
        ])
    }
}

// MARK: - JSONRepresentable

extension Form {
    func makeJSON() throws -> JSON {
        return JSON([
            "id": id!,
            "user": try user().get()?.makeJSON().node ?? nil,
            "question1": Node(question1),
            "question2": Node(question2),
            "question3": Node(question3)
        ])
    }
}

// MARK: - Relations

extension Form {
    func user() throws -> Parent<User> {
        return try parent(userId)
    }
}
