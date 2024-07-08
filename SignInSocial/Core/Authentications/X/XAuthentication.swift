//
//  XAuthentication.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import OAuthSwift
import Foundation
import UIKit
import SafariServices

public protocol XAuthentication: SocialAuthentication where Self.T == String {
    func getToken() async throws -> String?
}

public final class XAuthenticationImpl: NSObject, XAuthentication {
    private let application: OauthApplication
    let scheme = "$(X_SCHEME)"
    var codeVerifier: String = "twitter_challenge"
    private lazy var oauthHandler = SafariURLHandler(viewController: AppDelegate.rootViewController, oauthSwift: oauth2)
    private let oauth2: OAuth2Swift = {
        let oauth = OAuth2Swift(
            consumerKey: "$(X_CLIENT_ID)",
            consumerSecret: "",
            authorizeUrl: "https://twitter.com/i/oauth2/authorize",
            responseType: "code"
        )
        oauth.accessTokenBasicAuthentification = true
        oauth.allowMissingStateCheck = true
        return oauth
    }()
    
    init(application: OauthApplication) {
        self.application = application
        super.init()
        self.oauth2.authorizeURLHandler = self.oauthHandler 
    }
    
    @MainActor public func getToken() async throws -> String? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return continuation.resume(throwing: SSError.wSelf) }
            var outerSafariViewController: SFSafariViewController?
            var isFinished = false
            self.getSafariHandler {
                if !isFinished {
                    continuation.resume(returning: nil)
                }
            } completion: { safariViewController in
                outerSafariViewController = safariViewController
            }
            
            if let callbackUrl = URL(string: self.scheme) {
                Task(priority: .high) { @MainActor [weak self] in
                    guard let self else { return continuation.resume(throwing: SSError.wSelf) }
                    let token = try await application.getToken()
                    outerSafariViewController?.dismiss(animated: true)
                    continuation.resume(returning: token)
                    isFinished = true
                }
                self.oauth2.authorize(
                    withCallbackURL: callbackUrl,
                    scope: [
                        "users.read",
                        "tweet.read",
                        "follows.read",
                        "follows.write"
                    ].joined(separator: " "),
                    state: "state",
                    codeChallenge: generateCodeChallenge(codeVerifier: self.codeVerifier) ?? self.codeVerifier,
                    codeChallengeMethod: "S256",
                    codeVerifier: self.codeVerifier
                ) { [weak self, weak outerSafariViewController] result in
                    guard self != nil else { return continuation.resume(throwing: SSError.wSelf) }
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                        outerSafariViewController?.dismiss(animated: true)
                        isFinished = true
                    }
                }
            }
        }
    }
    
    @MainActor private func getSafariHandler(dismiss: @escaping () -> Void, completion: @escaping (_ safariViewController: SFSafariViewController) -> Void) {
        self.oauthHandler.factory = { url in
            let configuration: SFSafariViewController.Configuration = .init()
            configuration.entersReaderIfAvailable = true
            let safariViewController = SafariViewController(url: url, configuration: configuration)
            safariViewController.modalPresentationStyle = .formSheet
            safariViewController.dismissButtonStyle = .close
            safariViewController.dismiss = dismiss
            completion(safariViewController)
            return safariViewController
        }
        self.oauthHandler.presentCompletion = { [weak self] in
            guard self != nil else { return }
        }
    }
}

private final class SafariViewController: SFSafariViewController {
    var dismiss: (() -> Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismiss?()
    }
}
