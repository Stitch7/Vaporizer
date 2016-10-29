//
//  Password.swift
//  Vaporizer
//
//  Created by Christopher Reitz on 29.08.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import Foundation
import Cryptor
import Vapor
import Fluent

final class Password {

    // MARK: - Properties

    private let saltLength: UInt = 32
    private let rounds: UInt32 = 2
    private let salt: [UInt8]
    private let hash: [UInt8]

    public var saltString: String {
        return CryptoUtils.hexString(from: salt)
    }

    public var hashString: String {
        return CryptoUtils.hexString(from: hash)
    }

    // MARK: - Initializers

    public init(password: String) throws {
        self.salt = try Random.generate(byteCount: Int(saltLength))
        self.hash = PBKDF.deriveKey(fromPassword: password,
                                    salt: salt,
                                    prf: .sha512,
                                    rounds: rounds,
                                    derivedKeyLength: saltLength)
    }


    public init(hash: String, salt: String) throws {
        self.hash = CryptoUtils.byteArray(fromHex: hash)
        self.salt = CryptoUtils.byteArray(fromHex: salt)
    }

    // MARK: - Public

    public func verifyPassword(withPassword testPassword: String) -> Bool {
        let hashedTestPassword: [UInt8]
        hashedTestPassword = PBKDF.deriveKey(fromPassword: testPassword,
                                             salt: salt,
                                             prf: .sha512,
                                             rounds: rounds,
                                             derivedKeyLength: saltLength)

        return hash == hashedTestPassword
    }
}

extension Password: ValidationSuite {
    public static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(5)

        try evaluation.validate(input: value)
    }

    public func validated<T: ValidationSuite>() throws -> Valid<T> where T.InputType: PolymorphicInitializable {
        return try Node(hashString).validated(by: T.self)
    }
}
