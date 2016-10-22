//
//  Application+Routes.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import Auth
import Routing
import HTTP

extension Application {
    public func publicRoutes(_ drop: Droplet) {
        let indexController = IndexController(droplet: drop)
        let userController = UserController(droplet: drop)

        drop.get("/", handler: indexController.index)
        drop.get("health", handler: indexController.health)
        drop.post("/register", handler: userController.store)
    }

    public func protectedRoutes(_ drop: Droplet, protectedGroup: RouteGroup<Responder, Droplet>) {
        protectedGroup.resource("users", UserController(droplet: drop))
    }
}
