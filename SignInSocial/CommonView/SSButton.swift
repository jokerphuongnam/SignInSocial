//
//  SSButton.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import SwiftUI

struct SSButton: View {
    private let text: String
    private let isLoading: Bool
    private let action: () -> Void
    
    init(
        text: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        containerView
    }
    
    @ViewBuilder @MainActor private var containerView: some View {
        button
    }
    
    @ViewBuilder @MainActor private var button: some View {
        Button {
            action()
        } label: {
            contentButton
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .tint(.white)
                .cornerRadius(8)
        }
        .disabled(isLoading)
    }
    
    @ViewBuilder @MainActor private var contentButton: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else {
            Text(text)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    SSButton(text: "Test") {
        
    }
}
