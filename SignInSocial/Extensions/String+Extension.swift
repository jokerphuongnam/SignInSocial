//
//  String+Extension.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation

public extension String {
    init<T: Encodable>(_ codable: T) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(codable)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Encoding to JSON string failed"])
        }
        self = jsonString
    }
    
    func hexEncodedString() -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        let hexString = data.map { String(format: "%02x", $0) }.joined()
        return hexString
    }
}
