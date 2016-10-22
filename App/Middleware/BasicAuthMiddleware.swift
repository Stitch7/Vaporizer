//
//  BasicAuthMiddleware.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP

class BasicAuthMiddleware: Middleware {
	func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        guard let apiKey = request.auth.header?.basic else {
            throw Abort.custom(status: .unauthorized, message: "Basic authorization required")
        }

        try request.auth.login(apiKey, persist: false)

        return try chain.respond(to: request)
    }
}
