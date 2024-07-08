//
//  GoogleAuthentication.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import GoogleSignIn

public protocol GoogleAuthentication: SocialAuthentication where Self.T == String {
    func getToken() async throws -> String?
}

public final class GoogleAuthenticationImpl: GoogleAuthentication {
    private let ggSignIn: GIDSignIn = GIDSignIn.sharedInstance
    private let ggConfig: GIDConfiguration = GIDConfiguration(
        clientID: "$(CLIENT_ID)",
        serverClientID: "$(GID_SERVER_CLIENT_ID)"
    )
    
    @MainActor public func getToken() async throws -> String? {
        do {
            let result: GIDSignInResult? = try await ggSignIn.signIn(withPresenting: AppDelegate.rootViewController)
            if let result, let idToken = result.user.idToken {
                return idToken.tokenString
            }
            return nil
        } catch {
            let error = error as NSError
            if error.code == GIDSignInError.canceled.rawValue {
                return nil
            } else {
                throw error
            }
        }
    }
}
