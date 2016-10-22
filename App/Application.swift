//
//  Application.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Foundation
import Vapor
import SwiftyBeaver
import SwiftyBeaverVapor

public final class Application {

    // MARK: - Properties

    public var drop: Droplet

    // MARK: - Initializers

    public init(testing: Bool = false) {
        var args = CommandLine.arguments
        if testing {
            // Simulate passing `--env=testing` from the command line if testing is true
            args.append("--env=testing")
        }
        drop = Droplet(arguments: args)

        configureProviders()
        configureLogging()
        configurePreparations()
        configureMiddlewares()
        configureRoutes()
    }

    private func configurePreparations() {
        // Add preparations from the Preparations folder
        drop.preparations = preparations
    }

    private func configureLogging() {
        var destinations =  [BaseDestination]()
        destinations.append(ConsoleDestination())

        if let logfile = drop.config["app", "logfile"]?.string {
            let file = FileDestination()
            file.logFileURL = URL(string: "file://" + logfile)!
            destinations.append(file)
        }

        let provider = SwiftyBeaverProvider(destinations: destinations)
        drop.addProvider(provider)
    }

    private func configureProviders() {
        // Add providers from the Providers folder
        do {
            for provider in providers {
                try drop.addProvider(provider)
            }
        } catch {
            fatalError("Can not add provider. \(error)")
        }
    }

    private func configureMiddlewares() {
        // Add middlewares from the Middleware folder
        drop.middleware += middleware
    }

    private func configureRoutes() {
        // Add routes from the Routes folder
        publicRoutes(drop)

        // Protected routes requiring basic authorization
        let protect = BasicAuthMiddleware()
        let protectedGroup = drop.grouped(protect)
        protectedRoutes(drop, protectedGroup: protectedGroup)
    }

    // MARK: - Public

    public func start() {
        drop.run()
    }
}
