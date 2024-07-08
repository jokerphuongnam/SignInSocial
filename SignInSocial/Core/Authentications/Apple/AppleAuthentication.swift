//
//  AppleAuthentication.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import AuthenticationServices

public protocol AppleAuthentication: SocialAuthentication where Self.T == String {
    func getToken() async throws -> String?
}

public class AppleAuthenticationImpl: NSObject, AppleAuthentication {
    private var continuation: CheckedContinuation<String?, Error>?
    
    public func getToken() async throws -> String? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume(throwing: SSError.wSelf) }
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
            self.continuation = continuation
        }
    }
}

extension AppleAuthenticationImpl: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if let identityToken = appleIDCredential.identityToken {
                let token = String(data: identityToken, encoding: .utf8)
                continuation?.resume(returning: token)
            }
        default:
            break
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let error = error as NSError
        if error.code == 1001 {
            continuation?.resume(returning: nil)
            return
        }
        continuation?.resume(throwing: error)
    }
}

extension AppleAuthenticationImpl: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        AppDelegate.rootWindow
    }
}
