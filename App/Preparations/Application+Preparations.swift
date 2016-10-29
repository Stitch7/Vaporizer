//
//  Application+Preparations.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Fluent

extension Application {
    public var preparations: [Preparation.Type] {
        return [
            Form.self,
            User.self
        ]
    }
}
