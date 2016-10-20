//
//  IndexController.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import VaporMySQL
import HTTP

final class IndexController {

    // MARK: - Properties

    let drop: Droplet

    // MARK: - Initializers

    init(droplet: Droplet) {
        drop = droplet
    }

    // MARK: - Actions

    var index: ((Request) throws -> ResponseRepresentable) {
        return { request in
            return "welcome"
        }
    }

    var health: ((Request) throws -> ResponseRepresentable) {
        return { request in
            guard
                let mysql = self.drop.database?.driver as? MySQLDriver,
                let result = try? mysql.raw("SELECT @@version"),
                let mysqlVersion = result.array?.first?.object?["@@version"]?.string
            else {
                throw Abort.serverError
            }

            return JSON([
                "vapor-version": Node(VERSION),
                "mysql-version": Node(mysqlVersion)
            ])
        }
    }
}
