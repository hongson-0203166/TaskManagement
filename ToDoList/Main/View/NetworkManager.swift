//
//  NetworkManager.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 12/06/2024.
//

import Foundation
import Reachability
class NetworkManager: NSObject {
    var reachability: Reachability!
    static let sharedInstance: NetworkManager = {
        return NetworkManager()
    }()
    override init() {
        super.init()
        // Initialise reachability
        do{
            reachability = try Reachability()
        }catch{
            print("Unable to start notifier")
        }
        
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
                
                switch reachability.connection {
                case .wifi:
                    print("Network reachable via WiFi")
                    NotificationCenter.default.post(name: .networkStatusChanged, object: self, userInfo: ["status": "WiFi"])
                case .cellular:
                    print("Network reachable via Cellular")
                    NotificationCenter.default.post(name: .networkStatusChanged, object: self, userInfo: ["status": "Cellular"])
                case .unavailable, .none:
                    print("Network not reachable")
                    NotificationCenter.default.post(name: .networkStatusChanged, object: self, userInfo: ["status": "None"])
                }
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (NetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
    
}
