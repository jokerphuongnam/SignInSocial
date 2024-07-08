//
//  Data+Extension.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation

public extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}
