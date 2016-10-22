//
//  Application.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Vapor
import Auth

public final class Application {

    // MARK: - Properties

    public var drop: Droplet?

    // MARK: - Initializers

    public init(testing: Bool = false) {
        var args = CommandLine.arguments
        if testing {
            // Simulate passing `--env=testing` from the command line if testing is true
            args.append("--env=testing")
        }
        let drop = Droplet(arguments: args)

        configurePreparations(drop)
        configureProviders(drop)
        configureMiddlewares(drop)
        configureRoutes(drop)

        self.drop = drop
    }

    private func configurePreparations(_ drop: Droplet) {
        // Add preparations from the Preparations folder
        drop.preparations = preparations
    }

    private func configureProviders(_ drop: Droplet) {
        // Add providers from the Providers folder
        do {
            for provider in providers {
                try drop.addProvider(provider)
            }
        } catch {
            fatalError("Can not add provider. \(error)")
        }
    }

    private func configureMiddlewares(_ drop: Droplet) {
        // Add middlewares from the Middleware folder
        drop.middleware += middleware
    }

    private func configureRoutes(_ drop: Droplet) {
        // Add routes from the Routes folder
        publicRoutes(drop)

        // Protected routes requiring basic authorization
        let protect = BasicAuthMiddleware()
        let protectedGroup = drop.grouped(protect)
        protectedRoutes(drop, protectedGroup: protectedGroup)
    }

    // MARK: - Public

    public func start() {
        drop?.run()
    }
}
