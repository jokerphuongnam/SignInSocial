//
//  AppDelegate.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import UIKit
import FacebookLogin
import GoogleSignIn

final class AppDelegate: NSObject, UIApplicationDelegate {
    static var shared: AppDelegate!
    private let ggSignIn: GIDSignIn = GIDSignIn.sharedInstance
    let oauthApplication: OauthApplication = OauthAppDelegate()
    static var rootViewController: UIViewController! {
        rootWindow?.rootViewController
    }
    
    static var rootWindow: UIWindow! {
        (UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .flatMap { $0?.windows.first } ?? UIApplication.shared.windows.first!)
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.shared = self
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//            if let error {
//                
//            } else if let user {
//                
//            }
        }
        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let openUrls = [
            ApplicationDelegate.shared.application(app, open: url, options: options),
            ggSignIn.handle(url),
            oauthApplication.handle(url: url)
        ]
        var result = false
        
        for openUrl in openUrls {
            if openUrl {
                result = openUrl
            }
        }
        return result
    }
}
