//
//  SocialAuthentication.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import UIKit

public protocol SocialAuthentication {
    associatedtype T
    
    func getToken() async throws -> T?
}
