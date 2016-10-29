//
//  FormController.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.10.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP

final class FormController {

    // MARK: - Properties

    let drop: Droplet

    // MARK: - Initializers

    init(droplet: Droplet) {
        drop = droplet
        Form.database = drop.database
    }

    // MARK: - Actions
    
    func index(request: Request) throws -> ResponseRepresentable {
        return JSON(try Form.all().map { try $0.makeJSON() })
    }

    func store(request: Request) throws -> ResponseRepresentable {
        guard let json = request.json else { throw Abort.badRequest }

        var form = try Form(node: json)
        try form.save()

        return try form.makeJSON()
    }

    func show(request: Request, item form: Form) throws -> ResponseRepresentable {
        return form
    }

    func replace(request: Request, item form: Form) throws -> ResponseRepresentable {
        guard let json = request.json else {
            throw Abort.badRequest
        }

        var replaced = try Form(node: json)
        replaced.id = form.id
        try replaced.save()

        return replaced
    }

    func modify(request: Request, item form: Form) throws -> ResponseRepresentable {
        var modified = form
        modified.question1 = request.data["question1"]?.string ?? modified.question1
        modified.question2 = request.data["question2"]?.string ?? modified.question2
        modified.question3 = request.data["question3"]?.string ?? modified.question3

        try modified.save()

        return modified
    }

    func destroy(request: Request, item form: Form) throws -> ResponseRepresentable {
        try form.delete()

        return JSON([:])
    }
}

// MARK: - ResourceRepresentable

extension FormController: ResourceRepresentable {
    func makeResource() -> Resource<Form> {
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
