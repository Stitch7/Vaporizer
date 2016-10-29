//
//  ServerNameMiddleware.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 27/10/2016.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import HTTP

final class ServerNameMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        response.headers["Server"] = "Vaporizer"
        return response
    }
}
