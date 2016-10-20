//
//  Application+Providers.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import VaporMySQL

extension Application {
    public var providers: [Vapor.Provider.Type] {
        return [
            VaporMySQL.Provider.self
        ]
    }
}
