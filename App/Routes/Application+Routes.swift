//
//  Application+Routes.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor

extension Application {
    public func routes(_ drop: Droplet) {
        let indexController = IndexController(droplet: drop)
        let userController = UserController(droplet: drop)

        drop.get("/", handler: indexController.index)
        drop.get("health", handler: indexController.health)
        drop.resource("users", userController)
    }
}
