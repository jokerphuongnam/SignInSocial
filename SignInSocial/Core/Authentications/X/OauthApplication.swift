//
//  OauthApplication.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation

public protocol OauthApplication: AnyObject {
    func getToken() async throws -> String?
    @discardableResult func handle(url: URL) -> Bool
}

public class OauthAppDelegate {
    private var _continuation: CheckedContinuation<String?, Error>?
}

extension OauthAppDelegate: OauthApplication {
    public func getToken() async throws -> String? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume(throwing: SSError.wSelf) }
            self._continuation = continuation
        }
    }
    
    public func handle(url: URL) -> Bool {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
                _continuation?.resume(returning: code)
                return true
            }
        }
        return false
    }
}
