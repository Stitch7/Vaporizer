//
//  UserController.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP

final class UserController: ResourceRepresentable {

    typealias Item = User

    let drop: Droplet

    // MARK: - Initializers

    init(droplet: Droplet) {
        drop = droplet
        User.database = drop.database
    }

    // MARK: - Actions
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeNode().converted(to: JSON.self)
    }

    func store(request: Request) throws -> ResponseRepresentable {
        guard
            let requestBody = request.body.bytes,
            let json = try? JSON(bytes: requestBody)
        else {
            throw Abort.badRequest
        }

        var user = try User(node: json.makeNode())
        try user.save()

        return try user.makeJSON()
    }

    func show(request: Request, item user: User) throws -> ResponseRepresentable {
        return try user.makeJSON()
    }

    func replace(request: Request, item user: User) throws -> ResponseRepresentable {
        guard
            let requestBody = request.body.bytes,
            let json = try? JSON(bytes: requestBody)
        else {
            throw Abort.badRequest
        }

        var replacedUser = try User(node: json.makeNode())
        replacedUser.id = user.id
        try replacedUser.save()

        return try replacedUser.makeJSON()
    }

    func modify(request: Request, item user: User) throws -> ResponseRepresentable {
        var modifiedUser = user
        try extractField(name: "username", from: request, to: &modifiedUser.username)
        try extractField(name: "password", from: request, to: &modifiedUser.password)
        try extractField(name: "firstname", from: request, to: &modifiedUser.firstname)
        try extractField(name: "lastname", from: request, to: &modifiedUser.lastname)
        try modifiedUser.save()

        return try modifiedUser.makeJSON()
    }

    private func extractField<T: ValidationSuite>(name fieldName: String, from request: Request, to value: inout Valid<T>) throws where T.InputType: PolymorphicInitializable {
        guard let newValue = request.data[fieldName] else { return }

        if let validValue = try? newValue.validated(by: T.self) {
            value = validValue
        }
        else {
            throw Abort.custom(status: .badRequest, message: "Invalid \(fieldName)")
        }
    }

    func destroy(request: Request, item user: User) throws -> ResponseRepresentable {
        try user.delete()

        return user
    }

    // MARK: - ResourceRepresentable

    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: replace,
            modify: modify,
            destroy: destroy
        )
    }
}
