//
//  TelegramAuthentication.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

public protocol TelegramAuthentication: SocialAuthentication where T == TelegramResultModel {
    func getToken() async throws -> TelegramResultModel?
}

public final class TelegramAuthenticationImpl: TelegramAuthentication {
    @MainActor public func getToken() async throws -> TelegramResultModel? {
        try await withCheckedThrowingContinuation { continuation in
            var isFinished = false
            let viewController = TelegramWebViewViewController { result in
                if !isFinished {
                    isFinished = true
                    continuation.resume(with: result)
                }
            }
            AppDelegate.rootViewController.present(viewController, animated: true)
        }
    }
}
