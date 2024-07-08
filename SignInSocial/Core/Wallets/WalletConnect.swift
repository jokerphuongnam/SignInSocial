//
//  WalletConnect.swift
//  SignInSocial
//
//  Created by P. Nam on 08/07/2024.
//

import Foundation

public struct WalletModel: Hashable {
    let chainId: String
    let walletAddress: String
}

public protocol WalletConnect {
    func connect() async throws -> WalletModel
    func sign(nonce: String) async throws -> String
}
