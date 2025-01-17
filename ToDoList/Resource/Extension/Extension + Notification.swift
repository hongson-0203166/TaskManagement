//
//  Extension + Notification.swift
//  ToDoList
//
//  Created by Phạm Hồng Sơn on 30/05/2024.
//

import UIKit
extension Notification.Name {
    static let taskUpdated = Notification.Name("taskUpdated")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
    static let syncPendingActions = Notification.Name("syncPendingActions")
    
}
