//
//  Application+Middleware.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import HTTP

extension Application {
    public var middleware: [Middleware] {
        return [
            SampleMiddleware(),
        ]
    }
}
