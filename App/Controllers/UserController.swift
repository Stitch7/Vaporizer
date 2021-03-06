//
//  UserController.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP

final class UserController {

    // MARK: - Properties

    let drop: Droplet

    // MARK: - Initializers

    init(droplet: Droplet) {
        drop = droplet
        User.database = drop.database
    }

    // MARK: - Actions
    
    func index(request: Request) throws -> ResponseRepresentable {
        return JSON(try User.all().map { try $0.makeJSON() })
    }

    func store(request: Request) throws -> ResponseRepresentable {
        guard
            let requestJson = request.json,
            let passwordStr = requestJson["password"]?.string
        else {
            throw Abort.badRequest
        }

        let password = try Password(password: passwordStr)
        var json = requestJson
        json["password"] = JSON(Node(password.hashString))
        json["salt"] = JSON(Node(password.saltString))

        var user = try User(node: json)
        try user.save()

        return try user.makeJSON()
    }

    func show(request: Request, item user: User) throws -> ResponseRepresentable {
        return user
    }

    func replace(request: Request, item user: User) throws -> ResponseRepresentable {
        guard let json = request.json else {
            throw Abort.badRequest
        }

        var replaced = try User(node: json)
        replaced.id = user.id
        try replaced.save()

        return replaced
    }

    func modify(request: Request, item user: User) throws -> ResponseRepresentable {
        var modifiedUser = user
        try extractField(name: "username", from: request, to: &modifiedUser.username)
        try extractField(name: "password", from: request, to: &modifiedUser.password)
        try extractField(name: "firstname", from: request, to: &modifiedUser.firstname)
        try extractField(name: "lastname", from: request, to: &modifiedUser.lastname)
        try modifiedUser.save()

        return modifiedUser
    }

    private func extractField<T: ValidationSuite>
        (name fieldName: String, from request: Request, to value: inout Valid<T>) throws
        where T.InputType: PolymorphicInitializable
    {
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

        return JSON([:])
    }
}

// MARK: - ResourceRepresentable

extension UserController: ResourceRepresentable {
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            show: show,
            replace: replace,
            modify: modify,
            destroy: destroy
        )
    }
}
