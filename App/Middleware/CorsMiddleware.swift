//
//  CorsMiddleware.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 28/10/2016.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import HTTP
import JSON
import Vapor

class CorsMiddleware: Middleware {
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let response = request.isPreflight
            ? "".makeResponse()
            : try chain.respond(to: request)

        response.headers["Access-Control-Allow-Origin"] = request.headers["Origin"] ?? "*"
        response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, Origin, Content-Type, Accept"
        response.headers["Access-Control-Allow-Methods"] = "POST, GET, PUT, OPTIONS, DELETE, PATCH"

        return response
    }
}

extension Request {
    var isPreflight: Bool {
        return method == .options && headers["Access-Control-Request-Method"] != nil
    }
}
