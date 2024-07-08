//
//  FacebookAuthentication.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import FacebookLogin

public protocol FacebookAuthentication: SocialAuthentication where Self.T == String {
    func getToken() async throws -> String?
}

public final actor FacebookAuthenticationImpl: FacebookAuthentication {
    private let facebookLoginManager = LoginManager()
    
    @MainActor public func getToken() async throws -> String? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume(throwing: SSError.wSelf) }
            self.facebookLoginManager.logIn(
                permissions: [
                    "public_profile",
                    "email"
                ],
                from: nil
            ) { [weak self] result, error in
                guard self != nil else { return }
                if let result {
                    if result.isCancelled {
                        continuation.resume(returning: nil)
                    } else if let token = result.token {
                        continuation.resume(returning: token.tokenString)
                    }
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
