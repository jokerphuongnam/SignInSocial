//
//  MainView.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel(
        appleAuthentication: AppleAuthenticationImpl(),
        facebookAuthentication: FacebookAuthenticationImpl(),
        googleAuthentication: GoogleAuthenticationImpl(),
        xAuthentication: XAuthenticationImpl(application: AppDelegate.shared.oauthApplication),
        telegramAuthentication: TelegramAuthenticationImpl(),
        metamaskConnect: MetamasConnectImpl()
    )
    
    var body: some View {
        List {
            actions
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            tokens
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .contentMargins(.horizontal, 16)
        .contentMargins(.vertical, 32)
        .lineSpacing(0)
        .listRowSpacing(0)
        .navigationTitle("Authentication")
    }
    
    @ViewBuilder @MainActor private var actions: some View {
        SSButton(text: "Apple", isLoading: viewModel.appleToken.isLoading) {
            viewModel.signInWithApple()
        }
        SSButton(text: "Facebook", isLoading: viewModel.facebookToken.isLoading) {
            viewModel.signInWithFacebook()
        }
        SSButton(text: "Google", isLoading: viewModel.googleToken.isLoading) {
            viewModel.signInWithGoogle()
        }
        SSButton(text: "X", isLoading: viewModel.xToken.isLoading) {
            viewModel.signInWithX()
        }
        SSButton(text: "Telegram", isLoading: viewModel.telegramToken.isLoading) {
            viewModel.signInWithTelegram()
        }
        SSButton(text: "Metamask", isLoading: viewModel.metamaskWallet.isLoading || viewModel.metamaskSignature.isLoading) {
            viewModel.connectMetamaskWalletAddress()
        }
    }
    
    @ViewBuilder @MainActor private var tokens: some View {
        resultView(header: "Apple:") {
            appleToken
        }
        
        resultView(header: "Facebook:") {
            facebookToken
        }
        
        resultView(header: "Google:") {
            googleToken
        }
        
        resultView(header: "X:") {
            xToken
        }
        
        resultView(header: "Telegram:") {
            telegramToken
        }
        
        resultView(header: "Metamask") {
            VStack {
                metamaskInfo
                
                metamaskSignature
            }
        }
    }
    
    @ViewBuilder @MainActor private func resultView<Content>(header: String, content: @escaping () -> Content) -> some View where Content: View {
        Section(
            content: content,
            header: {
                Text(header)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
    
    @ViewBuilder @MainActor private var appleToken: some View {
        switch viewModel.appleToken {
        case .loading:
            EmptyView()
        case .success(let token):
            if let token {
                Text(token)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder @MainActor private var facebookToken: some View {
        switch viewModel.appleToken {
        case .loading:
            EmptyView()
        case .success(let token):
            if let token {
                Text(token)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder @MainActor private var googleToken: some View {
        switch viewModel.googleToken {
        case .loading:
            EmptyView()
        case .success(let token):
            if let token {
                Text(token)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder @MainActor private var xToken: some View {
        switch viewModel.xToken {
        case .loading:
            EmptyView()
        case .success(let token):
            if let token {
                Text(token)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder @MainActor private var telegramToken: some View {
        switch viewModel.telegramToken {
        case .loading:
            EmptyView()
        case .success(let token):
            if let token {
                Text((try? String(token)) ?? "")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder @MainActor private var metamaskInfo: some View {
        switch viewModel.metamaskWallet {
        case .loading:
            EmptyView()
        case .success(let model):
            if let model {
                VStack(spacing: 8) {
                    Text("Address: " + model.walletAddress)
                    Text("Chain ID: " + model.chainId)
                }
                .onAppear {
                    viewModel.signMetaskWallet(nonce: model.walletAddress)
                }
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
    
    @ViewBuilder @MainActor private var metamaskSignature: some View {
        switch viewModel.metamaskSignature {
        case .loading:
            EmptyView()
        case .success(let signature):
            if let signature {
                Text(signature)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error(let error):
            Text(error.localizedDescription)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    MainView()
}
