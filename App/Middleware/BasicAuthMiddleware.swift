//
//  BasicAuthMiddleware.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP

final class BasicAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        guard let apiKey = request.auth.header?.basic else {
            let response = Response(status: .unauthorized)
            response.headers["WWW-Authenticate"] = "Basic"
            return response
        }

        try request.auth.login(apiKey, persist: false)

        return try chain.respond(to: request)
    }
}
