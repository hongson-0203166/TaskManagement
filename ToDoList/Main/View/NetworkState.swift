//
//  NetworkState.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 11/06/2024.
//

import Foundation
import Alamofire
protocol NetworkStateDelegate: AnyObject {
    func networkStatusDidChange(isConnected: Bool)
}

class NetworkState {
    static let shared = NetworkState()
    private let reachabilityManager = NetworkReachabilityManager()
    weak var delegate: NetworkStateDelegate?
     init() {
        startListening()
    }

    private func startListening() {
        reachabilityManager?.startListening { [weak self] status in
            let isConnected = self?.reachabilityManager?.isReachable ?? false
            self?.delegate?.networkStatusDidChange(isConnected: isConnected)
        }
    }

    func isConnected() -> Bool {
        return reachabilityManager?.isReachable ?? false
    }
}
