//
//  MainViewModel.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import Foundation

public class MainViewModel: ObservableObject {
    private let appleAuthentication: any AppleAuthentication
    private let facebookAuthentication: any FacebookAuthentication
    private let googleAuthentication: any GoogleAuthentication
    private let xAuthentication: any XAuthentication
    private let telegramAuthentication: any TelegramAuthentication
    private let metamaskConnect: MetamasConnect
    
    @Published var appleToken: DataState<String?> = .success(data: nil)
    @Published var facebookToken: DataState<String?> = .success(data: nil)
    @Published var googleToken: DataState<String?> = .success(data: nil)
    @Published var xToken: DataState<String?> = .success(data: nil)
    @Published var telegramToken: DataState<TelegramResultModel?> = .success(data: nil)
    @Published var metamaskWallet: DataState<WalletModel?> = .success(data: nil)
    @Published var metamaskSignature: DataState<String?> = .success(data: nil)
    
    init(
        appleAuthentication: any AppleAuthentication,
        facebookAuthentication: any FacebookAuthentication,
        googleAuthentication: any GoogleAuthentication,
        xAuthentication: any XAuthentication,
        telegramAuthentication: any TelegramAuthentication,
        metamaskConnect: MetamasConnect
    ) {
        self.appleAuthentication = appleAuthentication
        self.facebookAuthentication = facebookAuthentication
        self.googleAuthentication = googleAuthentication
        self.xAuthentication = xAuthentication
        self.telegramAuthentication = telegramAuthentication
        self.metamaskConnect = metamaskConnect
    }
    
    func signInWithApple() {
        appleToken = .loading
        Task(priority: .background) { [weak self] in
            guard let self else { return }
            do {
                let token = try await self.appleAuthentication.getToken()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.appleToken = .success(data: token)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.appleToken = .error(error: error)
                }
            }
        }
    }
    
    func signInWithFacebook() {
        facebookToken = .loading
        
        Task(priority: .background) { [weak self] in
            guard let self else { return }
            do {
                let token = try await self.facebookAuthentication.getToken()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.facebookToken = .success(data: token)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.facebookToken = .error(error: error)
                }
            }
        }
    }
    
    func signInWithGoogle() {
        googleToken = .loading
        
        Task(priority: .high) { @MainActor [weak self] in
            guard let self else { return }
            do {
                let token = try await self.googleAuthentication.getToken()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.googleToken = .success(data: token)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.googleToken = .error(error: error)
                }
            }
        }
    }
    
    func signInWithX() {
        xToken = .loading
        Task(priority: .high) { @MainActor [weak self] in
            guard let self else { return }
            do {
                let token = try await self.xAuthentication.getToken()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.xToken = .success(data: token)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.xToken = .error(error: error)
                }
            }
        }
    }
    
    func signInWithTelegram() {
        telegramToken = .loading
        Task(priority: .high) { [weak self] in
            guard let self else { return }
            do {
                let token = try await self.telegramAuthentication.getToken()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.telegramToken = .success(data: token)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.telegramToken = .error(error: error)
                }
            }
        }
    }
    
    func connectMetamaskWalletAddress() {
        metamaskWallet = .loading
        Task(priority: .high) { [weak self] in
            guard let self else { return }
            do {
                let wallet = try await self.metamaskConnect.connect()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.metamaskWallet = .success(data: wallet)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.metamaskWallet = .error(error: error)
                }
            }
        }
    }
    
    func signMetaskWallet(nonce: String) {
        Task(priority: .high) { [weak self] in
            guard let self else { return }
            do {
                let signature = try await self.metamaskConnect.sign(nonce: nonce)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.metamaskSignature = .success(data: signature)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.metamaskSignature = .error(error: error)
                }
            }
        }
    }
}
