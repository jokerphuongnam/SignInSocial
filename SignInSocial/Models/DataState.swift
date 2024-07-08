//
//  DataState.swift
//  SignInSocial
//
//  Created by P. Nam on 05/07/2024.
//

import Foundation

public enum DataState<T>: Hashable where T: Hashable {
    case loading
    case success(data: T)
    case error(error: Error)
    
    var isLoading: Bool {
        self == .loading
    }
}

extension DataState {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .loading:
            hasher.combine(0)
        case let .success(data):
            hasher.combine(1)
            hasher.combine(data)
        case let .error(error):
            hasher.combine(2)
            hasher.combine("\(error)")
        }
    }
    
    public static func == (lhs: DataState<T>, rhs: DataState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case let (.success(data1), .success(data2)):
            return data1 == data2
        case let (.error(error1), .error(error2)):
            return "\(error1)" == "\(error2)"
        default:
            return false
        }
    }
}
