//
//  premiumManager.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 14/11/24.
//

import Foundation

class PremiumManager {
    static let shared = PremiumManager()
    private let defaults = UserDefaults.standard

    private let subscriptionActiveKey = "isSubscriptionActive"
    private let subscriptionExpirationDateKey = "subscriptionExpirationDate"
    private let allUnlockedKey = "allContentUnlocked"

    private var temporarilyUnlockedContent: Set<Int> = []
    
    var isSubscriptionActive: Bool {
        guard let expirationDate = defaults.object(forKey: subscriptionExpirationDateKey) as? Date else {
            return false
        }
        
        return expirationDate > Date()
    }
    
    func setSubscription(expirationDate: Date) {
        defaults.set(true, forKey: subscriptionActiveKey)
        defaults.set(expirationDate, forKey: subscriptionExpirationDateKey)
    }
    
    func clearSubscription() {
        defaults.removeObject(forKey: subscriptionActiveKey)
        defaults.removeObject(forKey: subscriptionExpirationDateKey)
    }
    
    func isContentUnlocked(itemID: Int) -> Bool {
        if defaults.bool(forKey: allUnlockedKey) {
            return true
        }
        
        if isSubscriptionActive {
            return true
        }

        return temporarilyUnlockedContent.contains(itemID)
    }

    func temporarilyUnlockContent(itemID: Int) {
        temporarilyUnlockedContent.insert(itemID)
    }

    func clearTemporaryUnlocks() {
        temporarilyUnlockedContent.removeAll()
    }
    
    func checkSubscriptionStatus() {
        guard let expirationDate = defaults.object(forKey: subscriptionExpirationDateKey) as? Date else {
            return
        }
        
        if expirationDate <= Date() {
            clearSubscription()
            clearTemporaryUnlocks()
        }
    }
}
