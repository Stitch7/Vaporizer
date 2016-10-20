//
//  App.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor

public final class Application {

    public var drop: Droplet?

    public init(testing: Bool = false) {
        var args = CommandLine.arguments
        if testing {
            // Simulate passing `--env=testing` from the command line if testing is true
            args.append("--env=testing")
        }
        let drop = Droplet(arguments: args)

        // Add preparations from the Preparations folder
        drop.preparations = preparations

        // Add providers from the Providers folder
        do {
            for provider in providers {
                try drop.addProvider(provider)
            }
        } catch {
            fatalError("Can not add provider. \(error)")
        }

        // Add routes from the Routes folder
        routes(drop)

        // Add middlewares from the Middleware folder
        drop.middleware += middleware

        self.drop = drop
    }

    public func start() {
        drop?.run()
    }
}
