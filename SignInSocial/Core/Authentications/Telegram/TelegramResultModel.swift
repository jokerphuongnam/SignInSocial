//
//  TelegramResultModel.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation

public struct TelegramResultModel: Codable, Hashable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let username: String
    public let photoURL: String
    public let authDate: Int
    public let hash: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case photoURL = "photo_url"
        case authDate = "auth_date"
        case hash
    }
}
