//
//  SignInSocialApp.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import SwiftUI
import SwiftData

@main
struct SignInSocialApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
            }
            .onOpenURL { url in
                appDelegate.oauthApplication.handle(url: url)
            }
        }
    }
}
