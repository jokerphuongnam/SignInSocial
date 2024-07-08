//
//  MetamasConnect.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation
import metamask_ios_sdk

public protocol MetamasConnect: WalletConnect { }

public class MetamasConnectImpl: MetamasConnect {
    private lazy var metamaskSDK: MetaMaskSDK = {
#if DEBUG
        let enableDebug = true
#else
        let enableDebug = false
#endif
        let metaData = AppMetadata(name: "$(APP_NAME)", url: "$(APP_SCHEME)")
        let metamaskSDK = MetaMaskSDK.shared(
            metaData,
            enableDebug: enableDebug,
            sdkOptions: nil
        )
        metamaskSDK.useDeeplinks = true
        return metamaskSDK
    }()
    var completion: (() -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(stateLoading(_:)), name: NSNotification.Name("connection"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("connection"), object: nil)
    }
    
    public func connect() async throws -> WalletModel {
        disconnect()
        let result = await metamaskSDK.connect()
        print(result)
        switch result {
        case .success(let walletAddress):
            return WalletModel(
                chainId: metamaskSDK.chainId,
                walletAddress: walletAddress
            )
        case .failure(let failure):
            throw failure
        }
    }
    
    public func sign(nonce: String) async throws -> String {
        let result = await metamaskSDK.connectAndSign(message: "0x\(nonce.hexEncodedString())")
        switch result {
        case .success(let signature):
            return signature
        case .failure(let failure):
            throw failure
        }
    }
    
    private func disconnect() {
        metamaskSDK.disconnect()
        metamaskSDK.terminateConnection()
        metamaskSDK.clearSession()
        completion?()
    }
    
    @objc private func stateLoading(_ sender: Notification) {
        if let userInfo = sender.userInfo, let value = userInfo["value"], let value = value as? String {
            if value == "Clients Disconnected" {
                Task(priority: .high) { @MainActor [weak self] in
                    guard let self else { return }
                    self.completion?()
                }
            }
        }
    }
}
